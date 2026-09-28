import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pashudhan_qr/app/app.locator.dart';
import 'package:pashudhan_qr/app/app.logger.dart';
import 'package:pashudhan_qr/app/app.router.dart';
import 'package:pashudhan_qr/models/associate.dart';
import 'package:pashudhan_qr/repository/associate_repository.dart';
import 'package:pashudhan_qr/repository/dto/associate_dtos.dart';
import 'package:pashudhan_qr/repository/dto/user_dtos.dart';
import 'package:pashudhan_qr/repository/user_repository.dart';
import 'package:pashudhan_qr/services/storage_service.dart';
import 'package:pashudhan_qr/repository/associate_partner_repository.dart';
import 'package:pashudhan_qr/models/customer.dart';
import 'package:pashudhan_qr/services/api_client_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class ProfileViewModel extends BaseViewModel {
  final _log = getLogger('ProfileViewModel');
  final _userRepo = locator<UserRepository>();
  final _associateRepo = locator<AssociateRepository>();
  final _storage = locator<StorageService>();
  final _dialogService = locator<DialogService>();
  final _navigationService = locator<NavigationService>();

  // ── State ──────────────────────────────────────────────────────────
  Associate? associate;
  Customer? customer;
  Uint8List? profilePicBytes;
  bool isFetchingPic = false;
  bool isUploadingPic = false;
  bool isDeletingPic = false;

  // ── Editable fields ────────────────────────────────────────────────
  String editedName = '';
  String editedIdNo = '';
  bool isEditing = false;

  // ── Role info ──────────────────────────────────────────────────────
  String userName = '';
  String userPhone = '';
  String userRole = '';
  String userId = '';

  // ── Init ───────────────────────────────────────────────────────────
  Future<void> init() async {
    setBusy(true);
    try {
      userName = await _storage.getCustomData('user_name') ?? '';
      userPhone = await _storage.getCustomData('user_phone') ?? '';
      userRole = await _storage.getCustomData('user_role') ?? '';
      userId = await _storage.getCustomData('user_id') ?? '';

      // Load profile details based on role
      if (userRole.toUpperCase() == 'CUSTOMER') {
        try {
          final api = locator<ApiClientService>();
          final response = await api.client.get('/v1/users/me');
          _log.i('Fetched /v1/users/me raw: ${response.data}');
          final dynamic apiData = response.data['data'] ?? response.data;
          if (apiData != null && apiData is Map<String, dynamic>) {
            customer = Customer.fromJson(apiData);
            _log.i('Parsed customer successfully: name=${customer?.name}, aadhar=${customer?.aadharNumber}, pin=${customer?.pincode}');
            editedName = customer?.name ?? userName;
          } else {
            customer = await _userRepo.getCurrentUser();
            editedName = customer?.name ?? userName;
          }
        } catch (e) {
          _log.w('Customer fetch from endpoint failed: $e');
          try {
            customer = await _userRepo.getCurrentUser();
            editedName = customer?.name ?? userName;
          } catch (innerError) {
            _log.w('Fallback customer fetch failed: $innerError');
            editedName = userName;
          }
        }
      } else if (userId.isNotEmpty) {
        // Load associate profile
        try {
          associate = await _associateRepo.getAssociate(userId);
          editedName = associate?.fullName ?? userName;
          editedIdNo = associate?.idNo ?? '';
        } catch (e) {
          _log.w('Associate fetch failed (may be customer): $e');
          editedName = userName;
        }
      }

      // Load profile picture URL
      await _loadProfilePic();
    } catch (e) {
      _log.e('Profile init failed: $e');
    } finally {
      setBusy(false);
    }
  }

  Future<void> _loadProfilePic() async {
    isFetchingPic = true;
    notifyListeners();
    try {
      profilePicBytes = await _userRepo.getProfilePic();
    } catch (e) {
      _log.w('Profile pic load failed: $e');
      profilePicBytes = null;
    } finally {
      isFetchingPic = false;
      notifyListeners();
    }
  }

  // ── Profile picture CRUD ───────────────────────────────────────────

  Future<void> uploadProfilePicFromCamera() async {
    await _pickAndUpload(ImageSource.camera);
  }

  Future<void> uploadProfilePicFromGallery() async {
    await _pickAndUpload(ImageSource.gallery);
  }

  Future<void> _pickAndUpload(ImageSource source) async {
    if (isUploadingPic) return;
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (picked == null) return;

      isUploadingPic = true;
      notifyListeners();

      await _userRepo.uploadProfilePic(
        ProfilePicUploadRequest(filePath: picked.path),
      );

      await _loadProfilePic();
    } on DioException catch (e) {
      _dialogService.showDialog(
        title: 'Upload Failed',
        description: _friendlyDioMessage(e, 'profile picture'),
      );
    } catch (e) {
      _dialogService.showDialog(
        title: 'Upload Failed',
        description: 'Could not upload profile picture. Please try again.',
      );
    } finally {
      isUploadingPic = false;
      notifyListeners();
    }
  }

  Future<void> deleteProfilePic() async {
    final confirm = await _dialogService.showConfirmationDialog(
      title: 'Remove Photo',
      description: 'Are you sure you want to remove your profile photo?',
      confirmationTitle: 'Remove',
      cancelTitle: 'Cancel',
    );
    if (confirm?.confirmed != true) return;

    isDeletingPic = true;
    notifyListeners();
    try {
      // POST /v1/user/profilePic  → DELETE /v1/user/profilePic
      await _userRepo.deleteProfilePic();
      profilePicBytes = null;
      notifyListeners();
    } on DioException catch (e) {
      _dialogService.showDialog(
        title: 'Remove Failed',
        description: _friendlyDioMessage(e, 'profile picture removal'),
      );
    } catch (e) {
      _dialogService.showDialog(
        title: 'Remove Failed',
        description: 'Could not remove profile picture. Please try again.',
      );
    } finally {
      isDeletingPic = false;
      notifyListeners();
    }
  }

  // ── Edit profile ───────────────────────────────────────────────────

  void startEditing() {
    isEditing = true;
    notifyListeners();
  }

  void cancelEditing() {
    editedName = associate?.fullName ?? userName;
    editedIdNo = associate?.idNo ?? '';
    isEditing = false;
    notifyListeners();
  }

  void setEditedName(String v) => editedName = v.trim();
  void setEditedIdNo(String v) => editedIdNo = v.trim();

  Future<void> saveProfile() async {
    if (editedName.isEmpty) {
      _dialogService.showDialog(
        title: 'Name Required',
        description: 'Full name cannot be empty.',
      );
      return;
    }
    if (isBusy) return;
    setBusy(true);
    try {
      final id = int.tryParse(userId) ?? 0;
      // PUT /v1/associate/{id}
      await _associateRepo.updateAssociate(
        id,
        AssociateRequest(
          userName: userName,
          fullName: editedName,
          idNo: editedIdNo,
        ),
      );
      // Refresh
      associate = await _associateRepo.getAssociate(userId);
      await _storage.saveCustomData('user_name', editedName);
      userName = editedName;
      isEditing = false;
      _dialogService.showDialog(
        title: 'Profile Updated',
        description: 'Your profile has been updated successfully.',
      );
      notifyListeners();
    } on DioException catch (e) {
      _dialogService.showDialog(
        title: 'Update Failed',
        description: _friendlyDioMessage(e, 'profile update'),
      );
    } catch (e) {
      _dialogService.showDialog(
        title: 'Update Failed',
        description: 'Could not update profile. Please try again.',
      );
    } finally {
      setBusy(false);
    }
  }

  // ── Delete account ─────────────────────────────────────────────────

  Future<void> deleteAccount() async {
    final confirm = await _dialogService.showConfirmationDialog(
      title: '⚠️ Deactivate Account',
      description:
          'Are you sure you want to deactivate your account? Once deactivated, you will not be able to log in or access any of your registered details and information. This action is permanent and cannot be undone.',
      confirmationTitle: 'Deactivate',
      cancelTitle: 'Cancel',
    );
    if (confirm?.confirmed != true) return;

    setBusy(true);
    try {
      final id = int.tryParse(userId) ?? 0;
      final role = userRole.toUpperCase();

      if (role == 'ASSOCIATE') {
        await _associateRepo.deleteAssociate(id);
      } else if (role == 'ASSOCIATE_PARTNER' || role == 'PARTNER') {
        final partnerRepo = locator<AssociatePartnerRepository>();
        await partnerRepo.deletePartner(id);
      } else if (role == 'CUSTOMER') {
        await _userRepo.deleteCurrentUser();
      } else {
        await _userRepo.deleteCurrentUser();
      }

      await _storage.clearAll();
      _navigationService.clearStackAndShow(Routes.loginView);
    } on DioException catch (e) {
      _dialogService.showDialog(
        title: 'Deactivation Failed',
        description: _friendlyDioMessage(e, 'account deactivation'),
      );
    } catch (e) {
      _dialogService.showDialog(
        title: 'Deactivation Failed',
        description: 'Could not deactivate account. Please try again.',
      );
    } finally {
      setBusy(false);
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────

  Future<void> logout() async {
    final confirm = await _dialogService.showConfirmationDialog(
      title: 'Logout',
      description: 'Are you sure you want to log out?',
      confirmationTitle: 'Logout',
      cancelTitle: 'Cancel',
    );
    if (confirm?.confirmed != true) return;

    await _storage.clearAll();
    _navigationService.clearStackAndShow(Routes.loginView);
  }

  // ── Helper ─────────────────────────────────────────────────────────

  String _friendlyDioMessage(DioException e, String context) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    if (data is Map && data['message'] != null)
      return data['message'].toString();
    switch (status) {
      case 400:
        return 'Invalid data for $context. Please check your input.';
      case 401:
        return 'Your session has expired. Please log in again.';
      case 403:
        return 'You do not have permission for $context.';
      case 404:
        return 'Resource not found for $context.';
      case 413:
        return 'File too large. Please use a smaller image.';
      case 500:
        return 'Server error during $context. Try again in a moment.';
      case 503:
        return 'Service unavailable. Try again shortly.';
      default:
        return e.message ?? 'Something went wrong during $context.';
    }
  }
}
