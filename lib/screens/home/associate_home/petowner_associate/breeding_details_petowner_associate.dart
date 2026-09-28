import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'breeding_details_petowner_associate_viewmodel.dart';

class BreedingDetailsPetOwnerAssociate
    extends StackedView<BreedingDetailsPetOwnerAssociateViewModel> {
  const BreedingDetailsPetOwnerAssociate({super.key});

  static const Color primaryYellow = Color(0xFFEDC93A);
  static const Color primaryGreen = Color(0xFFA1BC2A);
  static const Color darkBrown = Color(0xFF452B14);
  static const Color buttonYellow = Color(0xFFF3D133);

  @override
  Widget builder(BuildContext context,
      BreedingDetailsPetOwnerAssociateViewModel viewModel, Widget? child) {
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
                        'assets/icons_home/customer/pet_owner/pet_breading_report.png',
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // 🔥 TITLE
                    _buildTitleCard('ADD PET BREEDING DETAILS'),

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
                              'Name: ${viewModel.selectedPet!.petName ?? (viewModel.selectedPet!.name.isNotEmpty ? viewModel.selectedPet!.name : "Unknown")} (${viewModel.selectedPet!.displayGender})\nBreed: ${viewModel.selectedPet!.breed.isNotEmpty ? viewModel.selectedPet!.breed : "Unknown"}',
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
                                  border:
                                      Border.all(color: darkBrown, width: 2),
                                ),
                                child: Text(
                                  'Name: ${pet.petName ?? (pet.name.isNotEmpty ? pet.name : "Unknown")} (${pet.displayGender})',
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
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: () =>
                                    viewModel.selectMatingDate(context),
                                child: _buildInput(viewModel.matingDate != null
                                    ? viewModel.matingDate!.substring(0, 10)
                                    : 'DATE OF MATTING'),
                              ),
                              const SizedBox(height: 16),
                              GestureDetector(
                                onTap: () =>
                                    viewModel.selectWhelpingDate(context),
                                child: _buildInput(viewModel.whelpingDate !=
                                        null
                                    ? viewModel.whelpingDate!.substring(0, 10)
                                    : 'DATE OF WHELPING'),
                              ),
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
                              GestureDetector(
                                onTap: () => viewModel.scanQr(context),
                                child: _buildQrScanTile(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 🔥 DARK INPUT
                    _buildDarkInput('NUMBER OF PUPS GIVEN',
                        controller: viewModel.pupsController),

                    const SizedBox(height: 24),

                    // 🔥 SUBMIT
                    Center(
                      child: _buildSubmitButton(
                          viewModel.isBusy ? 'WAIT...' : 'SUBMIT >', () {
                        if (!viewModel.isBusy) {
                          viewModel.submit();
                        }
                      }),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ));
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
  Widget _buildQrScanTile() {
    return Container(
      height: 100,
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
    );
  }

  // 🔥 INPUT
  Widget _buildInput(String hint) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: primaryYellow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: darkBrown, width: 4),
      ),
      alignment: Alignment.center,
      child: Text(
        hint,
        style: const TextStyle(
          color: darkBrown,
          fontSize: 14,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  // 🔥 DARK INPUT
  Widget _buildDarkInput(String hint, {TextEditingController? controller}) {
    return Container(
      height: 62,
      decoration: BoxDecoration(
        color: darkBrown,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primaryYellow, width: 3.5),
      ),
      alignment: Alignment.center,
      child: controller != null
          ? TextField(
              controller: controller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                color: primaryYellow,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  color: primaryYellow,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
                border: InputBorder.none,
              ),
            )
          : Text(
              hint,
              style: const TextStyle(
                color: primaryYellow,
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

  Widget _buildReminderButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 88),
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

  @override
  BreedingDetailsPetOwnerAssociateViewModel viewModelBuilder(
          BuildContext context) =>
      BreedingDetailsPetOwnerAssociateViewModel();
}
