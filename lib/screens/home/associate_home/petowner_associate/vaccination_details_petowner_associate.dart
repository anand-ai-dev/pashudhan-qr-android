import 'dart:io' as dart_io;
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'vaccination_details_petowner_associate_viewmodel.dart';

class VaccinationDetailsPetOwnerAssociate
    extends StackedView<VaccinationDetailsPetOwnerAssociateViewModel> {
  const VaccinationDetailsPetOwnerAssociate({super.key});

  static const Color primaryYellow = Color(0xFFEDC93A);
  static const Color primaryGreen = Color(0xFFA1BC2A);
  static const Color darkBrown = Color(0xFF452B14);
  static const Color buttonYellow = Color(0xFFF3D133);

  @override
  Widget builder(BuildContext context, viewModel, Widget? child) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: primaryGreen,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: primaryGreen,
              image: DecorationImage(
                image: AssetImage('assets/pattern_bg.png'),
                repeat: ImageRepeat.repeat,
                opacity: 0.15,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 30),

                  // 🔥 IMAGE
                  SizedBox(
                    height: 180,
                    child: Image.asset(
                      'assets/icons_home/customer/pet_owner/vaccination_yellow_report.png',
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 🔥 TITLE
                  _buildTitleCard('ADD PET VACCINE DETAILS'),

                  const SizedBox(height: 16),

                  // 🔥 SEARCH
                  if (!viewModel.isPetLocked) ...[
                    _buildSearchInput('SEARCH BY PET OWNER. MOBILE NO',
                        viewModel.mobileController, viewModel.fetchPets),
                    const SizedBox(height: 16),
                  ],

                  // 🔥 PET LIST OR SUMMARY
                  if (viewModel.isPetLocked &&
                      viewModel.selectedPet != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryYellow,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: darkBrown, width: 3.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Name: ${viewModel.selectedPet!.petName ?? (viewModel.selectedPet!.name.isNotEmpty ? viewModel.selectedPet!.name : "N/A")} (${viewModel.selectedPet!.displayGender})\nBreed: ${viewModel.selectedPet!.breed.isNotEmpty ? viewModel.selectedPet!.breed : "Unknown"}',
                            style: const TextStyle(
                              color: darkBrown,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          GestureDetector(
                            onTap: viewModel.resetPet,
                            child: const Icon(Icons.refresh,
                                color: darkBrown, size: 30),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ] else if (viewModel.pets.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryYellow,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: darkBrown, width: 3.5),
                      ),
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: viewModel.pets.length,
                        itemBuilder: (context, index) {
                          final pet = viewModel.pets.elementAt(index);
                          final isSelected =
                              viewModel.selectedPet?.uuid == pet.uuid;
                          return GestureDetector(
                            onTap: () => viewModel.selectPet(pet),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? darkBrown : primaryYellow,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: darkBrown, width: 2),
                              ),
                              child: Text(
                                'Name: ${pet.petName ?? (pet.name.isNotEmpty ? pet.name : "N/A")} (${pet.displayGender})',
                                style: TextStyle(
                                  color: isSelected ? primaryYellow : darkBrown,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 🔥 DUAL COLUMN LAYOUT
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // LEFT COLUMN
                      Expanded(
                        flex: 48,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildButton('ADD', () {
                              viewModel.lockPet();
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // RIGHT COLUMN
                      Expanded(
                        flex: 52,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildQrScanTile(context, viewModel),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 🔥 VACCINE NAME INPUT
                  _buildDarkInput('ADD VACCINE NAME',
                      controller: viewModel.vaccineNameController),

                  const SizedBox(height: 16),

                  // 🔥 NEXT VACCINATION REMINDER
                  _buildReminderButton(
                    viewModel.nextDueDate != null
                        ? 'Next Vaccination Reminder: ${viewModel.formattedNextDueDate}'
                        : 'Next Vaccination Reminder',
                    () => viewModel.selectNextDate(context),
                  ),

                  const SizedBox(height: 16),

                  // 🔥 FRONT & BACK PHOTO PICKERS
                  Row(
                    children: [
                      Expanded(
                        child: _buildPhotoPicker(
                          'FRONT PHOTO\nOF VACCINE',
                          viewModel.frontPhoto,
                          viewModel.pickFrontPhoto,
                          viewModel.removeFrontPhoto,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildPhotoPicker(
                          'BACK PHOTO\nOF VACCINE',
                          viewModel.backPhoto,
                          viewModel.pickBackPhoto,
                          viewModel.removeBackPhoto,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 🔥 SUBMIT
                  Center(
                    child: _buildSubmitButton(
                        viewModel.isBusy ? 'WAIT...' : 'SUBMIT >', () {
                      if (!viewModel.isBusy) {
                        viewModel.submit(context);
                      }
                    }),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🔥 PHOTO PICKER
  Widget _buildPhotoPicker(
      String label, dart_io.File? photo, VoidCallback onPick, VoidCallback onRemove) {
    return GestureDetector(
      onTap: photo == null ? onPick : null,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: primaryYellow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: darkBrown, width: 3.5),
        ),
        child: photo != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
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
                        color: darkBrown,
                        fontSize: 14,
                        fontWeight: FontWeight.w900),
                  ),
                ],
              ),
      ),
    );
  }

  // 🔥 TITLE
  Widget _buildTitleCard(String title) {
    return Container(
      height: 68,
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
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  // 🔥 SEARCH
  Widget _buildSearchInput(
      String hint, TextEditingController controller, VoidCallback onSearch) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: primaryYellow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: darkBrown, width: 3.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  color: darkBrown,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          GestureDetector(
            onTap: onSearch,
            child: const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.search, color: darkBrown),
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 QR TILE
  Widget _buildQrScanTile(BuildContext context,
      VaccinationDetailsPetOwnerAssociateViewModel viewModel) {
    return GestureDetector(
      onTap: () => viewModel.scanQr(context),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: primaryYellow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: darkBrown, width: 4),
        ),
        child: Image.asset(
          'assets/icons_home/customer/pet_owner/qr_image1.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildReminderButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 65),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: darkBrown,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: primaryYellow, width: 3.5),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: primaryYellow,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  // 🔥 DARK INPUT
  Widget _buildDarkInput(String hint, {TextEditingController? controller}) {
    return Container(
      height: 62,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: darkBrown, width: 3.5),
      ),
      alignment: Alignment.center,
      child: controller != null
          ? TextField(
              controller: controller,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: darkBrown,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  color: darkBrown,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
                border: InputBorder.none,
              ),
            )
          : Text(
              hint,
              style: const TextStyle(
                color: darkBrown,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
    );
  }

  // 🔥 BUTTON
  Widget _buildButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: darkBrown,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: primaryYellow, width: 3.5),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: primaryYellow,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  // 🔥 SUBMIT
  Widget _buildSubmitButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        width: 160,
        decoration: BoxDecoration(
          color: buttonYellow,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: darkBrown, width: 3.5),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: darkBrown,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  @override
  VaccinationDetailsPetOwnerAssociateViewModel viewModelBuilder(
          BuildContext context) =>
      VaccinationDetailsPetOwnerAssociateViewModel();
}
