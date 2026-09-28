import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:pashudhan_qr/models/pashudhan_model.dart';
import 'package:pashudhan_qr/widgets/qr_generator_widget.dart';
import 'package:screenshot/screenshot.dart';
import 'pashudhan_card_livestock_viewmodel.dart';

class PashudhanCardLivestock
    extends StackedView<PashudhanCardLivestockViewModel> {
  const PashudhanCardLivestock({super.key});

  static const Color primaryYellow = Color(0xFFEDC93A);
  static const Color primaryGreen = Color(0xFFA1BC2A);
  static const Color darkBrown = Color(0xFF452B14);
  static const Color accentGreen = Color(0xFF678122);

  @override
  Widget builder(
    BuildContext context,
    PashudhanCardLivestockViewModel viewModel,
    Widget? child,
  ) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: primaryGreen,
        body: SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 159, 186, 42),
              image: DecorationImage(
                image: AssetImage('assets/pattern_bg.png'),
                repeat: ImageRepeat.repeat,
                opacity: 0.12,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Title bar ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    decoration: BoxDecoration(
                      color: darkBrown,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: primaryYellow, width: 2.5),
                    ),
                    child: const Center(
                      child: Text(
                        'PASHUDHANQR CARD OF LIVESTOCK',
                        style: TextStyle(
                          color: primaryYellow,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Card List ───────────────────────────────────────
                Expanded(
                  child: viewModel.isBusy
                      ? const Center(
                          child: CircularProgressIndicator(color: darkBrown),
                        )
                      : viewModel.errorMessage != null
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.error_outline,
                                      color: darkBrown, size: 48),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24),
                                    child: Text(
                                      viewModel.errorMessage!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: darkBrown,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    onPressed: viewModel.refresh,
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            )
                          : viewModel.pashudhanList.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No livestock registered yet.',
                                    style: TextStyle(
                                        color: darkBrown,
                                        fontWeight: FontWeight.w700),
                                  ),
                                )
                              : ListView.separated(
                                  padding:
                                      const EdgeInsets.fromLTRB(14, 0, 14, 24),
                                  itemCount: viewModel.pashudhanList.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 10),
                                  itemBuilder: (context, index) {
                                    return RepaintBoundary(
                                      child: _buildQrCard(
                                        context,
                                        viewModel.pashudhanList[index],
                                        index,
                                        viewModel,
                                      ),
                                    );
                                  },
                                ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── QR Card (matches reference image design) ─────────────────────────────
  Widget _buildQrCard(
    BuildContext context,
    Pashudhan cardData,
    int index,
    PashudhanCardLivestockViewModel viewModel,
  ) {
    final id = cardData.earTagNumber.isNotEmpty
        ? cardData.earTagNumber
        : cardData.uuid.isNotEmpty
            ? cardData.uuid
            : 'unknown';
    final qrData = id;

    return Screenshot(
        controller: viewModel.getScreenshotController(index),
        child: Container(
          decoration: BoxDecoration(
            color: primaryYellow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: darkBrown, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(40),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Row 1: Download | PashuDhanQR CARD | Sync + Share ──
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
                child: Row(
                  children: [
                    // Download circle button
                    GestureDetector(
                      onTap: () => viewModel.downloadQr(index, context),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          color: darkBrown,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.file_download_outlined,
                          color: primaryYellow,
                          size: 20,
                        ),
                      ),
                    ),

                    // "PashuDhanQR CARD" title
                    Expanded(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'PashuDhan',
                              style: TextStyle(
                                color: accentGreen,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            TextSpan(
                              text: 'QR',
                              style: TextStyle(
                                color: darkBrown,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            TextSpan(
                              text: ' CARD',
                              style: TextStyle(
                                color: accentGreen,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Sync icon
                    GestureDetector(
                      onTap: () => viewModel.syncQr(index),
                      child: const Icon(
                        Icons.change_circle_outlined,
                        color: accentGreen,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Share icon
                    GestureDetector(
                      onTap: () => viewModel.shareQr(index, context),
                      child: const Icon(
                        Icons.share_outlined,
                        color: darkBrown,
                        size: 26,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Row 2: Illustration & Slogan (left) + QR (right) ──
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // LEFT: Farmer + animals illustration & Slogan
                    Expanded(
                      flex: 6,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Builder(builder: (_) {
                            final imageUrl = viewModel.getImageUrl(cardData);
                            return imageUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      imageUrl,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Image.asset(
                                        'assets/icons_home/customer/livestock_farmer/livestock_farmer_card.png',
                                        height: 100,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  )
                                : Image.asset(
                                    'assets/icons_home/customer/livestock_farmer/livestock_farmer_card.png',
                                    height: 100,
                                    fit: BoxFit.contain,
                                    alignment: Alignment.bottomCenter,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.image,
                                      size: 80,
                                      color: darkBrown,
                                    ),
                                  );
                          }),
                          const SizedBox(height: 8),
                          const Text(
                            'अब अपने पशुधन की जन्मपत्री अपने हाथ में',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: darkBrown,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // RIGHT: QR code with brown border
                    Expanded(
                      flex: 4,
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: darkBrown, width: 3.5),
                          ),
                          padding: const EdgeInsets.all(6),
                          child: QRGeneratorWidget(
                            data: qrData,
                            foregroundColor: darkBrown,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Row 3: Animal name (left) | Ear tag number (right) ──
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        (cardData.name.isNotEmpty
                            ? cardData.name
                            : 'पशुधन का नाम') + ' (${cardData.displayGender})',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: accentGreen,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        cardData.earTagNumber.isNotEmpty
                            ? cardData.earTagNumber
                            : cardData.uuid.isNotEmpty
                                ? cardData.uuid
                                : 'N/A',
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: accentGreen,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  @override
  PashudhanCardLivestockViewModel viewModelBuilder(BuildContext context) =>
      PashudhanCardLivestockViewModel();

  @override
  void onViewModelReady(PashudhanCardLivestockViewModel viewModel) {
    viewModel.initialize();
    super.onViewModelReady(viewModel);
  }
}
