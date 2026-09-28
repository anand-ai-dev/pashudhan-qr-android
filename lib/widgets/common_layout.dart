import 'package:flutter/material.dart';
import 'package:pashudhan_qr/app/app.locator.dart';
import 'package:pashudhan_qr/app/app.router.dart';
import 'package:pashudhan_qr/repository/auth_repository.dart';
import 'package:stacked_services/stacked_services.dart';

class CommonLayout extends StatelessWidget {
  final Widget child;
  final bool showBottomImage;
  final Color backgroundColor;
  final String? topBannerText;
  final String? bottomBannerText;

  const CommonLayout({
    super.key,
    required this.child,
    this.showBottomImage = true,
    this.backgroundColor = Colors.white,
    this.topBannerText,
    this.bottomBannerText,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            /// 🔝 TOP IMAGE WITH LOGOUT
            Column(
              children: [
                Stack(
                  children: [
                    SizedBox(
                      width: screenWidth,
                      height: screenHeight * 0.48,
                      child: Image.asset(
                        'assets/header1.png',
                        fit: BoxFit.fill, // full stretch
                      ),
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white),
                        onPressed: () async {
                          final authRepo = locator<AuthRepository>();
                          await authRepo.logout();
                          locator<NavigationService>().clearStackAndShow(Routes.loginView);
                        },
                      ),
                    ),
                  ],
                ),

                /// TOP BANNER
                if (topBannerText != null)
                  Container(
                    width: double.infinity,
                    color: const Color(0xFF8A5A2B),
                    padding: const EdgeInsets.symmetric(
                        vertical: 6.0, horizontal: 8.0),
                    child: Text(
                      topBannerText!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFF9C22E),
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),

            /// 🔸 MAIN CONTENT
            Expanded(
              child: SizedBox(
                width: screenWidth, // 👈 ensures full width
                child: child,
              ),
            ),

            /// 🔻 BOTTOM BANNER
            if (bottomBannerText != null)
              Container(
                width: double.infinity,
                color: const Color(0xFF8A5A2B),
                padding:
                    const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                child: Text(
                  bottomBannerText!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFF9C22E),
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

            /// 🔻 BOTTOM IMAGE (FIXED)
            if (showBottomImage)
              SizedBox(
                width: screenWidth, // 👈 FULL WIDTH GUARANTEED
                height: screenHeight * 0.045,
                child: Image.asset(
                  'assets/bottombar.png', // or bottombar.png if you use that
                  fit:
                      BoxFit.cover, // 👈 BEST for full-width without distortion
                ),
              ),
            SizedBox(
              width: screenWidth, // 👈 FULL WIDTH GUARANTEED
              height: screenHeight * 0.1,
              child: Image.asset(
                'assets/footer.png', // or bottombar.png if you use that
                fit: BoxFit.cover, // 👈 BEST for full-width without distortion
              ),
            ),
          ],
        ),
      ),
    );
  }
}
