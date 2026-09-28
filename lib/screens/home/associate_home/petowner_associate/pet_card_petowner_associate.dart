import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:pashudhan_qr/models/pet_model.dart';
import 'package:pashudhan_qr/widgets/qr_generator_widget.dart';
import 'package:screenshot/screenshot.dart';
import 'pet_card_petowner_associate_viewmodel.dart';

class PetCardPetOwnerAssociate
    extends StackedView<PetCardPetOwnerAssociateViewModel> {
  const PetCardPetOwnerAssociate({super.key});

  static const Color primaryYellow = Color(0xFFEDC93A);
  static const Color primaryGreen = Color(0xFFA1BC2A);
  static const Color darkBrown = Color(0xFF452B14);
  static const Color accentGreen = Color(0xFF678122);

  @override
  Widget builder(
    BuildContext context,
    PetCardPetOwnerAssociateViewModel viewModel,
    Widget? child,
  ) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: primaryGreen,
        body: Container(
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
              _buildAppBar(context),

              // ── Card List ───────────────────────────────────────
              Expanded(
                child: viewModel.isBusy
                    ? const Center(
                        child: CircularProgressIndicator(color: darkBrown),
                      )
                    : viewModel.errorMessage != null
                        ? _buildErrorView(viewModel)
                        : viewModel.petList.isEmpty
                            ? _buildEmptyView()
                            : ListView.separated(
                                padding:
                                    const EdgeInsets.fromLTRB(14, 0, 14, 24),
                                itemCount: viewModel.petList.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  return _buildQrCard(
                                    context,
                                    viewModel.petList[index],
                                    index,
                                    viewModel,
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: darkBrown,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: primaryYellow, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              decoration: BoxDecoration(
                color: darkBrown,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: primaryYellow, width: 2.5),
              ),
              child: const Center(
                child: Text(
                  'ASSOCIATE QR MANAGEMENT',
                  style: TextStyle(
                    color: primaryYellow,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(PetCardPetOwnerAssociateViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: darkBrown, size: 48),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              viewModel.errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: darkBrown, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: viewModel.refresh,
            style: ElevatedButton.styleFrom(
                backgroundColor: darkBrown, foregroundColor: primaryYellow),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return const Center(
      child: Text(
        'No pets registered yet.',
        style: TextStyle(
            color: darkBrown, fontWeight: FontWeight.w700, fontSize: 16),
      ),
    );
  }

  Widget _buildQrCard(
    BuildContext context,
    Pet cardData,
    int index,
    PetCardPetOwnerAssociateViewModel viewModel,
  ) {
    final id = cardData.petIdNumber.isNotEmpty
        ? cardData.petIdNumber
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
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header Row: Actions ──
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
                child: Row(
                  children: [
                    _buildCircleBtn(Icons.edit_note_rounded, accentGreen,
                        () => viewModel.editPet(cardData, context)),
                    const SizedBox(width: 8),
                    _buildCircleBtn(
                        Icons.delete_sweep_rounded,
                        Colors.red.shade800,
                        () => viewModel.deletePet(cardData.petIdNumber)),
                    Expanded(
                      child: Text.rich(
                        const TextSpan(
                          children: [
                            TextSpan(
                              text: 'PashuDhan',
                              style: TextStyle(
                                color: primaryGreen,
                              ),
                            ),
                            TextSpan(
                              text: 'QR',
                              style: TextStyle(
                                color: darkBrown,
                              ),
                            ),
                            TextSpan(
                              text: ' CARD',
                              style: TextStyle(
                                color: primaryGreen,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    _buildCircleBtn(Icons.file_download_outlined, darkBrown,
                        () => viewModel.downloadQr(index, context)),
                    const SizedBox(width: 8),
                    _buildCircleBtn(Icons.share_outlined, darkBrown,
                        () => viewModel.shareQr(index, context)),
                  ],
                ),
              ),

              // ── Main Row: Illustration & QR ──
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 6,
                      child: Column(
                        children: [
                          Builder(builder: (_) {
                            final imageUrl = viewModel.getImageUrl(cardData);
                            return imageUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      imageUrl,
                                      height: 95,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Image.asset(
                                        'assets/icons_home/customer/pet_owner/pet_owner_card.png',
                                        height: 105,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.image,
                                                size: 70, color: darkBrown),
                                      ),
                                    ),
                                  )
                                : Image.asset(
                                    'assets/icons_home/customer/pet_owner/pet_owner_card.png',
                                    height: 120,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Icon(
                                        Icons.image,
                                        size: 70,
                                        color: darkBrown),
                                  );
                          }),
                          const SizedBox(height: 4),
                          const Text(
                            "Now all your pet's records are at your fingertips",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: darkBrown),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 4,
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: darkBrown, width: 3),
                          ),
                          padding: const EdgeInsets.all(5),
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

              // ── Footer Row: Data ──
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: const BoxDecoration(
                  color: darkBrown,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(13),
                      bottomRight: Radius.circular(13)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      cardData.name.toUpperCase(),
                      style: const TextStyle(
                          color: primaryYellow,
                          fontSize: 13,
                          fontWeight: FontWeight.w900),
                    ),
                    Text(
                      'ID: $id',
                      style: const TextStyle(
                          color: primaryYellow,
                          fontSize: 13,
                          fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildCircleBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  @override
  PetCardPetOwnerAssociateViewModel viewModelBuilder(BuildContext context) =>
      PetCardPetOwnerAssociateViewModel();

  @override
  void onViewModelReady(PetCardPetOwnerAssociateViewModel viewModel) {
    viewModel.initialize();
    super.onViewModelReady(viewModel);
  }
}
