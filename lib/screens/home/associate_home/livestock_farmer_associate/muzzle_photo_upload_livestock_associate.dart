import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pashudhan_qr/app/app.locator.dart';
import 'package:pashudhan_qr/models/pashudhan_model.dart';
import 'package:pashudhan_qr/repository/pashudhan_repository.dart';
import 'package:pashudhan_qr/screens/home/customer_home/livestock_farmer/routes/scan_muzzle_screen.dart';

class MuzzlePhotoUploadLivestockAssociate extends StatefulWidget {
  final Pashudhan pashudhan;

  const MuzzlePhotoUploadLivestockAssociate({
    super.key,
    required this.pashudhan,
  });

  @override
  State<MuzzlePhotoUploadLivestockAssociate> createState() =>
      _MuzzlePhotoUploadLivestockAssociateState();
}

class _MuzzlePhotoUploadLivestockAssociateState
    extends State<MuzzlePhotoUploadLivestockAssociate> {
  static const Color primaryYellow = Color(0xFFEDC93A);
  static const Color primaryGreen = Color(0xFFA1BC2A);
  static const Color darkBrown = Color(0xFF452B14);
  static const Color buttonYellow = Color(0xFFF3D133);

  final _repository = locator<PashudhanRepository>();
  final List<File> _photos = [];
  bool _isUploading = false;

  Future<void> _scanPhoto() async {
    final file = await Navigator.push<File?>(
      context,
      MaterialPageRoute(builder: (_) => const ScanMuzzleScreen()),
    );

    if (file == null) return;
    setState(() => _photos.add(file));
  }

  Future<void> _uploadPhotos() async {
    if (_photos.length < 3) {
      _showMessage('Please capture at least 3 good muzzle photos.');
      return;
    }

    setState(() => _isUploading = true);
    try {
      // Phase 1: Upload all visuals first (fast — local disk write on backend)
      final List<(List<int>, String)> uploadedFiles = [];
      for (var i = 0; i < _photos.length; i++) {
        final file = _photos[i];
        final bytes = await file.readAsBytes();
        final fileName = 'muzzle_${widget.pashudhan.earTagNumber}_${i + 1}.jpg';

        await _repository.uploadVisual(
          widget.pashudhan.uuid,
          bytes,
          fileName,
        );
        uploadedFiles.add((bytes, fileName));
      }

      // Phase 2: Register muzzle embeddings with ML backend
      // Done separately so visual upload 503s are not caused by slow ML calls.
      int registeredCount = 0;
      for (final (bytes, fileName) in uploadedFiles) {
        try {
          await _repository.registerMuzzle(
            widget.pashudhan.uuid,
            bytes,
            fileName,
          );
          registeredCount++;
        } on DioException catch (e) {
          // Log but don't abort — partial registration is better than none
          if (e.response?.statusCode == 502) {
            _showMessage(
              'Muzzle detection service is unavailable. Photos saved; registration will be retried later.',
            );
            break;
          }
        }
      }

      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Success'),
          content: Text(
            '${_photos.length} muzzle photos uploaded for ${widget.pashudhan.name}.'
            '${registeredCount > 0 ? '\n$registeredCount photo(s) registered for biometric ID.' : ''}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        _showMessage(
          'Upload is not allowed for associate on this backend. Please deploy the updated backend and try again.',
        );
      } else if (e.response?.statusCode == 503) {
        _showMessage(
          'Server is temporarily busy. Please wait a moment and try again.',
        );
      } else if (e.response?.statusCode == 502) {
        _showMessage(
          'Muzzle detection service is currently unavailable. Please try again later or contact support.',
        );
      } else {
        _showMessage('Photo upload failed (${e.response?.statusCode ?? 'unknown error'}). Please try again.');
      }
    } catch (_) {
      _showMessage('Photo upload failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: primaryGreen,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: primaryGreen,
            image: DecorationImage(
              image: AssetImage('assets/pattern_bg.png'),
              repeat: ImageRepeat.repeat,
              opacity: 0.15,
            ),
          ),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTitleCard('SCAN MUZZLE PHOTOS'),
                      const SizedBox(height: 14),
                      _buildInfoCard(),
                      const SizedBox(height: 14),
                      _buildPhotoGrid(),
                      const SizedBox(height: 16),
                      _buildButton(
                        Icons.camera_alt_rounded,
                        'SCAN MUZZLE PHOTO',
                        darkBrown,
                        primaryYellow,
                        _isUploading ? null : _scanPhoto,
                      ),
                      const SizedBox(height: 12),
                      _buildButton(
                        Icons.cloud_upload_rounded,
                        _isUploading ? 'UPLOADING...' : 'UPLOAD PHOTOS',
                        buttonYellow,
                        darkBrown,
                        _isUploading ? null : _uploadPhotos,
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _isUploading
                            ? null
                            : () => Navigator.of(context)
                                .popUntil((route) => route.isFirst),
                        child: const Text(
                          'SKIP FOR NOW',
                          style: TextStyle(
                            color: darkBrown,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: const BoxDecoration(
        color: primaryYellow,
        border: Border(bottom: BorderSide(color: darkBrown, width: 3)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded,
                color: darkBrown, size: 28),
            onPressed: _isUploading ? null : () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Muzzle Photos',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: darkBrown,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildTitleCard(String title) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: darkBrown,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primaryYellow, width: 4),
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            color: primaryYellow,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: primaryYellow.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: darkBrown, width: 3),
      ),
      child: Text(
        'Capture at least 3 clear muzzle photos for ${widget.pashudhan.name}. These photos will be uploaded to the livestock visuals API.',
        style: const TextStyle(
          color: darkBrown,
          fontSize: 14,
          fontWeight: FontWeight.w800,
          height: 1.3,
        ),
      ),
    );
  }

  Widget _buildPhotoGrid() {
    if (_photos.isEmpty) {
      return Container(
        height: 160,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFEDEDED),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: darkBrown, width: 4),
        ),
        child: const Text(
          'No muzzle photos captured yet',
          style: TextStyle(color: darkBrown, fontWeight: FontWeight.w800),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _photos.length,
      itemBuilder: (context, index) {
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(_photos[index], fit: BoxFit.cover),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: _isUploading
                    ? null
                    : () => setState(() => _photos.removeAt(index)),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildButton(
    IconData icon,
    String label,
    Color background,
    Color foreground,
    VoidCallback? onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: foreground, width: 4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: foreground),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: foreground,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
