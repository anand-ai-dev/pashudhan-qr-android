import 'dart:io' as dart_io;
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:pashudhan_qr/screens/home/customer_home/livestock_farmer/routes/scan_muzzle_screen.dart';

import 'vaccination_details_livestock_associate_viewmodel.dart';

class VaccinationDetailsLivestockAssociate
    extends StackedView<VaccinationDetailsLivestockAssociateViewModel> {
  const VaccinationDetailsLivestockAssociate({super.key});

  static const Color primaryYellow = Color(0xFFEDC93A);
  static const Color primaryGreen = Color(0xFFA1BC2A);
  static const Color darkBrown = Color(0xFF452B14);
  static const Color buttonYellow = Color(0xFFF3D133);

  @override
  Widget builder(
    BuildContext context,
    VaccinationDetailsLivestockAssociateViewModel viewModel,
    Widget? child,
  ) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: primaryYellow,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: primaryYellow,
            image: DecorationImage(
              image: AssetImage('assets/pattern_bg.png'),
              repeat: ImageRepeat.repeat,
              opacity: 0.15,
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 30),

                    // Illustration
                    SizedBox(
                      height: 180,
                      child: Image.asset(
                        'assets/icons_home/customer/livestock_farmer/vaccination_green_report.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.medical_information_outlined,
                                size: 80, color: darkBrown),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    _buildTitleCard('ADD VACCINATION  DETAILS'),
                    const SizedBox(height: 16),

                    // Search input — always visible
                    _buildSearchInput(
                      'SEARCH BY L.FARMER MOBILE NO',
                      viewModel.mobileController,
                      viewModel.fetchLivestock,
                    ),
                    const SizedBox(height: 8),

                    // Livestock list (shown after search, hidden when locked)
                    if (viewModel.isLivestockLocked &&
                        viewModel.selectedLivestock != null) ...[
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: primaryGreen,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: darkBrown, width: 3.5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${viewModel.selectedLivestock!.name.isNotEmpty ? viewModel.selectedLivestock!.name : "Unknown"} (${viewModel.selectedLivestock!.displayGender}) (${viewModel.selectedLivestock!.breed})',
                                style: const TextStyle(
                                  color: darkBrown,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: viewModel.resetLivestock,
                              child: const Icon(Icons.refresh,
                                  color: darkBrown, size: 28),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ] else if (viewModel.livestocks.isNotEmpty) ...[
                      Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: primaryGreen,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: darkBrown, width: 3.5),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: viewModel.livestocks.length,
                          itemBuilder: (context, index) {
                            final item = viewModel.livestocks[index];
                            final isSelected =
                                viewModel.selectedLivestock?.uuid == item.uuid;
                            return GestureDetector(
                              onTap: () => viewModel.selectLivestock(item),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 5),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: isSelected ? darkBrown : primaryYellow,
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: darkBrown, width: 2),
                                ),
                                child: Text(
                                  '${item.name.isNotEmpty ? item.name : "Unknown"} (${item.displayGender}) (${item.breed})',
                                  style: TextStyle(
                                    color:
                                        isSelected ? primaryYellow : darkBrown,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    // ADD + scanner tiles row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              _buildButton('ADD', viewModel.lockLivestock),
                              const SizedBox(height: 16),
                              _buildMuzzleScannerTile(context),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            children: [
                              _buildQrScanTile(context, viewModel),
                              const SizedBox(height: 16),
                              // Info block removed to make space for photos
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Vaccine name input — wired to controller
                    _buildVaccineInput(viewModel.vaccineNameController),
                    const SizedBox(height: 16),

                    // Next Vaccination Reminder Button
                    _buildDateButton(
                      viewModel.selectedDate != null
                          ? 'Next Vaccination Reminder: ${viewModel.formattedSelectedDate}'
                          : 'Next Vaccination Reminder',
                      () => viewModel.selectDate(context),
                    ),
                    const SizedBox(height: 16),

                    // Add photo pickers for FRONT and BACK
                    Row(
                      children: [
                        Expanded(
                          child: _buildPhotoPicker(
                            'FRONT PHOTO',
                            viewModel.frontPhoto,
                            viewModel.pickFrontPhoto,
                            viewModel.removeFrontPhoto,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildPhotoPicker(
                            'BACK PHOTO',
                            viewModel.backPhoto,
                            viewModel.pickBackPhoto,
                            viewModel.removeBackPhoto,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Submit
                    Center(
                      child: SizedBox(
                        width: 160,
                        child: _buildSubmitButton(
                          viewModel.isBusy ? 'WAIT...' : 'SUBMIT >',
                          () {
                            if (!viewModel.isBusy) viewModel.submit(context);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMuzzleScannerTile(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ScanMuzzleScreen()),
        );
      },
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: primaryGreen,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: darkBrown, width: 3.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons_home/customer/livestock_farmer/muzzle.png',
              height: 65,
              width: 175,
              fit: BoxFit.contain,
              errorBuilder: (c, e, s) =>
                  const Icon(Icons.image, color: darkBrown),
            ),
            const SizedBox(height: 6),
            const Text(
              'MUZZLE SCANNER',
              style: TextStyle(
                  color: primaryYellow,
                  fontSize: 16,
                  fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPicker(
      String label, dart_io.File? photo, VoidCallback onPick, VoidCallback onRemove) {
    return GestureDetector(
      onTap: photo == null ? onPick : null,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: primaryGreen,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: darkBrown, width: 3.5),
        ),
        child: photo != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.file(photo, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_alt, color: darkBrown, size: 32),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: primaryYellow,
                        fontSize: 14,
                        fontWeight: FontWeight.w900),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildQrScanTile(BuildContext context,
      VaccinationDetailsLivestockAssociateViewModel viewModel) {
    return GestureDetector(
      onTap: () => viewModel.scanQr(context),
      child: Container(
        height: 110,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: primaryGreen,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: darkBrown, width: 3.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 5,
              child: Image.asset(
                'assets/icons_home/customer/livestock_farmer/qr_image.png',
                fit: BoxFit.contain,
                errorBuilder: (c, e, s) =>
                    const Icon(Icons.qr_code, color: darkBrown, size: 40),
              ),
            ),
            const SizedBox(width: 6),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleCard(String title) {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: darkBrown,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: primaryGreen, width: 3.5),
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            color: primaryYellow,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchInput(
    String hint,
    TextEditingController controller,
    VoidCallback onSearch,
  ) {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: primaryGreen,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: darkBrown, width: 3.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                    color: darkBrown,
                    fontSize: 15,
                    fontWeight: FontWeight.w900),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              ),
            ),
          ),
          GestureDetector(
            onTap: onSearch,
            child: const Padding(
              padding: EdgeInsets.only(right: 14.0),
              child: Icon(Icons.search, color: darkBrown, size: 32),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVaccineInput(TextEditingController controller) {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: darkBrown, width: 3.5),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: darkBrown,
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
        decoration: const InputDecoration(
          hintText: 'ADD VACCINE NAME',
          hintStyle: TextStyle(
            color: darkBrown,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 20),
        ),
      ),
    );
  }

  Widget _buildInfoBlock(String text) {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: darkBrown,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: primaryGreen, width: 3.5),
      ),
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: primaryYellow,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            height: 1.1,
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 65,
        decoration: BoxDecoration(
          color: darkBrown,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: primaryGreen, width: 3.5),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
                color: primaryYellow,
                fontSize: 21,
                fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }

  Widget _buildDateButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 65),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: darkBrown, width: 3.5),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: darkBrown,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 65,
        decoration: BoxDecoration(
          color: primaryGreen,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: darkBrown, width: 3.5),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: darkBrown,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  @override
  VaccinationDetailsLivestockAssociateViewModel viewModelBuilder(
          BuildContext context) =>
      VaccinationDetailsLivestockAssociateViewModel();

  @override
  void onViewModelReady(
      VaccinationDetailsLivestockAssociateViewModel viewModel) {
    viewModel.initialize();
    super.onViewModelReady(viewModel);
  }
}
