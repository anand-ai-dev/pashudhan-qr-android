import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:pashudhan_qr/screens/home/customer_home/livestock_farmer/routes/scan_muzzle_screen.dart';

import 'breeding_details_livestock_associate_viewmodel.dart';

class BreedingDetailsLivestockAssociate
    extends StackedView<BreedingDetailsLivestockAssociateViewModel> {
  const BreedingDetailsLivestockAssociate({super.key});

  static const Color primaryYellow = Color(0xFFEDC93A);
  static const Color primaryGreen = Color(0xFFA1BC2A);
  static const Color darkBrown = Color(0xFF452B14);
  static const Color buttonYellow = Color(0xFFF3D133);

  @override
  Widget builder(
    BuildContext context,
    BreedingDetailsLivestockAssociateViewModel viewModel,
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
                        'assets/icons_home/customer/livestock_farmer/breading_report.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.favorite_border_outlined,
                                size: 80, color: darkBrown),
                      ),
                    ),
                    const SizedBox(height: 5),

                    // Title
                    _buildTitleCard('ADD BREEDING  DETAILS'),
                    const SizedBox(height: 5),

                    // Search input — always visible
                    _buildSearchInput(
                      'SEARCH BY L.FARMER MOBILE NO',
                      viewModel.mobileController,
                      viewModel.fetchLivestock,
                    ),
                    const SizedBox(height: 8),

                    // Locked selection summary
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
                    ]
                    // Livestock list
                    else if (viewModel.livestocks.isNotEmpty) ...[
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
                              // 🔥 Muzzle scanner — pushes to ScanMuzzleScreen
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const ScanMuzzleScreen()),
                                  );
                                },
                                child: Container(
                                  height: 110,
                                  decoration: BoxDecoration(
                                    color: primaryGreen,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: darkBrown, width: 3.5),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/icons_home/customer/livestock_farmer/muzzle.png',
                                        height: 65,
                                        width: 175,
                                        fit: BoxFit.contain,
                                        errorBuilder: (c, e, s) => const Icon(
                                            Icons.image,
                                            color: darkBrown),
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        'MUZZLE SCANNER',
                                        style: TextStyle(
                                          color: primaryYellow,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            children: [
                              // QR scan tile
                              _buildQrScanTile(context, viewModel),
                              const SizedBox(height: 16),
                              // Insemination type dropdown
                              _buildDropdown(
                                viewModel.inseminationType,
                                ['NATURAL', 'AI'],
                                viewModel.onInseminationTypeChanged,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Bull breed (for NATURAL)
                    _buildTextInput(
                      'IN CASE OF NATURAL INSEMINATION ADD THE BULL BREED',
                      controller: viewModel.bullBreedController,
                      fontSize: 12,
                    ),
                    const SizedBox(height: 15),

                    // Straw No (for ARTIFICIAL)
                    _buildTextInput(
                      'IN CASE OF ARTIFICIAL INSEMINATION ADD THE  STRAW NO',
                      controller: viewModel.strawNoController,
                      fontSize: 12,
                    ),
                    const SizedBox(height: 15),

                    // Date of insemination + No. of calves
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                viewModel.selectInseminationDate(context),
                            child: _buildDisplayInput(
                              viewModel.inseminationDateLabel,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildTextInput(
                            'NO. OF CALVES',
                            controller: viewModel.calvesController,
                            fontSize: 13,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Date of Calving
                    GestureDetector(
                      onTap: () => viewModel.selectCalvingDate(context),
                      child: _buildDisplayInput(
                        viewModel.calvingDateLabel,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),

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

  Widget _buildQrScanTile(BuildContext context,
      BreedingDetailsLivestockAssociateViewModel viewModel) {
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

  // Input field wired to a TextEditingController
  Widget _buildTextInput(
    String hint, {
    required TextEditingController controller,
    double fontSize = 14,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: darkBrown, width: 3.5),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              color: darkBrown,
              fontSize: fontSize,
              fontWeight: FontWeight.w900),
          border: InputBorder.none,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        ),
      ),
    );
  }

  // Read-only display field (for date)
  Widget _buildDisplayInput(String text, {double fontSize = 14}) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: darkBrown, width: 3.5),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_today, color: darkBrown, size: 16),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: darkBrown,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String currentValue,
    List<String> items,
    void Function(String?) onChanged,
  ) {
    return Container(
      height: 65,
      padding: const EdgeInsets.only(left: 16, right: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: darkBrown, width: 3.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: currentValue,
          icon:
              const Icon(Icons.keyboard_arrow_down, color: darkBrown, size: 36),
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Center(
                child: Text(
                  value == 'AI' ? 'ARTIFICIAL' : value,
                  style: const TextStyle(
                      color: darkBrown,
                      fontSize: 13,
                      fontWeight: FontWeight.w900),
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
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
  BreedingDetailsLivestockAssociateViewModel viewModelBuilder(
          BuildContext context) =>
      BreedingDetailsLivestockAssociateViewModel();

  @override
  void onViewModelReady(BreedingDetailsLivestockAssociateViewModel viewModel) {
    viewModel.initialize();
    super.onViewModelReady(viewModel);
  }
}
