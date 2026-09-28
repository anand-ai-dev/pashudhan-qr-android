import 'package:flutter/material.dart';
import 'package:pashudhan_qr/screens/login/login_viewmodel.dart';
import 'package:stacked/stacked.dart';

class LoginView extends StackedView<LoginViewModel> {
  const LoginView({super.key});

  @override
  Widget builder(
    BuildContext context,
    LoginViewModel viewModel,
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
                    /// HEADER IMAGE
                    SizedBox(
                      height: screenHeight * 0.38,
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
                        vertical: 6.0,
                        horizontal: 8.0,
                      ),
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

                    /// PHONE FIELD
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: TextField(
                        onChanged: viewModel.setPhoneNumber,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                        decoration: InputDecoration(
                          hintText: '80910569**',
                          counterText: '',
                          filled: true,
                          fillColor: const Color(0xFFB4D333),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Enter Your Mobile Number',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// GET STARTED BUTTON
                    GestureDetector(
                      onTap: viewModel.isBusy ? null : viewModel.onGetStarted,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: viewModel.isBusy
                              ? const Color(0xFFC8A000)
                              : const Color(0xFFF9C22E),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: viewModel.isBusy
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'GET STARTED',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// CHARACTERS
                    SizedBox(
                      height: screenHeight * 0.20,
                      child: Row(
                        children: [
                          Expanded(
                            child: Image.asset(
                              'assets/women1.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          Expanded(
                            child: Image.asset(
                              'assets/doctor1.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          Expanded(
                            child: Image.asset(
                              'assets/men1.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
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
  void onViewModelReady(LoginViewModel viewModel) => viewModel.init();

  @override
  LoginViewModel viewModelBuilder(BuildContext context) => LoginViewModel();
}