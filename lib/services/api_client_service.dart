import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pashudhan_qr/app/app.logger.dart';
import 'package:pashudhan_qr/app/app.router.dart';
import 'package:pashudhan_qr/core/exceptions.dart';
import 'package:stacked_services/stacked_services.dart';

/// Production-ready Dio HTTP client for the Pashudhan QR backend.
///
/// Responsibilities:
///   • Attach Bearer token to every protected request.
///   • Provide [basicAuthHeader] for login-style endpoints.
///   • Detect & propagate meaningful errors (400, 401, 403, 500, 503, …).
///   • Log every request / response cycle (verbose in debug, silent in release).
///   • Auto-logout on expired JWT.
class ApiClientService {
  final _logger = getLogger('ApiClientService');

  // Pass --dart-define=HTTP_DEBUG=true at flutter run to enable verbose
  // request/response header + body logging.
  static const _httpDebug = bool.fromEnvironment('HTTP_DEBUG', defaultValue: false);

  // ─── Base URL ─────────────────────────────────────────────────────────────
  // ✅ Correct backend base URL (NOT the Swagger UI URL).
  static const String _baseUrl =
      // 'http://10.165.233.102:8443'; // 🧪 LOCAL — same WiFi required
      'https://pashudhanqr-api-f5b0885dd324.herokuapp.com'; // ☁️ HEROKU (production)

  String get baseUrl => _baseUrl;

  // ─── Secure storage ───────────────────────────────────────────────────────
  final _storage = const FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';

  // JWT expiry cache — avoids redundant base64 decoding per request.
  int? _cachedTokenExp;
  String? _cachedToken;

  // Auto-incrementing request ID for log correlation.
  int _requestCounter = 0;
  String _newRequestId() => 'req-${++_requestCounter}';

  // ─── Public (unauthenticated) paths ──────────────────────────────────────
  // These paths skip Bearer-token injection.
  static const List<String> _publicPaths = [
    '/v1/otp',
    '/v1/otp/verify',
    '/v1/auth/admin/login',
  ];

  bool _isPublicEndpoint(String path) {
    // Exact matching or prefix matching for public routes
    return path.startsWith('/v1/otp/') || 
           path.startsWith('/v1/auth/') ||
           _publicPaths.contains(path);
  }

  // ─── Dio instance ─────────────────────────────────────────────────────────
  late final Dio _client;

