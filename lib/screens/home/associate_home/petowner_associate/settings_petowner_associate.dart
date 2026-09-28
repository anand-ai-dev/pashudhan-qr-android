import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'settings_petowner_associate_viewmodel.dart';

class SettingsPetOwnerAssociate extends StackedView<SettingsPetOwnerAssociateViewModel> {
  const SettingsPetOwnerAssociate({super.key});

  static const Color bgYellow = Color.fromARGB(255, 243, 209, 51);
  static const Color btnGreen = Color(0xFFA1BC2A);
  static const Color darkBrown = Color(0xFF5A391D);
  static const Color iconYellow = Color(0xFFEACA25);

  @override
  Widget builder(
    BuildContext context,
    SettingsPetOwnerAssociateViewModel viewModel,
    Widget? child,
  ) {
    return SafeArea(child: Scaffold(
      backgroundColor: bgYellow,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/pattern_bg.png'),
            repeat: ImageRepeat.repeat,
            opacity: 0.10,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),

                Align(
                  alignment: Alignment.topCenter,
                  heightFactor: 0.80,
                  child: Image.asset(
                    'assets/icons_home/customer/pet_owner/settings.png',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.settings_outlined,
                      size: 200,
                      color: darkBrown,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                _buildTitleBar(),
                const SizedBox(height: 24),

                _buildProfileRow(viewModel),
                const SizedBox(height: 24),

                _buildNotificationsRow(viewModel),
                const SizedBox(height: 24),

                _buildHelpRow(viewModel),

                const SizedBox(height: 32),

                _buildLogoutButton(viewModel),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    ));
  }

  Widget _buildTitleBar() {
    return Container(
      width: double.infinity,
      height: 65,
      decoration: BoxDecoration(
        color: darkBrown,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: btnGreen, width: 3.5),
      ),
      child: const Center(
        child: Text(
          'SETTINGS',
          style: TextStyle(
            color: iconYellow,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileRow(SettingsPetOwnerAssociateViewModel viewModel) {
    return GestureDetector(
      onTap: viewModel.updateProfile,
      child: Container(
        width: double.infinity,
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: btnGreen,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: darkBrown, width: 3.5),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: iconYellow, width: 2.5),
              ),
              child:
                  const Icon(Icons.person_outline, color: iconYellow, size: 40),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    viewModel.userName.toUpperCase(),
                    style: const TextStyle(
                      color: darkBrown,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    viewModel.userPhone,
                    style: const TextStyle(
                      color: darkBrown,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.settings, color: iconYellow, size: 30),
                const SizedBox(height: 2),
                const Text(
                  'UPDATE PROFILE',
                  style: TextStyle(
                    color: darkBrown,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsRow(SettingsPetOwnerAssociateViewModel viewModel) {
    return GestureDetector(
      onTap: viewModel.notifications,
      child: Container(
        width: double.infinity,
        height: 65,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: btnGreen,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: darkBrown, width: 3.5),
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_none, color: iconYellow, size: 38),
                Positioned(
                  right: 2,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: bgYellow,
                      shape: BoxShape.circle,
                      border: Border.all(color: darkBrown, width: 1.2),
                    ),
                    child: const Text('1', style: TextStyle(color: darkBrown, fontSize: 8, fontWeight: FontWeight.bold, height: 1)),
                  ),
                ),
              ],
            ),
            const Expanded(
              child: Center(
                child: Text(
                  'NOTIFICATIONS',
                  style: TextStyle(
                    color: darkBrown,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 38),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpRow(SettingsPetOwnerAssociateViewModel viewModel) {
    return GestureDetector(
      onTap: viewModel.helpAndSupport,
      child: Container(
        width: double.infinity,
        height: 65,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: btnGreen,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: darkBrown, width: 3.5),
        ),
        child: Row(
          children: [
            const Icon(Icons.forum_outlined, color: iconYellow, size: 38),
            const Expanded(
              child: Center(
                child: Text(
                  'HELP & SUPPORT',
                  style: TextStyle(
                    color: darkBrown,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 38),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(SettingsPetOwnerAssociateViewModel viewModel) {
    return GestureDetector(
      onTap: viewModel.logout,
      child: Container(
        width: 230,
        height: 65,
        decoration: BoxDecoration(
          color: darkBrown,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: btnGreen, width: 3.5),
        ),
        child: const Center(
          child: Text(
            'LOGOUT',
            style: TextStyle(
              color: iconYellow,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  @override
  SettingsPetOwnerAssociateViewModel viewModelBuilder(BuildContext context) =>
      SettingsPetOwnerAssociateViewModel();

  @override
  void onViewModelReady(SettingsPetOwnerAssociateViewModel viewModel) {
    viewModel.initialize();
    super.onViewModelReady(viewModel);
  }
}




