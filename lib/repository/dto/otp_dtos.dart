import 'dart:convert';
import 'package:pashudhan_qr/core/json_parsers.dart';

class VerifyOtpParsedResponse {
  final String? jwtToken;
  final int? userId;
  final String? role;

  VerifyOtpParsedResponse({this.jwtToken, this.userId, this.role});
}

class GenerateOtpResponse {
  final int otpId;

  GenerateOtpResponse({
    required this.otpId,
  });

  GenerateOtpResponse copyWith({
    int? otpId,
  }) {
    return GenerateOtpResponse(
      otpId: otpId ?? this.otpId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'otpId': otpId,
    };
  }

  factory GenerateOtpResponse.fromMap(Map<String, dynamic> map) {
    return GenerateOtpResponse(
      otpId: JsonParsers.parseInt(map['otpId']),
    );
  }

  String toJson() => json.encode(toMap());

  factory GenerateOtpResponse.fromJson(String source) =>
      GenerateOtpResponse.fromMap(json.decode(source));

  @override
  String toString() => 'GenerateOtpResponse(otpId: $otpId)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GenerateOtpResponse && other.otpId == otpId;
  }

  @override
  int get hashCode => otpId.hashCode;
}

class VerifyOtpRequest {
  final int otpId;
  final int otp;
  final String userName;

  VerifyOtpRequest({
    required this.otpId,
    required this.otp,
    required this.userName,
  });

  VerifyOtpRequest copyWith({
    int? otpId,
    int? otp,
    String? userName,
  }) {
    return VerifyOtpRequest(
      otpId: otpId ?? this.otpId,
      otp: otp ?? this.otp,
      userName: userName ?? this.userName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'otpId': otpId,
      'otp': otp,
      'userName': userName,
    };
  }

  factory VerifyOtpRequest.fromMap(Map<String, dynamic> map) {
    return VerifyOtpRequest(
      otpId: JsonParsers.parseInt(map['otpId']),
      otp: JsonParsers.parseInt(map['otp']),
      userName: JsonParsers.parseString(map['userName']),
    );
  }

  String toJson() => json.encode(toMap());

  factory VerifyOtpRequest.fromJson(String source) =>
      VerifyOtpRequest.fromMap(json.decode(source));

  @override
  String toString() =>
      'VerifyOtpRequest(otpId: $otpId, otp: $otp, userName: $userName)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is VerifyOtpRequest &&
        other.otpId == otpId &&
        other.otp == otp &&
        other.userName == userName;
  }

  @override
  int get hashCode => otpId.hashCode ^ otp.hashCode ^ userName.hashCode;
}
