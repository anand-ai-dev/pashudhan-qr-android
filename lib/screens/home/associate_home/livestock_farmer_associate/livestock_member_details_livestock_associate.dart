import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';

import 'livestock_member_details_livestock_associate_viewmodel.dart';

/// Customer onboarding screen — register the livestock farmer as a customer.
/// Reached after successfully registering a pashudhan via Add Livestock.
class LivestockMemberDetailsLivestockAssociate
    extends StackedView<LivestockMemberDetailsLivestockAssociateViewModel> {

  /// Mobile number of the farmer (passed from Add Livestock screen, optional)
  final String? ownerMobile;
  final bool returnToPreviousFlow;

  const LivestockMemberDetailsLivestockAssociate({
    super.key,
    this.ownerMobile,
    this.returnToPreviousFlow = false,
  });

  static const Color primaryYellow = Color(0xFFEDC93A);
  static const Color primaryGreen = Color(0xFFA1BC2A);
  static const Color darkBrown = Color(0xFF452B14);
  static const Color buttonYellow = Color(0xFFF3D133);

  @override
  Widget builder(
    BuildContext context,
    LivestockMemberDetailsLivestockAssociateViewModel viewModel,
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

                  // ── Illustration ──
                  SizedBox(
                    height: 200,
                    child: Image.asset(
                      'assets/icons_home/customer/livestock_farmer/farmer_animals.png',
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ── Title ──
                  _buildTitleCard('LIVESTOCK FARMER DETAILS'),

                  const SizedBox(height: 16),

                  // ── NAME + FATHER'S NAME ──
                  Row(
                    children: [
                      Expanded(
                          child: _buildInput('NAME', viewModel.nameController)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _buildInput(
                              "FATHER'S NAME", viewModel.fatherNameController)),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ── GENDER (Dropdown) ──
                  _buildGenderDropdown(viewModel),

                  const SizedBox(height: 14),

                  // ── LOCATION ──
                  Row(
                    children: [
                      Expanded(
                        child: _buildInput(
                          viewModel.isFetchingLocation ? 'FETCHING LOCATION...' : 'LOCATION',
                          viewModel.locationController,
                        ),
                      ),
                      if (viewModel.locationError != null || !viewModel.isFetchingLocation)
                        IconButton(
                          icon: const Icon(Icons.my_location, color: darkBrown),
                          onPressed: viewModel.fetchLocation,
                        ),
                    ],
                  ),
                  if (viewModel.locationError != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      viewModel.locationError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ],

                  const SizedBox(height: 14),

                  // ── PHONE NUMBER (manually entered) ──
                  _buildNumberInput('PHONE NUMBER', viewModel.mobileController, maxLength: 10),

                  const SizedBox(height: 14),

                  // ── PINCODE ──
                  _buildNumberInput('PINCODE', viewModel.pincodeController, maxLength: 6),

                  const SizedBox(height: 14),

                  // ── AADHAR NUMBER ──
                  _buildNumberInput('AADHAR NUMBER', viewModel.aadharController,
                      maxLength: 12),

                  const SizedBox(height: 14),

                  // ── OTP SECTION ──
                  _buildOtpSection(viewModel),

                  const SizedBox(height: 24),

                  // ── SUBMIT ──
                  Center(
                    child: SizedBox(
                      width: 180,
                      child: _buildSubmitButton(
                        viewModel.isBusy ? 'REGISTERING...' : 'SUBMIT >',
                        viewModel.otpVerified && !viewModel.isBusy
                            ? () => viewModel.submit(context)
                            : null,
                        enabled: viewModel.otpVerified && !viewModel.isBusy,
                      ),
                    ),
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

  // ═══════════════════════════════════════════════════════════════════
  //  OTP SECTION
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildOtpSection(
      LivestockMemberDetailsLivestockAssociateViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: primaryYellow.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: darkBrown, width: 3),
      ),
      child: Column(
        children: [
          // Status text
          if (viewModel.isSendingOtp)
            const _OtpStatusRow(
                icon: Icons.send_rounded,
                text: 'Sending OTP...',
                color: darkBrown)
          else if (viewModel.otpVerified)
            const _OtpStatusRow(
                icon: Icons.check_circle,
                text: 'OTP Verified ✅',
                color: Color(0xFF2E7D32))
          else if (viewModel.otpSent)
            const _OtpStatusRow(
                icon: Icons.sms_rounded,
                text: 'OTP sent to farmer\'s number',
                color: darkBrown),

          if (viewModel.otpError != null) ...[
            const SizedBox(height: 6),
            Text(
              viewModel.otpError!,
              style: const TextStyle(
                  color: Color(0xFFC62828),
                  fontSize: 13,
                  fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
          ],

          // OTP input + verify button (only if not verified yet)
          if (!viewModel.otpVerified) ...[
            if (!viewModel.otpSent) ...[
              const SizedBox(height: 10),
              GestureDetector(
                onTap: viewModel.isSendingOtp ? null : viewModel.sendOtp,
                child: Container(
                  height: 56,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: darkBrown,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: buttonYellow, width: 3),
                  ),
                  child: Center(
                    child: Text(
                      viewModel.isSendingOtp ? 'SENDING...' : 'SEND OTP',
                      style: const TextStyle(
                        color: buttonYellow,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildNumberInput('ENTER OTP', viewModel.otpController, maxLength: 6),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: viewModel.isVerifyingOtp ? null : viewModel.verifyOtp,
                    child: Container(
                      height: 56,
                      width: 100,
                      decoration: BoxDecoration(
                        color: darkBrown,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: buttonYellow, width: 3),
                      ),
                      child: Center(
                        child: Text(
                          viewModel.isVerifyingOtp ? 'WAIT...' : 'VERIFY',
                          style: const TextStyle(
                            color: buttonYellow,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Resend button
              if (viewModel.otpSent && !viewModel.isSendingOtp) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: viewModel.sendOtp,
                  child: const Text(
                    'Resend OTP',
                    style: TextStyle(
                      color: darkBrown,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildGenderDropdown(LivestockMemberDetailsLivestockAssociateViewModel viewModel) {
    final genders = ['MALE', 'FEMALE', 'OTHERS'];
    final currentText = viewModel.genderController.text.toUpperCase();
    final value = genders.contains(currentText) ? currentText : null;

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
          hint: const Center(
            child: Text(
              'GENDER',
              style: TextStyle(
                color: darkBrown,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          icon: const Icon(Icons.keyboard_arrow_down, color: darkBrown, size: 28),
          items: genders.map((String val) {
            return DropdownMenuItem<String>(
              value: val,
              alignment: Alignment.center,
              child: Center(
                child: Text(
                  val,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: darkBrown,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              viewModel.setGender(val);
            }
          },
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  //  UI HELPERS
  // ═══════════════════════════════════════════════════════════════════

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



  Widget _buildInput(String hint, TextEditingController controller) {
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
        textAlign: TextAlign.center,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: darkBrown,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        style: const TextStyle(
          color: darkBrown,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildNumberInput(String hint, TextEditingController controller,
      {int? maxLength}) {
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
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
        ],
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: darkBrown,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          counterText: '', // hide character counter
        ),
        style: const TextStyle(
          color: darkBrown,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: darkBrown, width: 4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
                color: darkBrown, fontSize: 11, fontWeight: FontWeight.w800),
          ),
          Text(
            value,
            style: const TextStyle(
                color: darkBrown, fontSize: 16, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(String label, VoidCallback? onTap,
      {bool enabled = true}) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.45,
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
      ),
    );
  }

  @override
  LivestockMemberDetailsLivestockAssociateViewModel viewModelBuilder(
          BuildContext context) =>
      LivestockMemberDetailsLivestockAssociateViewModel(
        initialMobile: ownerMobile,
        returnToPreviousFlow: returnToPreviousFlow,
      );

  @override
  void onViewModelReady(
      LivestockMemberDetailsLivestockAssociateViewModel viewModel) {
    viewModel.initialize();
    super.onViewModelReady(viewModel);
  }
}

/// Small helper widget for OTP status display
class _OtpStatusRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _OtpStatusRow(
      {required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 6),
        Text(text,
            style: TextStyle(
                color: color, fontSize: 14, fontWeight: FontWeight.w800)),
      ],
    );
  }
}
