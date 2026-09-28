import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pashudhan_qr/screens/login/otp_verify_viewmodel.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked/stacked.dart';

@FormView(fields: [
  FormTextField(name: 'otp'),
])
class OtpVerifyView extends StackedView<OtpVerifyViewModel> {
  final String phoneNumber;
  final int otpId;

  const OtpVerifyView({
    super.key,
    required this.phoneNumber,
    required this.otpId,
  });

  @override
  Widget builder(
    BuildContext context,
    OtpVerifyViewModel viewModel,
    Widget? child,
  ) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            /// SCROLLABLE MAIN CONTENT
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

                    /// HINDI BANNER
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

                    const SizedBox(height: 24),

                    /// OTP FIELD
                    Center(
                      child: SizedBox(
                        width: 240,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFB4D333),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: const Color(0xFF5C3317),
                              width: 3.0,
                            ),
                          ),
                          child: TextField(
                            onChanged: viewModel.setOtp,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              hintText: '56**',
                              counterText: '',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'Enter OTP Recieved On Mobile',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Color(0xFF5C3317),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// QR IMAGE
                    Image.asset(
                      'assets/scan_qr.png',
                      height: screenHeight * 0.16,
                    ),

                    const SizedBox(height: 20),

                    /// SUBMIT BUTTON
                    GestureDetector(
                      onTap: viewModel.isBusy ? null : viewModel.onVerify,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB4D333),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: const Color(0xFF5C3317),
                            width: 2.0,
                          ),
                        ),
                        child: viewModel.isBusy
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'SUBMIT >',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF5C3317),
                                ),
                              ),
                      ),
                    ),

                    /// RESEND OTP
                    TextButton(
                      onPressed:
                          viewModel.isBusy ? null : viewModel.resendOtp,
                      child: const Text(
                        'Resend OTP',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF5C3317),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            /// FOOTER (always at bottom, fixed)
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
    );
  }

  @override
  OtpVerifyViewModel viewModelBuilder(BuildContext context) =>
      OtpVerifyViewModel(
        phoneNumber: phoneNumber,
        otpId: otpId,
      );
}