  ApiClientService() {
    _client = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        // ✅ Default Content-Type for all JSON requests.
        contentType: 'application/json',
        headers: const {
          'Accept': 'application/json',
        },
      ),
    );

    _addLoggingInterceptor();
    _addMainInterceptor();

    _logger.i('✅ ApiClientService initialized → $_baseUrl');
  }

  Dio get client => _client;

  // ─── Public helpers ───────────────────────────────────────────────────────

  /// Returns a Basic-Auth header value for [username] / [password].
  ///
  /// Usage inside a ViewModel / repository:
  /// ```dart
  /// final response = await _apiClient.client.post(
  ///   '/v1/auth/admin/login',
  ///   options: Options(headers: {
  ///     'Authorization': _apiClient.basicAuthHeader('admin@example.com', 'secret'),
  ///   }),
  /// );
  /// ```
  String basicAuthHeader(String username, String password) {
    final credentials = base64Encode(utf8.encode('$username:$password'));
    return 'Basic $credentials';
  }

  /// Persists [token] to secure storage for later Bearer-token injection.
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
    // Invalidate cache so the new token is parsed on the next request.
    _cachedToken = null;
    _cachedTokenExp = null;
    _logger.i('✅ Token saved to secure storage.');
  }

  /// Reads the current token from secure storage (may be null).
  Future<String?> getToken() => _storage.read(key: _tokenKey);
  String? get token => _cachedToken;

  /// Deletes the stored token (call on logout).
  Future<void> deleteToken() => _storage.delete(key: _tokenKey);

  /// Fetches the profile picture as raw bytes (Uint8List).
  ///
  /// This endpoint returns image/png or image/jpeg directly (binary),
  /// so we MUST override the global 'Accept: application/json' header.
  Future<Uint8List?> getProfileImage() async {
    try {
      final response = await _client.get(
        '/v1/user/profilePic',
        options: Options(
          responseType: ResponseType.bytes,
          // Overriding global headers to avoid 406 Not Acceptable
          headers: {
            'Accept': 'image/*, */*',
          },
          // Allow 204 (No Content) as a valid success state
          validateStatus: (status) =>
              (status != null && status >= 200 && status < 300),
        ),
      );

      if (response.statusCode == 204 || response.data == null) {
        _logger.i('👤 No profile picture set (204 No Content).');
        return null;
      }

      if (response.data is Uint8List) {
        return response.data as Uint8List;
      }

      if (response.data is List<int>) {
        return Uint8List.fromList(response.data as List<int>);
      }

      _logger.w('⚠️ Unexpected profile picture data type: ${response.data.runtimeType}');
      return null;
    } catch (e) {
      _logger.w('👤 Profile picture fetch failed or not found: $e');
      return null;
    }
  }

  // ─── Interceptors ─────────────────────────────────────────────────────────

  /// Full header + body logging when HTTP_DEBUG=true; errors always logged.
  void _addLoggingInterceptor() {
    _client.interceptors.add(
      LogInterceptor(
        requestHeader: _httpDebug,
        requestBody: _httpDebug,
        responseHeader: _httpDebug,
        responseBody: _httpDebug,
        error: true,
        logPrint: (obj) => _logger.d(obj.toString()),
      ),
    );
  }

  /// Core interceptor: token injection + structured error mapping.
  void _addMainInterceptor() {
    _client.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
  }

  // ─── onRequest ────────────────────────────────────────────────────────────

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final path = options.path;
    final method = options.method.toUpperCase();
    final requestId = _newRequestId();
    options.extra['requestId'] = requestId;
    _logger.i('➡️  [$requestId] $method $_baseUrl$path');

    if (_isPublicEndpoint(path)) {
      _logger.d('🔓 Public endpoint — skipping token injection for $path');
      return handler.next(options);
    }

    String? token;

    final isOtpEndpoint = (path == '/v1/associate' && method == 'POST') ||
                          (path == '/v1/users/createCustomer' && method == 'POST');

    final isMixedAuthEndpoint = (path == '/v1/associate-partner' && method == 'GET');

    if (isOtpEndpoint) {
      token = await _storage.read(key: 'otp_token');
    } else {
      token = await _storage.read(key: _tokenKey);
      
      // Fallback to otp_token during registration where auth_token is not yet available
      if ((token == null || token.isEmpty) && isMixedAuthEndpoint) {
        token = await _storage.read(key: 'otp_token');
        if (token != null && token.isNotEmpty) {
          _logger.d('⚠️  No auth_token found, falling back to otp_token for mixed auth endpoint.');
        }
      }
    }

    if (token == null || token.isEmpty) {
      if (isOtpEndpoint) {
        // For OTP-auth endpoints: missing token means OTP was never completed.
        // Do NOT wipe storage or navigate away — let the ViewModel handle this.
        _logger.w('⚠️  No OTP token found for $path. OTP verification may not have completed.');
        return handler.reject(
          DioException(
            requestOptions: options,
            error: UnauthenticatedException('OTP verification required. Please verify your phone number first.'),
            type: DioExceptionType.cancel,
          ),
        );
      }
      final otpToken = await _storage.read(key: 'otp_token');
      if (otpToken != null && otpToken.isNotEmpty) {
        _logger.w('⚠️  No auth_token found for protected path: $path, but otp_token exists. Silently skipping request (OTP stage).');
        options.extra['skip'] = true;
        return handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: [], // Return empty list safely for downstream parsing
          ),
        );
      }

      _logger.w('⚠️  No token found for protected path: $path. Clearing session to prevent retry loops.');
      await _handleAutoLogout('Authentication required.');
      return handler.reject(
        DioException(
          requestOptions: options,
          error: UnauthenticatedException('Authentication required.'),
          type: DioExceptionType.cancel,
        ),
      );
    }

    // Only check JWT expiry for regular auth tokens, not OTP tokens.
    // OTP tokens have different lifetimes and must not be rejected here.
    if (!isOtpEndpoint && _isTokenExpired(token)) {
      _logger.w('❌ JWT expired — logging out.');
      await _handleAutoLogout('Session expired. Please log in again.');
      return handler.reject(
        DioException(
          requestOptions: options,
          error: UnauthenticatedException('Session expired. Please log in again.'),
          type: DioExceptionType.cancel,
        ),
      );
    }

    // ✅ Attach Bearer token.
    options.headers['Authorization'] = 'Bearer $token';
    final tokenKind = isOtpEndpoint ? 'otp' : 'auth';
    final preview = _httpDebug ? token : (token.length > 20 ? '${token.substring(0, 20)}…' : token);
    _logger.i('🔐 [$requestId] Authorization: Bearer $preview ($tokenKind)');

    return handler.next(options);
  }

  // ─── onResponse ───────────────────────────────────────────────────────────

  void _onResponse(Response response, ResponseInterceptorHandler handler) {
    final requestId = response.requestOptions.extra['requestId'] ?? '?';
    _logger.i(
      '⬅️  [$requestId] ${response.statusCode} ${response.requestOptions.method} '
      '${response.requestOptions.path}',
    );

    // Safely decode string bodies that Dio failed to auto-parse.
    if (response.data is String &&
        (response.data as String).isNotEmpty) {
      try {
        response.data = jsonDecode(response.data as String);
      } catch (_) {
        _logger.w('⚠️  Non-JSON response body — keeping as plain text.');
      }
    }

    handler.next(response);
  }

  // ─── onError ──────────────────────────────────────────────────────────────

  Future<void> _onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    void rejectWith(Exception e) {
      handler.reject(DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: e,
      ));
    }

    final status = err.response?.statusCode;
    final path = err.requestOptions.path;
    final requestId = err.requestOptions.extra['requestId'] ?? '?';

    _logger.e('🔴 [$requestId] API Error [$status] on $path → ${err.message}');

    // Always log the error response body so we can diagnose 422 / 400 / 500
    // validation or server errors without needing HTTP_DEBUG=true.
    if (err.response?.data != null) {
      _logger.e('🔴 [$requestId] Response body: ${err.response?.data}');
    }

    // ── Network / connectivity errors ──
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.connectionError ||
        err.error is SocketException) {
      _logger.e('🔴 Network error — cannot reach server.');
      return rejectWith(ServerException(
        'Unable to connect to the server. Please check your internet connection.',
      ));
    }

    // ── SSL handshake failure ──
    if (err.error is HandshakeException) {
      _logger.e('🔴 SSL handshake failed.');
      return rejectWith(ServerException('SSL certificate error. Please contact support.'));
    }

    // ── Format / decoding error ──
    if (err.error is FormatException) {
      _logger.e('🔴 FormatException — unexpected response format.');
      return rejectWith(ServerException('Invalid server response. Please try again.'));
    }

    // ── HTTP status-based handling ──
    switch (status) {
      case 400:
        _logger.w('⚠️  400 Bad Request — $path');
        final msg = _extractMessage(err.response?.data, 'Bad request. Please check your input.');
        return rejectWith(ServerException(msg));

      case 401:
        _logger.w('⚠️  401 Unauthorised — $path');
        // Login endpoints (OTP / Basic-Auth) return 401 for wrong credentials;
        // forward to the ViewModel so it can show the correct message.
        if (_isPublicEndpoint(path)) {
          return handler.next(err);
        }
        // For protected endpoints, treat as session expiry.
        await _handleAutoLogout('Session expired. Please log in again.');
        return rejectWith(UnauthenticatedException('Session expired. Please log in again.'));

      case 403:
        _logger.w('⚠️  403 Forbidden — $path');
        // Forward to ViewModel (e.g. approval-pending routing).
        return handler.next(err);

      case 404:
        _logger.w('⚠️  404 Not Found — $path');
        return rejectWith(ServerException('Requested resource not found.'));

      case 422:
        _logger.w('⚠️  422 Unprocessable Entity — $path');
        _logger.w('⚠️  422 Response data: ${err.response?.data}');
        final msg = _extractMessage(err.response?.data, 'Invalid data. Please check your input and try again.');
        return rejectWith(ServerException(msg));

      case 500:
        _logger.e('🔴 500 Internal Server Error — $path');
        final msg = _extractMessage(err.response?.data, 'Internal server error. Please try again later.');
        return rejectWith(ServerException(msg));

      case 503:
        _logger.e('🔴 503 Service Unavailable — $path');
        return rejectWith(ServerException(
          'The server is temporarily unavailable. Please try again shortly.',
        ));

      default:
        if (status != null) {
          _logger.e('🔴 Unhandled HTTP $status — $path');
        }
        return handler.next(err);
    }
  }

  // ─── Private helpers ──────────────────────────────────────────────────────

  /// Extracts a human-readable message from a JSON error body.
  ///
  /// Supports two server formats:
  ///   • AppException:  `{"code": 409, "message": "Customer already exists"}`
  ///   • Bean Validation (422): `{"errors": ["field userName may not be blank"]}`
  String _extractMessage(dynamic data, String fallback) {
    if (data is Map) {
      if (data['message'] != null) {
        return data['message'].toString();
      }
      // Dropwizard bean-validation errors use an 'errors' array.
      if (data['errors'] is List && (data['errors'] as List).isNotEmpty) {
        return (data['errors'] as List).join('; ');
      }
    }
    return fallback;
  }

  /// Clears secure storage and navigates to the login screen.
  Future<void> _handleAutoLogout(String reason) async {
    _logger.w('🚪 Auto-logout: $reason');
    try {
      await _storage.deleteAll();
    } catch (e) {
      _logger.e('Failed to clear storage on auto-logout: $e');
    }

    await Future.delayed(const Duration(milliseconds: 100));

    StackedService.navigatorKey?.currentState?.pushNamedAndRemoveUntil(
      Routes.loginView,
      (route) => false,
    );
  }

  /// Parses a JWT and returns `true` if the `exp` claim is in the past.
  /// Caches the parsed expiry so repeated calls within the same request are free.
  bool _isTokenExpired(String token) {
    if (_cachedToken != token) {
      _cachedToken = token;
      _cachedTokenExp = null;
      try {
        final parts = token.split('.');
        if (parts.length == 3) {
          final payload = jsonDecode(
            utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
          );
          _cachedTokenExp = payload['exp'] as int?;
        }
      } catch (e) {
        _logger.w('Could not parse JWT expiry: $e');
      }
    }

    if (_cachedTokenExp == null) return false;

    const driftBufferSeconds = 30;
    final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return (_cachedTokenExp! - driftBufferSeconds) < nowSeconds;
  }
}