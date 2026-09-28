import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pashudhan_qr/app/app.locator.dart';
import 'package:pashudhan_qr/repository/associate_repository.dart';
import 'package:pashudhan_qr/repository/dto/associate_dtos.dart';
import 'package:pashudhan_qr/repository/pashudhan_repository.dart';
import 'package:pashudhan_qr/repository/pet_repository.dart';
import 'package:pashudhan_qr/services/storage_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:pashudhan_qr/app/app.router.dart';

class PhotoUploadViewModel extends BaseViewModel {
  final String uuid;
  final bool? isPet;

  final _pashudhanRepo = locator<PashudhanRepository>();
  final _petRepo = locator<PetRepository>();
  final _associateRepo = locator<AssociateRepository>();
  final _dialogService = locator<DialogService>();
  final _navigationService = locator<NavigationService>();
  final _storage = locator<StorageService>();

  final List<XFile> _selectedImages = [];
  List<XFile> get selectedImages => List.unmodifiable(_selectedImages);



  /// Associate registration mode: no livestock/pet uuid yet
  bool get isAssociate => uuid.isEmpty;

  /// Exactly 5 photos required to submit
  bool get canSubmit => _selectedImages.length == 5;

  PhotoUploadViewModel({required this.uuid, this.isPet});

  // ── Init ────────────────────────────────────────────────────────────
  void init() {
  }

