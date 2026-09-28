import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Full-screen QR scanner.
///
/// Usage:
/// ```dart
/// final earTagId = await Navigator.push<String>(
///   context,
///   MaterialPageRoute(builder: (_) => const QRScannerScreen()),
/// );
/// if (earTagId != null && earTagId.isNotEmpty) { ... }
/// ```
///
/// Returns the scanned string (plain earTagId) via Navigator.pop.
class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  static const Color _primaryYellow = Color(0xFFEDC93A);
  static const Color _darkBrown = Color(0xFF452B14);

  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _hasScanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;

    final barcode = capture.barcodes.firstOrNull;
    final rawValue = barcode?.rawValue;

    if (rawValue == null || rawValue.trim().isEmpty) return;

    final earTagId = rawValue.trim();
    _hasScanned = true;

    // Return the plain earTagId to the caller
    Navigator.of(context).pop(earTagId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: _darkBrown,
        title: const Text(
          'Scan QR Code',
          style: TextStyle(color: _primaryYellow, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: _primaryYellow),
        actions: [
          // Torch toggle
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _controller,
              builder: (_, state, __) {
                final isOn = state.torchState == TorchState.on;
                return Icon(
                  isOn ? Icons.flash_on : Icons.flash_off,
                  color: isOn ? Colors.yellow : _primaryYellow,
                );
              },
            ),
            onPressed: _controller.toggleTorch,
          ),
          // Flip camera
          IconButton(
            icon: const Icon(Icons.flip_camera_ios, color: _primaryYellow),
            onPressed: _controller.switchCamera,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera preview
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          // Scan frame overlay
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(color: _primaryYellow, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // Instruction label
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: _darkBrown.withAlpha(200),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Point the camera at a PashuDhan QR code',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _primaryYellow,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
