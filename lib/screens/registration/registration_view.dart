import 'package:flutter/material.dart';

import 'package:pashudhan_qr/screens/registration/registration_viewmodel.dart';
import 'package:pashudhan_qr/models/role.dart';
import 'package:pashudhan_qr/repository/dto/associate_dtos.dart';
import 'package:pashudhan_qr/services/api_client_service.dart';
import 'package:pashudhan_qr/app/app.locator.dart';
import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher.dart';

class RegistrationView extends StackedView<RegistrationViewModel> {
  final UserRole type;

  const RegistrationView({
    super.key,
    required this.type,
  });

  @override
  Widget builder(
    BuildContext context,
    RegistrationViewModel viewModel,
    Widget? child,
  ) {
    final isAssociate = type == UserRole.ASSOCIATE;
    final isCustomer = type == UserRole.CUSTOMER;
    final isPartner = type == UserRole.PARTNER;

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    const Color headerGreen = Color(0xFF9EAD24);
    const Color themeGold = Color(0xFFE4C025);

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
      body: MediaQuery.removeViewInsets(
        removeBottom: true,
        context: context,
        child: Stack(
          children: [
            Positioned.fill(
              child: Column(
                children: [
                  /// ================= HEADER (FIXED) =================
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                    child: Container(
                      width: double.infinity,
                      height: screenHeight * 0.42,
                      color: isPartner
                          ? const Color.fromARGB(255, 243, 209, 51)
                          : headerGreen,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          /// 🔥 BACKGROUND (UPDATED ONLY THIS PART)
                          Positioned.fill(
                            child: isPartner
                                ? Opacity(
                                    opacity: 0.50,
                                    child: Transform.scale(
                                      scale: 1,
                                      child: Image.asset(
                                        'assets/pattern_bg2.png',
                                        repeat: ImageRepeat.repeat,
                                      ),
                                    ),
                                  )
                                : ColorFiltered(
                                    colorFilter: const ColorFilter.mode(
                                      Color(0xFF9EAD24),
                                      BlendMode.modulate,
                                    ),
                                    child: Opacity(
                                      opacity: 0.50,
                                      child: Transform.scale(
                                        scale: 1,
                                        child: Image.asset(
                                          isAssociate
                                              ? 'assets/pattern_bg1.png'
                                              : 'assets/pattern_bg.png',
                                          repeat: ImageRepeat.repeat,
                                        ),
                                      ),
                                    ),
                                  ),
                          ),

                          Positioned(
                            top: screenHeight * 0.06,
                            child: isPartner
                                ? Image.asset(
                                    'assets/hand_shake.png',
                                    height: screenHeight * 0.24,
                                    fit: BoxFit.contain,
                                  )
                                : Image.asset(
                                    isAssociate
                                        ? 'assets/associate_manager.png'
                                        : 'assets/farmer_petowner.png',
                                    height: screenHeight * 0.235,
                                  ),
                          ),

                          /// TITLE
                          Positioned(
                            bottom: 110,
                            child: Container(
                              width: screenWidth * 0.68,
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: isPartner
                                        ? const Color(0xFF5C3317)
                                        : themeGold,
                                    width: 4),
                              ),
                              child: Text(
                                isPartner
                                    ? 'ASSOCIATE PARTNER'
                                    : isAssociate
                                        ? 'ASSOCIATE'
                                        : 'LIVESTOCK FARMER & PET OWNER',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isPartner
                                      ? const Color(0xFF5C3317)
                                      : headerGreen,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  /// ================= FORM =================
                  Expanded(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.16),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            if (!isPartner) ...[
                              _buildField('Name', viewModel.setName),
                              const SizedBox(height: 14),
                            ],
                            if (isPartner) ...[
                              _buildPartnerField(
                                  'Partner Name', viewModel.setName),
                              const SizedBox(height: 14),
                              _buildPartnerDropdown(viewModel),
                              const SizedBox(height: 14),
                              _buildPartnerField(
                                  'Registration No', viewModel.setIdNo),
                            ] else if (isAssociate) ...[
                              _buildDropdown(viewModel),
                              const SizedBox(height: 14),
                              _buildField('Id NO.', viewModel.setIdNo),
                            ] else if (isCustomer) ...[
                              _buildPincodeField(viewModel),
                              const SizedBox(height: 14),
                              _buildField('Aadhar No.', viewModel.setAadharNo),
                            ],
                            const SizedBox(height: 22),
                            GestureDetector(
                             onTap: () async {
  if (isPartner) {
    final Uri url = Uri.parse(locator<ApiClientService>().baseUrl);

    await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
  } else {
    await viewModel.onSubmit();
  }
},
                              child: Container(
                                width: 160,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: isPartner
                                      ? const Color(0xFF9EAD24)
                                      : themeGold,
                                  borderRadius: BorderRadius.circular(12),
                                  border: isPartner
                                      ? Border.all(
                                          color: const Color(0xFF5C3317),
                                          width: 3)
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    'SUBMIT >',
                                    style: TextStyle(
                                      color: isPartner
                                          ? const Color(0xFF5C3317)
                                          : const Color(0xFF5A4A00),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 160),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// ================= FOOTER =================
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    color: isPartner || isCustomer
                        ? const Color(0xFF8A5A2B)
                        : const Color.fromARGB(255, 155, 190, 15),
                    padding: const EdgeInsets.symmetric(
                        vertical: 6.0, horizontal: 8.0),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'अब अपने पशुधन की जन्मपत्री अपने हाथ में',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isPartner || isCustomer
                              ? const Color(0xFFF9C22E)
                              : const Color(0xFF8A5A2B),
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  Image.asset(
                    'assets/footer.png',
                    width: double.infinity,
                    fit: BoxFit.fill,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildField(String hint, Function(String) onChanged) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4C025), width: 2),
      ),
      child: TextField(
        onChanged: onChanged,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF9EAD24),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xFF9EAD24),
            fontWeight: FontWeight.w600,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildDropdown(RegistrationViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4C025), width: 2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: viewModel.isBusy && viewModel.partners.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(11.0),
              child: Center(
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(color: Color(0xFF9EAD24), strokeWidth: 2.5),
                ),
              ),
            )
          : DropdownButtonFormField<AssociatePartnerResponse>(
              isExpanded: true,
              initialValue: viewModel.selectedPartner,
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFFE4C025)),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 11),
              ),
              hint: const Center(
                child: Text(
                  'Select Partner',
                  style: TextStyle(
                    color: Color(0xFF9EAD24),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              items: viewModel.partners.map((partner) {
                return DropdownMenuItem<AssociatePartnerResponse>(
                  value: partner,
                  child: Center(child: Text(partner.name)),
                );
              }).toList(),
              validator: (value) => value == null ? 'Please select a partner' : null,
              onChanged: (val) {
                if (val != null) {
                  viewModel.setPartner(val);
                }
              },
            ),
    );
  }

  Widget _buildPincodeField(RegistrationViewModel viewModel) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4C025), width: 2),
      ),
      child: TextField(
        onChanged: viewModel.setPinCode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 6,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF9EAD24),
        ),
        decoration: const InputDecoration(
          hintText: 'Pin Code',
          hintStyle: TextStyle(
            color: Color(0xFF9EAD24),
            fontWeight: FontWeight.w600,
          ),
          border: InputBorder.none,
          counterText: '',
        ),
      ),
    );
  }

  Widget _buildPartnerField(String hint, Function(String) onChanged) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF5C3317), width: 3),
      ),
      child: TextField(
        onChanged: onChanged,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          color: Color(0xFF9EAD24),
          fontSize: 20,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xFF9EAD24),
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.only(bottom: 5), // center alignment fix
        ),
      ),
    );
  }


  Widget _buildPartnerDropdown(RegistrationViewModel viewModel) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF5C3317), width: 3),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: viewModel.selectedPartnerType,
          icon: const Icon(Icons.keyboard_arrow_down,
              color: Color(0xFF9EAD24), size: 30),
          hint: const Center(
            child: Text(
              'Partner Type',
              style: TextStyle(
                color: Color(0xFF9EAD24),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          items: const [
            DropdownMenuItem(
              value: 'type1',
              child: Center(
                  child: Text('Type 1',
                      style: TextStyle(
                          color: Color(0xFF9EAD24),
                          fontSize: 20,
                          fontWeight: FontWeight.w800))),
            ),
            DropdownMenuItem(
              value: 'type2',
              child: Center(
                  child: Text('Type 2',
                      style: TextStyle(
                          color: Color(0xFF9EAD24),
                          fontSize: 20,
                          fontWeight: FontWeight.w800))),
            ),
          ],
          onChanged: (val) {
            if (val != null) {
              viewModel.setPartnerType(val);
            }
          },
        ),
      ),
    );
  }

  @override
  void onViewModelReady(RegistrationViewModel viewModel) {
    viewModel.init();
  }

  @override
  RegistrationViewModel viewModelBuilder(BuildContext context) =>
      RegistrationViewModel(type: type);
}
