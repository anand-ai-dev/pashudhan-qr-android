import 'package:flutter/material.dart';
import 'package:pashudhan_qr/screens/login/splash_viewmodel.dart';
import 'package:stacked/stacked.dart';

class SplashView extends StackedView<SplashViewModel> {
  final bool skipDelay;

  const SplashView({
    super.key,
    this.skipDelay = false,
  });

  @override
  Widget builder(
    BuildContext context,
    SplashViewModel viewModel,
    Widget? child,
  ) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            /// SCROLLABLE MAIN CONTENT
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    /// HEADER
                    SizedBox(
                      height: screenHeight * 0.40,
                      width: double.infinity,
                      child: Image.asset(
                        'assets/header1.png',
                        fit: BoxFit.fill,
                      ),
                    ),

                    /// HINDI BANNER
                    Container(
                      width: double.infinity,
                      color: const Color.fromARGB(255, 155, 190, 15),
                      padding: const EdgeInsets.symmetric(
                          vertical: 6.0, horizontal: 8.0),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'अब अपने पशुधन की जन्मपत्री अपने हाथ में',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF8A5A2B),
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// QR Section
                    Center(
                      child: Image.asset(
                        'assets/scan_qr.png',
                        height: screenHeight * 0.18,
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// Characters
                    SizedBox(
                      height: screenHeight * 0.22,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            flex: 12,
                            child: Image.asset(
                              'assets/women1.png',
                              fit: BoxFit.contain,
                              alignment: Alignment.bottomCenter,
                            ),
                          ),
                          const Spacer(flex: 2),
                          Expanded(
                            flex: 12,
                            child: Image.asset(
                              'assets/doctor1.png',
                              fit: BoxFit.contain,
                              alignment: Alignment.bottomCenter,
                            ),
                          ),
                          const Spacer(flex: 1),
                          Expanded(
                            flex: 10,
                            child: Image.asset(
                              'assets/men1.png',
                              fit: BoxFit.contain,
                              alignment: Alignment.bottomCenter,
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
  void onViewModelReady(SplashViewModel viewModel) {
    viewModel.init(skipDelay);
  }

  @override
  SplashViewModel viewModelBuilder(BuildContext context) => SplashViewModel();
}
