import 'package:flutter/material.dart';
import 'package:pashudhan_qr/models/pet_model.dart';
import 'package:pashudhan_qr/widgets/qr_generator_widget.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class PetFullReportScreen extends StatefulWidget {
  final Pet pet;

  const PetFullReportScreen({super.key, required this.pet});

  @override
  State<PetFullReportScreen> createState() => _PetFullReportScreenState();
}

class _PetFullReportScreenState extends State<PetFullReportScreen> {
  static const Color primaryYellow = Color(0xFFEDC93A);
  static const Color primaryGreen = Color(0xFFA1BC2A);
  static const Color darkBrown = Color(0xFF452B14);

  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isProcessing = false;

  Future<void> _downloadOrShare(bool isShare) async {
    setState(() => _isProcessing = true);
    try {
      final image = await _screenshotController.capture(delay: const Duration(milliseconds: 10));
      if (image == null) throw Exception("Failed to capture screen");

      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }
      
      if (directory == null) throw Exception("Could not access storage directory");
      final file = File('${directory.path}/pet_report_${widget.pet.petIdNumber}.png');
      await file.writeAsBytes(image);

      if (isShare) {
        await Share.shareXFiles([XFile(file.path)], text: 'Pet Report for ${widget.pet.name}');
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Report saved to ${file.path}'), backgroundColor: darkBrown),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryGreen,
      appBar: AppBar(
        backgroundColor: darkBrown,
        title: const Text('Pet Full Report', style: TextStyle(color: primaryYellow)),
        iconTheme: const IconThemeData(color: primaryYellow),
        actions: [
          if (_isProcessing)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: primaryYellow, strokeWidth: 2)),
            )
          else ...[
            IconButton(icon: const Icon(Icons.download), onPressed: () => _downloadOrShare(false)),
            IconButton(icon: const Icon(Icons.share), onPressed: () => _downloadOrShare(true)),
          ]
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Screenshot(
          controller: _screenshotController,
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    decoration: BoxDecoration(border: Border.all(color: darkBrown, width: 4)),
                    padding: const EdgeInsets.all(8),
                    child: QRGeneratorWidget(data: widget.pet.petIdNumber, size: 150),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('PET DETAILS', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkBrown)),
                const Divider(color: darkBrown, thickness: 2),
                const SizedBox(height: 16),
                _buildRow('Category', widget.pet.category),
                _buildRow('Name', widget.pet.name),
                _buildRow('Gender', widget.pet.displayGender),
                _buildRow('Age', widget.pet.displayAge),
                _buildRow('Breed', widget.pet.breed),
                _buildRow('Pet ID Number', widget.pet.petIdNumber),
                _buildRow('Weight', '${widget.pet.weight} kg'),
                _buildRow('Height', '${widget.pet.heightInCms} cm'),
                const SizedBox(height: 24),
                const Text('OWNER DETAILS', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkBrown)),
                const Divider(color: darkBrown, thickness: 2),
                const SizedBox(height: 16),
                _buildRow('Owner Name', widget.pet.ownerName ?? 'NA'),
                _buildRow('Phone', widget.pet.ownerPhone ?? 'NA'),
                _buildRow('Location', widget.pet.ownerLocation ?? 'NA'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: darkBrown, fontSize: 16))),
          const Text(' : ', style: TextStyle(fontWeight: FontWeight.bold, color: darkBrown, fontSize: 16)),
          Expanded(flex: 3, child: Text(value.isEmpty ? 'N/A' : value, style: const TextStyle(color: Colors.black87, fontSize: 16))),
        ],
      ),
    );
  }
}
