import 'dart:io';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'photo_upload_viewmodel.dart';

class PhotoUploadView extends StackedView<PhotoUploadViewModel> {
  final String uuid;
  final bool? isPet;

  const PhotoUploadView({
    super.key,
    required this.uuid,
    this.isPet,
  });

  static const Color primaryYellow = Color(0xFFEDC93A);
  static const Color primaryGreen = Color(0xFFA1BC2A);
  static const Color darkBrown = Color(0xFF452B14);
  static const Color buttonYellow = Color(0xFFF3D133);

  @override
  void onViewModelReady(PhotoUploadViewModel viewModel) {
    viewModel.init();
  }

  /// Shows a bottom sheet for Camera / Gallery source selection
  void _showSourcePicker(BuildContext context, PhotoUploadViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 42,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const Text(
              'Add Photo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: darkBrown,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Camera option
                _buildSourceTile(
                  context: context,
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    viewModel.pickFromCamera();
                  },
                ),
                // Gallery option
                _buildSourceTile(
                  context: context,
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    viewModel.pickFromGallery();
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: primaryGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primaryGreen, width: 2),
            ),
            child: Icon(icon, size: 36, color: darkBrown),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: darkBrown,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget builder(BuildContext context, PhotoUploadViewModel viewModel, Widget? child) {
    final typeName = isPet == true ? 'Pet' : (isPet == false ? 'Livestock' : 'Associate');
    final photoCount = viewModel.selectedImages.length;

    return SafeArea(
      child: Scaffold(
        backgroundColor: primaryGreen,
        appBar: AppBar(
          backgroundColor: darkBrown,
          title: Text(
            'UPLOAD $typeName PHOTOS',
            style: const TextStyle(color: primaryYellow, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: primaryYellow),
        ),
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 12),

                // ── Photo count badge ───────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: darkBrown.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.photo_library, color: primaryYellow, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '$photoCount / 5 photos selected',
                        style: const TextStyle(
                          color: primaryYellow,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // ── Progress bar ─────────────────────────────────────
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: photoCount / 5,
                    minHeight: 8,
                    backgroundColor: Colors.white30,
                    color: photoCount == 5 ? Colors.green : primaryYellow,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  photoCount < 5
                      ? 'Select exactly 5 photos of the $typeName to continue.'
                      : '✅ All 5 photos selected. Ready to submit!',
                  style: TextStyle(
                    fontSize: 14,
                    color: photoCount == 5 ? Colors.white : darkBrown,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: photoCount == 0
                      // ── Empty state ─────────────────────────────
                      ? Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.82,
                            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.add_photo_alternate_outlined,
                                    size: 60, color: primaryGreen),
                                const SizedBox(height: 16),
                                const Text(
                                  'No photos selected yet',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: darkBrown,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Tap the button below to pick photos\nfrom your camera or gallery.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF5A6B87),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                GestureDetector(
                                  onTap: viewModel.isBusy
                                      ? null
                                      : () => _showSourcePicker(context, viewModel),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 32, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: buttonYellow,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.upload_rounded, color: darkBrown),
                                        SizedBox(width: 8),
                                        Text(
                                          'Upload Photo',
                                          style: TextStyle(
                                            color: darkBrown,
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )

                      // ── Photo grid ──────────────────────────────
                      : Column(
                          children: [
                            Expanded(
                              child: GridView.builder(
                                itemCount: photoCount,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                                itemBuilder: (context, index) {
                                  return Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(
                                          File(viewModel.selectedImages[index].path),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      // ── Delete (✕) ──
                                      Positioned(
                                        top: 5,
                                        right: 5,
                                        child: GestureDetector(
                                          onTap: viewModel.isBusy
                                              ? null
                                              : () => viewModel.removeImage(index),
                                          child: const CircleAvatar(
                                            radius: 14,
                                            backgroundColor: Colors.white,
                                            child: Icon(Icons.close,
                                                color: Colors.red, size: 18),
                                          ),
                                        ),
                                      ),
                                      // ── Number badge ──
                                      Positioned(
                                        bottom: 5,
                                        left: 5,
                                        child: CircleAvatar(
                                          radius: 12,
                                          backgroundColor:
                                              darkBrown.withValues(alpha: 0.8),
                                          child: Text(
                                            '${index + 1}',
                                            style: const TextStyle(
                                              color: primaryYellow,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 12),

                            // ── CRUD action row ──────────────────
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (photoCount < 5 && !viewModel.isBusy)
                                  _buildIconButton(
                                    icon: Icons.upload_rounded,
                                    label: 'Add More',
                                    onTap: () =>
                                        _showSourcePicker(context, viewModel),
                                  ),
                                if (photoCount > 0 && !viewModel.isBusy) ...[
                                  const SizedBox(width: 12),
                                  _buildIconButton(
                                    icon: Icons.delete_sweep,
                                    label: 'Clear All',
                                    onTap: () => viewModel.clearAllImages(),
                                    danger: true,
                                  ),
                                ],
                              ],
                            ),

                            const SizedBox(height: 16),

                            // ── Submit button ────────────────────
                            if (viewModel.isBusy)
                              const Column(
                                children: [
                                  CircularProgressIndicator(color: darkBrown),
                                  SizedBox(height: 8),
                                  Text(
                                    'Uploading photos, please wait…',
                                    style: TextStyle(
                                      color: darkBrown,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            else
                              Opacity(
                                opacity: viewModel.canSubmit ? 1.0 : 0.45,
                                child: _buildSubmitButton(
                                  viewModel.canSubmit
                                      ? () => viewModel.uploadPhotos()
                                      : null,
                                ),
                              ),
                          ],
                        ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        width: 220,
        decoration: BoxDecoration(
          color: buttonYellow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: darkBrown, width: 4),
        ),
        child: const Center(
          child: Text(
            'SUBMIT PHOTOS >',
            style: TextStyle(
              color: darkBrown,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool danger = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: danger ? Colors.red.shade600 : darkBrown,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: primaryYellow, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: primaryYellow,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  PhotoUploadViewModel viewModelBuilder(BuildContext context) =>
      PhotoUploadViewModel(uuid: uuid, isPet: isPet);
}
