import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

/// In-app muzzle scanner — camera preview in a viewfinder (like PhonePe/GPay).
/// The `camera` package handles the OS permission dialog automatically.
/// No extra permission plugin needed.
class ScanMuzzleScreen extends StatefulWidget {
  const ScanMuzzleScreen({super.key});

  @override
  State<ScanMuzzleScreen> createState() => _ScanMuzzleScreenState();
}

class _ScanMuzzleScreenState extends State<ScanMuzzleScreen>
    with WidgetsBindingObserver {
  static const Color primaryYellow = Color(0xFFEDC93A);
  static const Color primaryGreen = Color(0xFFA1BC2A);
  static const Color darkBrown = Color(0xFF452B14);
  static const Color buttonYellow = Color(0xFFF3D133);

  CameraController? _controller;
  bool _isCameraReady = false;
  bool _isCameraError = false;
  String _errorMessage = '';
  File? _capturedImage;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startCamera();
  }

  // ═══════════════════════════════════════════════════════════════════
  //  CAMERA — the camera package auto-triggers permission dialog
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _startCamera() async {
    setState(() {
      _isCameraReady = false;
      _isCameraError = false;
    });

    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        _setError('No camera found on this device.');
        return;
      }

      // Pick back camera
      final cam = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _controller =
          CameraController(cam, ResolutionPreset.high, enableAudio: false);

      // This call triggers the OS permission dialog automatically
      await _controller!.initialize();

      if (mounted) setState(() => _isCameraReady = true);
    } on CameraException catch (e) {
      // Permission denied or camera error
      if (e.code == 'CameraAccessDenied' ||
          e.code == 'CameraAccessDeniedWithoutPrompt') {
        _setError(
            'Camera permission denied.\nPlease allow camera access in your phone Settings > Apps > Pashudhan QR > Permissions.');
      } else {
        _setError('Camera error: ${e.description ?? "Unknown error"}');
      }
    } catch (e) {
      _setError('Could not start camera. Please try again.');
    }
  }

  void _setError(String msg) {
    if (mounted) {
      setState(() {
        _isCameraError = true;
        _errorMessage = msg;
        _isCameraReady = false;
      });
    }
  }

  Future<void> _capturePhoto() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isCapturing) {
      return;
    }

    setState(() => _isCapturing = true);

    try {
      final XFile file = await _controller!.takePicture();
      if (mounted) {
        setState(() {
          _capturedImage = File(file.path);
          _isCapturing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCapturing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to capture photo. Please try again.'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _retakePhoto() => setState(() => _capturedImage = null);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isCameraError) {
      // User might have granted permission in Settings — retry
      _startCamera();
    } else if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
      _controller = null;
      if (mounted) setState(() => _isCameraReady = false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════
  //  BUILD
  // ═══════════════════════════════════════════════════════════════════

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
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      _buildTitleCard('MUZZLE SCANNER'),
                      const SizedBox(height: 16),
                      _buildInstructionCard(),
                      const SizedBox(height: 16),
                      _buildViewfinder(),
                      const SizedBox(height: 16),
                      _buildActionButtons(),
                      const SizedBox(height: 24),
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

  // ═══════════════════════════════════════════════════════════════════
  //  APP BAR
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildAppBar() {
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
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Scan Pashudhan Muzzle',
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

  // ═══════════════════════════════════════════════════════════════════
  //  TITLE CARD
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildTitleCard(String title) {
    return Container(
      height: 56,
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
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  INSTRUCTION CARD
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildInstructionCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: primaryYellow.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: darkBrown, width: 2.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: darkBrown, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _capturedImage != null
                  ? 'Muzzle photo captured! You can retake or go back.'
                  : _isCameraError
                      ? 'Camera access is needed to scan muzzle.'
                      : 'Place the pashudhan muzzle inside the frame and tap capture.',
              style: const TextStyle(
                color: darkBrown,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  CAMERA VIEWFINDER
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildViewfinder() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: darkBrown, width: 4),
        boxShadow: [
          BoxShadow(
            color: darkBrown.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: _buildViewfinderContent(),
        ),
      ),
    );
  }

  Widget _buildViewfinderContent() {
    // ── Captured photo ──
    if (_capturedImage != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.file(_capturedImage!, fit: BoxFit.cover),
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Muzzle Captured ✓',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    // ── Error / permission denied ──
    if (_isCameraError) {
      return Container(
        color: darkBrown,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.camera_alt_rounded,
                    color: primaryYellow, size: 48),
                const SizedBox(height: 12),
                Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: primaryYellow,
                      fontSize: 14,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _startCamera,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 12),
                    decoration: BoxDecoration(
                      color: buttonYellow,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: darkBrown, width: 2),
                    ),
                    child: const Text(
                      'TRY AGAIN',
                      style: TextStyle(
                          color: darkBrown,
                          fontWeight: FontWeight.w900,
                          fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ── Loading camera ──
    if (!_isCameraReady || _controller == null) {
      return Container(
        color: darkBrown,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: primaryYellow, strokeWidth: 3),
              SizedBox(height: 12),
              Text(
                'Starting camera...',
                style: TextStyle(
                    color: primaryYellow,
                    fontSize: 14,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      );
    }

    // ── Live camera preview with scanner overlay ──
    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(_controller!),
        CustomPaint(painter: _ScannerOverlayPainter()),
        const Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              'Align muzzle within the frame',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  ACTION BUTTONS
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildActionButtons() {
    if (_capturedImage != null) {
      return Row(
        children: [
          Expanded(
            child: _buildBtn(
                Icons.refresh_rounded, 'RETAKE', buttonYellow, _retakePhoto),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildBtn(
              Icons.check_rounded,
              'DONE',
              primaryGreen,
              () => Navigator.pop(context, _capturedImage),
            ),
          ),
        ],
      );
    }

    // Capture button
    final canCapture = _isCameraReady && !_isCapturing && !_isCameraError;

    return GestureDetector(
      onTap: canCapture ? _capturePhoto : null,
      child: Opacity(
        opacity: canCapture ? 1.0 : 0.4,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: darkBrown,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primaryYellow, width: 4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isCapturing
                    ? Icons.hourglass_top_rounded
                    : Icons.camera_alt_rounded,
                color: primaryYellow,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                _isCapturing ? 'CAPTURING...' : 'CAPTURE MUZZLE',
                style: const TextStyle(
                    color: primaryYellow,
                    fontSize: 18,
                    fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBtn(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: darkBrown, width: 3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: darkBrown, size: 20),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    color: darkBrown,
                    fontSize: 16,
                    fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  SCANNER OVERLAY — corner brackets like PhonePe/GPay
// ═══════════════════════════════════════════════════════════════════
class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final scanRect = Rect.fromLTRB(w * 0.1, h * 0.15, w * 0.9, h * 0.85);

    final bgPaint = Paint()..color = Colors.black.withValues(alpha: 0.45);
    canvas.drawRect(Rect.fromLTRB(0, 0, w, scanRect.top), bgPaint);
    canvas.drawRect(Rect.fromLTRB(0, scanRect.bottom, w, h), bgPaint);
    canvas.drawRect(
        Rect.fromLTRB(0, scanRect.top, scanRect.left, scanRect.bottom),
        bgPaint);
    canvas.drawRect(
        Rect.fromLTRB(scanRect.right, scanRect.top, w, scanRect.bottom),
        bgPaint);

    final cp = Paint()
      ..color = const Color(0xFFEDC93A)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const double cl = 30;

    canvas.drawLine(Offset(scanRect.left, scanRect.top + cl),
        Offset(scanRect.left, scanRect.top), cp);
    canvas.drawLine(Offset(scanRect.left, scanRect.top),
        Offset(scanRect.left + cl, scanRect.top), cp);

    canvas.drawLine(Offset(scanRect.right - cl, scanRect.top),
        Offset(scanRect.right, scanRect.top), cp);
    canvas.drawLine(Offset(scanRect.right, scanRect.top),
        Offset(scanRect.right, scanRect.top + cl), cp);

    canvas.drawLine(Offset(scanRect.left, scanRect.bottom - cl),
        Offset(scanRect.left, scanRect.bottom), cp);
    canvas.drawLine(Offset(scanRect.left, scanRect.bottom),
        Offset(scanRect.left + cl, scanRect.bottom), cp);

    canvas.drawLine(Offset(scanRect.right - cl, scanRect.bottom),
        Offset(scanRect.right, scanRect.bottom), cp);
    canvas.drawLine(Offset(scanRect.right, scanRect.bottom),
        Offset(scanRect.right, scanRect.bottom - cl), cp);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