  // ── PICK FROM CAMERA ────────────────────────────────────────────────
  Future<void> pickFromCamera() async {
    if (isBusy) return;
    if (_selectedImages.length >= 5) {
      _dialogService.showDialog(
        title: '5 Photos Already Selected',
        description: 'You have already selected 5 photos. Remove a photo before adding a new one.',
      );
      return;
    }
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1280,
        maxHeight: 1280,
      );
      if (image == null) return;
      _selectedImages.add(image);
      notifyListeners();
    } catch (e) {
      _dialogService.showDialog(
        title: 'Camera Unavailable',
        description: 'Unable to open camera. Please check camera permissions and try again.',
      );
    }
  }

  // ── PICK FROM GALLERY ───────────────────────────────────────────────
  Future<void> pickFromGallery() async {
    if (isBusy) return;
    try {
      final picker = ImagePicker();
      final images = await picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1280,
        maxHeight: 1280,
      );
      if (images.isEmpty) return;

      final slotsAvailable = 5 - _selectedImages.length;
      if (slotsAvailable <= 0) {
        _dialogService.showDialog(
          title: '5 Photos Already Selected',
          description: 'You have already selected 5 photos. Remove a photo before adding a new one.',
        );
        return;
      }

      _selectedImages.addAll(images.take(slotsAvailable));

      final skipped = images.length - slotsAvailable;
      if (skipped > 0) {
        _dialogService.showDialog(
          title: 'Some Photos Skipped',
          description: '$skipped photo(s) were skipped. You can only upload 5 in total.',
        );
      }

      notifyListeners();
    } catch (e) {
      _dialogService.showDialog(
        title: 'Gallery Unavailable',
        description: 'Unable to open gallery. Please check storage permissions and try again.',
      );
    }
  }

  // ── REMOVE ONE IMAGE ────────────────────────────────────────────────
  void removeImage(int index) {
    if (index < 0 || index >= _selectedImages.length) return;
    _selectedImages.removeAt(index);
    notifyListeners();
  }

  // ── CLEAR ALL IMAGES ────────────────────────────────────────────────
  void clearAllImages() {
    _selectedImages.clear();
    notifyListeners();
  }

  // ── UPLOAD & SUBMIT ─────────────────────────────────────────────────
  //
  // Backend endpoints:
  //   POST /v1/pashudhan/{pashudhanUuid}/visuals  (livestock)
  //   POST /v1/pets/{petUuid}/visuals             (pet)
  //
  // For Associate Registration (uuid is empty), there is NO backend
  // endpoint for associate profile photos yet. Photos are saved locally
  // and the associate is sent to ApprovalPendingView immediately.
  // ⚠️ BACKEND BLOCKER: Request /v1/associate/{id}/visuals endpoint.
  //
  Future<void> uploadPhotos() async {
    if (!canSubmit) {
      _dialogService.showDialog(
        title: 'Photos Required',
        description:
            'Please select exactly 5 photos before submitting. You currently have ${_selectedImages.length}.',
      );
      return;
    }

    if (isBusy) return;
    setBusy(true);

    try {
      if (isAssociate) {
        // ── Load pending registration data saved by RegistrationViewModel ──
        final userName  = await _storage.getCustomData('pending_assoc_userName');
        final fullName  = await _storage.getCustomData('pending_assoc_fullName');
        final idNo      = await _storage.getCustomData('pending_assoc_idNo');
        final partnerIdStr = await _storage.getCustomData('pending_assoc_partnerId');

        if (userName == null || fullName == null || idNo == null || partnerIdStr == null) {
          _dialogService.showDialog(
            title: 'Registration Error',
            description: 'Missing registration data. Please go back and fill in the form again.',
          );
          return;
        }

        final partnerId = int.tryParse(partnerIdStr);
        if (partnerId == null) {
          _dialogService.showDialog(
            title: 'Registration Error',
            description: 'Invalid partner selection. Please go back and try again.',
          );
          return;
        }

        // 🔥 DEBUG: Verify OTP token is present BEFORE calling POST /v1/associate
        final otpToken = await _storage.getOtpToken();
        // ignore: avoid_print
        print('🔥 OTP TOKEN BEFORE API: $otpToken');
        if (otpToken == null || otpToken.isEmpty) {
          _dialogService.showDialog(
            title: 'Session Error',
            description: 'OTP verification token is missing. Please go back and verify your phone number again.',
          );
          return;
        }

        // ── Call POST /v1/associate (uses OTP token via ApiClientService) ──
        final res = await _associateRepo.createAssociate(
          CreateAssociateRequest(
            userName: userName,
            fullName: fullName,
            partnerId: partnerId,
            idNo: idNo,
          ),
        );

        // Persist associate profile data
        await _storage.saveCustomData('user_id', res.id.toString());
        await _storage.saveCustomData('user_role', 'ASSOCIATE');
        await _storage.saveCustomData('user_name', fullName);
        if (res.partnerType != null) {
          await _storage.saveCustomData('partner_type', res.partnerType!);
        }

        // Clean up temp keys
        await _storage.deleteCustomData('pending_assoc_userName');
        await _storage.deleteCustomData('pending_assoc_fullName');
        await _storage.deleteCustomData('pending_assoc_idNo');
        await _storage.deleteCustomData('pending_assoc_partnerId');

        // Navigate to approval pending screen and stop — do NOT fall through
        _navigationService.clearStackAndShow(Routes.approvalPendingView);
        return;
      } else {
        // Upload each photo to the correct livestock or pet endpoint
        for (final file in _selectedImages) {
          final bytes = await file.readAsBytes();
          if (isPet == true) {
            await _petRepo.uploadVisual(uuid, bytes, file.name);
          } else if (isPet == false) {
            await _pashudhanRepo.uploadVisual(uuid, bytes, file.name);
          }
        }
      }

      // Livestock/Pet registrations return to the dashboard
      if (isPet == true) {
        _navigationService.clearStackAndShow(Routes.homePetOwnerAssociate);
      } else {
        _navigationService.clearStackAndShow(Routes.homeLivestockAssociate);
      }
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      String message;
      switch (status) {
        case 400:
          message = 'One or more photos could not be accepted. Please try different photos.';
          break;
        case 401:
          message = 'Your session has expired. Please log in again.';
          break;
        case 403:
          message = 'You do not have permission to upload photos at this time.';
          break;
        case 404:
          message = 'Upload destination not found. Please contact support.';
          break;
        case 413:
          message = 'One or more photos are too large. Please use images under 5 MB each.';
          break;
        case 500:
          message = 'Server error while uploading. Please try again in a moment.';
          break;
        case 503:
          message = 'Service temporarily unavailable. Please try again shortly.';
          break;
        default:
          final data = e.response?.data;
          message = (data is Map && data['message'] != null)
              ? data['message'].toString()
              : 'Upload failed. Please check your connection and try again.';
      }
      _dialogService.showDialog(title: 'Upload Failed', description: message);
    } catch (e) {
      _dialogService.showDialog(
        title: 'Upload Failed',
        description: 'Something unexpected happened. Please try again.',
      );
    } finally {
      setBusy(false);
    }
  }
}
