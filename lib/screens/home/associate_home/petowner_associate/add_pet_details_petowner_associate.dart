import 'dart:io' as dart_io;
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'package:pashudhan_qr/widgets/breed_autocomplete_input.dart';
import 'add_pet_details_petowner_associate_viewmodel.dart';


class AddLivestockDetailsPetOwnerAssociate extends StackedView<AddLivestockDetailsPetOwnerAssociateViewModel> {
  final String? initialMobile;
  const AddLivestockDetailsPetOwnerAssociate({super.key, this.initialMobile});

  static const Color primaryYellow = Color(0xFFEDC93A);
  static const Color primaryGreen = Color(0xFFA1BC2A);
  static const Color darkBrown = Color(0xFF452B14);
  static const Color buttonYellow = Color(0xFFF3D133);

  @override
  Widget builder(
    BuildContext context,
    AddLivestockDetailsPetOwnerAssociateViewModel viewModel,
    Widget? child,
  ) {
    return SafeArea(child: Scaffold(
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 30),

                SizedBox(
                  height: 200,
                  child: Image.asset(
                    'assets/pashudhan_card_pets.png',
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 10),

                _buildTitleCard('ADD PET DETAILS'),

                const SizedBox(height: 16),

                _buildSearchInput('SEARCH BY PET OWNER MOBILE NO', viewModel.ownerMobileController),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(flex: 3, child: _buildButton('ADD', () {})),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 7,
                      child: _buildDropdown(
                          'PET TYPE', ['DOG', 'CAT', 'OTHER'], viewModel.selectedPetType, viewModel.setPetType),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: BreedAutocompleteInput(
                        hint: 'BREED',
                        controller: viewModel.breedController,
                        animalCategory: viewModel.selectedPetType,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildDropdown(
                          'GENDER', ['Male', 'Female'], viewModel.selectedGender, (val) => viewModel.setGender(val)),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                _buildInput(
                  'D.O.B',
                  viewModel.dobController,
                  readOnly: true,
                  onTap: () => viewModel.selectDob(context),
                ),

                const SizedBox(height: 14),

                // 🔥 TAPPABLE PHOTO UPLOAD SECTION
                _buildPhotoUploadSection(viewModel),

                const SizedBox(height: 14),

                _buildInput('BREEDING NO.', viewModel.breedingNoController),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(child: _buildInput('PET NAME', viewModel.petNameController)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildInput('PET WEIGHT', viewModel.weightController)),
                  ],
                ),

                const SizedBox(height: 14),

                _buildInput('PET ID NO.', viewModel.petIdNoController),

                const SizedBox(height: 24),

                Center(
                  child: SizedBox(
                    width: 180,
                    child: _buildSubmitButton(
                      viewModel.isBusy ? 'WAIT...' : 'SUBMIT >', 
                      () {
                        if (!viewModel.isBusy && viewModel.capturedPhotos.length >= 3) {
                          viewModel.submit();
                        }
                      },
                      enabled: !viewModel.isBusy && viewModel.capturedPhotos.length >= 3,
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    ));
  }

  // 🔥 PHOTO UPLOAD SECTION - tappable to open camera
  Widget _buildPhotoUploadSection(AddLivestockDetailsPetOwnerAssociateViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Tap to capture button
        GestureDetector(
          onTap: viewModel.capturePhoto,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: viewModel.capturedPhotos.length >= 3
                  ? darkBrown
                  : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: darkBrown, width: 4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  viewModel.capturedPhotos.length >= 3
                      ? Icons.check_circle
                      : Icons.camera_alt,
                  color: viewModel.capturedPhotos.length >= 3
                      ? primaryYellow
                      : darkBrown,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  viewModel.capturedPhotos.isEmpty
                      ? 'TAP TO CAPTURE PHOTOS (MIN 3)'
                      : '${viewModel.capturedPhotos.length} PHOTO${viewModel.capturedPhotos.length == 1 ? '' : 'S'} CAPTURED (TAP TO ADD)',
                  style: TextStyle(
                    color: viewModel.capturedPhotos.length >= 3
                        ? primaryYellow
                        : darkBrown,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Show captured photos as thumbnails
        if (viewModel.capturedPhotos.isNotEmpty) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: viewModel.capturedPhotos.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          viewModel.capturedPhotos[index],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () => viewModel.removePhoto(index),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                      // Photo number badge
                      Positioned(
                        bottom: 2,
                        left: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: darkBrown.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: primaryYellow,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  // 🔥 TITLE
  Widget _buildTitleCard(String title) {
    return Container(
      height: 62,
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

  // 🔥 SEARCH
  Widget _buildSearchInput(String hint, TextEditingController controller) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: primaryYellow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: darkBrown, width: 4),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  color: darkBrown,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.search, color: darkBrown, size: 26),
          ),
        ],
      ),
    );
  }

  // 🔥 INPUT
  Widget _buildInput(String hint, TextEditingController? controller, {double fontSize = 14, bool enabled = true, bool readOnly = false, VoidCallback? onTap}) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: darkBrown, width: 4),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        enabled: enabled,
        readOnly: readOnly,
        onTap: onTap,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: darkBrown,
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  // 🔥 DROPDOWN
  Widget _buildDropdown(String hint, List<String> items, String? value, void Function(String) onChanged, {double fontSize = 14}) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: darkBrown, width: 4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Center(
            child: Text(
              hint,
              style: TextStyle(
                color: darkBrown,
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          icon: const Icon(Icons.keyboard_arrow_down, color: darkBrown, size: 28),
          items: items.map((String val) {
            return DropdownMenuItem<String>(
              value: val,
              alignment: Alignment.center,
              child: Center(
                child: Text(
                  val,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: darkBrown,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
        ),
      ),
    );
  }

  // 🔥 ADD BUTTON
  Widget _buildButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: darkBrown,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: buttonYellow, width: 4),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: buttonYellow,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  // 🔥 SUBMIT
  Widget _buildSubmitButton(String label, VoidCallback onTap, {bool enabled = true}) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: enabled ? buttonYellow : Colors.grey.shade400,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: darkBrown, width: 4),
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
  AddLivestockDetailsPetOwnerAssociateViewModel viewModelBuilder(
          BuildContext context) =>
      AddLivestockDetailsPetOwnerAssociateViewModel(initialMobile: initialMobile);

  @override
  void onViewModelReady(
      AddLivestockDetailsPetOwnerAssociateViewModel viewModel) {
    viewModel.initialize();
    super.onViewModelReady(viewModel);
  }
}
