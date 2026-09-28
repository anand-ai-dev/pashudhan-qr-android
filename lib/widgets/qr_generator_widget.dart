import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Generates a QR code locally (no API call).
/// [data] must be the plain earTagId string — e.g. "ET123456789".
/// No JSON, no encoding.
class QRGeneratorWidget extends StatelessWidget {
  final String data;
  final double size;
  final Color foregroundColor;
  final Color backgroundColor;

  const QRGeneratorWidget({
    super.key,
    required this.data,
    this.size = 100,
    this.foregroundColor = const Color(0xFF452B14),
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    // Guard: never render an empty QR
    if (data.trim().isEmpty) {
      return SizedBox(
        width: size,
        height: size,
        child: const Center(
          child: Icon(Icons.qr_code_2_rounded, color: Colors.grey),
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      color: backgroundColor,
      padding: const EdgeInsets.all(4),
      child: QrImageView(
        // ✅ Plain earTagId — no JSON, no encoding
        data: data,
        version: QrVersions.auto,
        eyeStyle: QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: foregroundColor,
        ),
        dataModuleStyle: QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: foregroundColor,
        ),
        backgroundColor: backgroundColor,
      ),
    );
  }
}
