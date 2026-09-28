import 'package:flutter/material.dart';
import 'package:pashudhan_qr/app/app.locator.dart';
import 'package:pashudhan_qr/models/pashudhan_model.dart';
import 'package:pashudhan_qr/services/api_client_service.dart';
import 'package:pashudhan_qr/widgets/photo_gallery_view.dart';
import 'package:pashudhan_qr/widgets/qr_generator_widget.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class LivestockDetailsAssociateView extends StatefulWidget {
  final Pashudhan pashudhan;

  const LivestockDetailsAssociateView({super.key, required this.pashudhan});

  @override
  State<LivestockDetailsAssociateView> createState() => _LivestockDetailsAssociateViewState();
}

class _LivestockDetailsAssociateViewState extends State<LivestockDetailsAssociateView> {
  static const Color primaryYellow = Color(0xFFEDC93A);
  static const Color primaryGreen = Color(0xFFA1BC2A);
  static const Color darkBrown = Color(0xFF452B14);

  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isProcessing = false;

  List<String> get _imageUrls {
    final baseUrl = locator<ApiClientService>().baseUrl;
    return widget.pashudhan.visuals
        .map((id) => '$baseUrl/v1/pashudhan/${widget.pashudhan.uuid}/visuals/$id')
        .toList();
  }

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
      final file = File('${directory.path}/livestock_report_${widget.pashudhan.earTagNumber}.png');
      await file.writeAsBytes(image);

      if (isShare) {
        await Share.shareXFiles([XFile(file.path)], text: 'Livestock Report for ${widget.pashudhan.name}');
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
    final imageUrls = _imageUrls;
    return Scaffold(
      backgroundColor: primaryGreen,
      appBar: AppBar(
        backgroundColor: darkBrown,
        title: const Text('Livestock Full Report (Associate)', style: TextStyle(color: primaryYellow)),
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
                if (imageUrls.isNotEmpty) ...[
                  _buildPhotoStrip(context, imageUrls),
                  const SizedBox(height: 16),
                ],
                Center(
                  child: Container(
                    decoration: BoxDecoration(border: Border.all(color: darkBrown, width: 4)),
                    padding: const EdgeInsets.all(8),
                    child: QRGeneratorWidget(data: widget.pashudhan.earTagNumber, size: 150),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('PASHUDHAN DETAILS', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkBrown)),
                const Divider(color: darkBrown, thickness: 2),
                const SizedBox(height: 16),
                _buildRow('Category', widget.pashudhan.category),
                _buildRow('Name', widget.pashudhan.name),
                _buildRow('Gender', widget.pashudhan.displayGender),
                _buildRow('Breed', widget.pashudhan.breed),
                _buildRow('Ear Tag Number', widget.pashudhan.earTagNumber),
                _buildRow('Lactation Number', widget.pashudhan.lactationNumber.toString()),
                _buildRow('Weight', '${widget.pashudhan.weight} kg'),
                _buildRow('Age in Months', widget.pashudhan.ageInMonths.toString()),
                _buildRow('Age Recorded At', widget.pashudhan.ageRecordedAt),
                _buildRow('Owner ID', widget.pashudhan.ownerId.toString()),
                const SizedBox(height: 24),
                const Text('OWNER DETAILS', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkBrown)),
                const Divider(color: darkBrown, thickness: 2),
                const SizedBox(height: 16),
                _buildRow('Name', widget.pashudhan.ownerName ?? 'N/A'),
                _buildRow('Phone Number', widget.pashudhan.ownerPhone ?? 'N/A'),
                _buildRow('Location', widget.pashudhan.ownerLocation ?? 'N/A'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoStrip(BuildContext context, List<String> imageUrls) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Photos', style: TextStyle(fontWeight: FontWeight.bold, color: darkBrown, fontSize: 16)),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PhotoGalleryView(imageUrls: imageUrls)),
              ),
              child: const Text('View All', style: TextStyle(color: Color(0xFF678122), fontWeight: FontWeight.w700, fontSize: 14)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: imageUrls.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) => GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PhotoGalleryView(imageUrls: imageUrls)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrls[index],
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
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
