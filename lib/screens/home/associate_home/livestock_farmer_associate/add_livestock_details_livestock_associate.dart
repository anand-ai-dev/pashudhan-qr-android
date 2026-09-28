import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'package:pashudhan_qr/widgets/breed_autocomplete_input.dart';
import 'add_livestock_details_livestock_associate_viewmodel.dart';

class AddLivestockDetailsLivestockAssociate extends StackedView<AddLivestockDetailsLivestockAssociateViewModel> {
  final String? initialMobile;

  const AddLivestockDetailsLivestockAssociate({super.key, this.initialMobile});

  static const Color primaryYellow = Color(0xFFEDC93A);
  static const Color primaryGreen = Color(0xFFA1BC2A);
  static const Color darkBrown = Color(0xFF452B14);
  static const Color buttonYellow = Color(0xFFF3D133);

  @override
  Widget builder(
    BuildContext context,
    AddLivestockDetailsLivestockAssociateViewModel viewModel,
    Widget? child,
  ) {
    return SafeArea(
        child: Scaffold(
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
                    'assets/icons_home/customer/livestock_farmer/farmer_animals.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 10),
                _buildTitleCard(viewModel.ownerConfirmed
                    ? 'ADD LIVESTOCK DETAILS'
                    : 'OWNER INFORMATION'),
                const SizedBox(height: 16),
                _buildSearchInput('SEARCH BY L.FARMER MOBILE NO',
                    viewModel.lfMobileController),
                const SizedBox(height: 14),
                if (!viewModel.ownerConfirmed) ...[
                  _buildOwnerInfoCard(),
                  const SizedBox(height: 14),
                  _buildSubmitButton('CONTINUE >', () {
                    if (!viewModel.isBusy) {
                      viewModel.continueWithOwner(context);
                    }
                  }),
                  const SizedBox(height: 12),
                  _buildButton('REGISTER OWNER', () {
                    if (!viewModel.isBusy) {
                      viewModel.registerOwnerThenContinue(context);
                    }
                  }),
                  const SizedBox(height: 30),
                ] else ...[
                  _buildConfirmedOwnerCard(viewModel),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                          flex: 3,
                          child: _buildButton('CHANGE', viewModel.resetOwner)),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 7,
                        child: _buildDropdown(
                            'LIVESTOCK TYPE',
                            ['COW', 'BUFFALO'],
                            viewModel.selectedLivestockType,
                            viewModel.setLivestockType),
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
                          animalCategory: viewModel.selectedLivestockType,
                          backgroundColor: const Color(0xFFEDEDED),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildDropdown(
                          'GENDER', ['Male', 'Female'], viewModel.selectedGender, (val) => viewModel.setGender(val),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: _buildAgeButton(
                          viewModel.selectedAgeDate != null
                              ? '${viewModel.calculatedAgeInMonths} Months'
                              : 'AGE',
                          () => viewModel.selectAgeDate(context),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildDropdown(
                          'LACTATION NO.',
                          ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15+'],
                          viewModel.selectedLactationNumber,
                          viewModel.setSelectedLactationNumber,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                          child: _buildInput('LIVESTOCK NAME',
                              viewModel.livestockNameController, fontSize: 13)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _buildInput(
                              'LIVESTOCK WEIGHT', viewModel.weightController, fontSize: 13)),
                    ],
                  ),

                  const SizedBox(height: 14),

                  _buildInput('LIVESTOCK ID NO.', viewModel.idNoController),

                  const SizedBox(height: 24),

                  Center(
                    child: SizedBox(
                      width: 180,
                      child: _buildSubmitButton(
                          viewModel.isBusy ? 'WAIT...' : 'SUBMIT >', () {
                        if (!viewModel.isBusy) viewModel.submit();
                      }),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ],
            ),
          ),
        ),
      ),
    ));
  }

  Widget _buildOwnerInfoCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: primaryYellow.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: darkBrown, width: 3),
      ),
      child: const Text(
        'Enter the farmer mobile number first. If the owner is already registered, continue to cattle details. If not, register the owner first.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: darkBrown,
          fontSize: 14,
          fontWeight: FontWeight.w800,
          height: 1.3,
        ),
      ),
    );
  }

  Widget _buildConfirmedOwnerCard(
      AddLivestockDetailsLivestockAssociateViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: buttonYellow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: darkBrown, width: 3),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: darkBrown),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Owner: ${viewModel.confirmedOwnerMobile}',
              style: const TextStyle(
                color: darkBrown,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
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
            child: Icon(Icons.search, color: primaryGreen, size: 26),
          ),
        ],
      ),
    );
  }

  // 🔥 INPUT
  Widget _buildInput(String hint, TextEditingController? controller,
      {double fontSize = 14, bool enabled = true}) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: darkBrown, width: 4),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        enabled: enabled,
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

  Widget _buildAgeButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFEDEDED),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: darkBrown, width: 4),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: darkBrown,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  // 🔥 DROPDOWN
  Widget _buildDropdown(String hint, List<String> items, String? value,
      void Function(String) onChanged, {double fontSize = 14}) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
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
          icon:
              const Icon(Icons.keyboard_arrow_down, color: darkBrown, size: 28),
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
  Widget _buildSubmitButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: buttonYellow,
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
  AddLivestockDetailsLivestockAssociateViewModel viewModelBuilder(
          BuildContext context) =>
      AddLivestockDetailsLivestockAssociateViewModel(initialMobile: initialMobile);

  @override
  void onViewModelReady(
      AddLivestockDetailsLivestockAssociateViewModel viewModel) {
    viewModel.initialize();
    super.onViewModelReady(viewModel);
  }
}
