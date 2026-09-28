import 'package:flutter/material.dart';
import 'package:pashudhan_qr/models/role.dart';
import 'package:pashudhan_qr/screens/login/role_selection_viewmodel.dart';
import 'package:stacked/stacked.dart';

class RoleSelectionView extends StackedView<RoleSelectionViewModel> {
  const RoleSelectionView({super.key});

  @override
  Widget builder(
    BuildContext context,
    RoleSelectionViewModel viewModel,
    Widget? child,
  ) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(child: Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    /// HEADER
                    SizedBox(
                      height: screenHeight * 0.35,
                      width: double.infinity,
                      child: Image.asset(
                        'assets/header1.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      color: const Color(0xFF8A5A2B),
                      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                      child: const Text(
                        'Kindly Choose Your Category',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFF9C22E),
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                    /// MAIN CONTENT
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          /// ROLE ROW 1
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: _buildRoleItem(
                                  'ASSOCIATE PARTNER',
                                  'assets/hand_shake.png',
                                  () => viewModel.onRoleSelected(UserRole.PARTNER),
                                  size: 100,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildRoleItem(
                                  'ASSOCIATE',
                                  'assets/doctor1.png',
                                  () => viewModel.onRoleSelected(UserRole.ASSOCIATE),
                                  size: 100,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          /// ROLE ROW 2
                          _buildRoleItem(
                            'LIVESTOCK FARMER & PET OWNER',
                            'assets/livestockfarmer.png',
                            () => viewModel.onRoleSelected(UserRole.CUSTOMER),
                            size: 120,
                            isWide: true,
                          ),
                        ],
                      ),
                    ),

                    /// HINDI BANNER BOTTOM
                    Container(
                      width: double.infinity,
                      color: const Color(0xFF8A5A2B),
                      padding: const EdgeInsets.symmetric(
                          vertical: 6.0, horizontal: 8.0),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'अब अपने पशुधन की जन्मपत्री अपने हाथ में',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFF9C22E),
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// FOOTER (fixed 10%)
            SizedBox(
              height: screenHeight * 0.10,
              width: double.infinity,
              child: Image.asset(
                'assets/footer.png',
                fit: BoxFit.fill,
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildRoleItem(
    String title,
    String assetPath,
    VoidCallback onTap, {
    double size = 110,
    bool isWide = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: size,
            child: Image.asset(assetPath, fit: BoxFit.contain),
          ),
          const SizedBox(height: 8),
          _buildText(title, isWide: isWide),
        ],
      ),
    );
  }

  Widget _buildText(String title, {bool isWide = false}) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: isWide ? 260 : 160),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFB4D333),
        border: Border.all(color: const Color(0xFF5C3317), width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF5C3317),
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  @override
  RoleSelectionViewModel viewModelBuilder(BuildContext context) =>
      RoleSelectionViewModel();
}
