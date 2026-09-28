import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'settings_customer_pet_viewmodel.dart';

class SettingsCustomerPet
    extends StackedView<SettingsCustomerPetViewModel> {
  const SettingsCustomerPet({super.key});

  static const Color bgYellow = Color.fromARGB(255, 243, 209, 51);
  static const Color btnGreen = Color(0xFFA1BC2A);
  static const Color darkBrown = Color(0xFF5A391D);
  static const Color iconYellow = Color(0xFFEACA25);

  @override
  Widget builder(
    BuildContext context,
    SettingsCustomerPetViewModel viewModel,
    Widget? child,
  ) {
    return SafeArea(child: Scaffold(
      backgroundColor: bgYellow,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/pattern_bg.png'),
                repeat: ImageRepeat.repeat,
                opacity: 0.10,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),

                Align(
                  alignment: Alignment.topCenter,
                  heightFactor: 0.80, // Reduces the layout height, eliminating the bottom transparent space
                  child: Image.asset(
                    'assets/icons_home/customer/livestock_farmer/settings.png',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.settings,
                      size: 200,
                      color: darkBrown,
                    ),
                  ),
                ),
                SizedBox(height: 40),
                _buildTitleBar(),
                const SizedBox(height: 24),

                _buildProfileRow(viewModel),
                const SizedBox(height: 24),

                _buildRow(
                  icon: Icons.notifications_none,
                  label: 'NOTIFICATIONS',
                  onTap: viewModel.onNotificationsTapped,
                  bgColor: btnGreen,
                  borderColor: darkBrown,
                  iconColor: iconYellow,
                  textColor: darkBrown,
                ),
                const SizedBox(height: 24),

                _buildModeChangeRow(viewModel),
                const SizedBox(height: 24),

                _buildRow(
                  icon: Icons.chat_bubble_outline,
                  label: 'HELP & SUPPORT',
                  onTap: viewModel.onHelpAndSupportTapped,
                  bgColor: btnGreen,
                  borderColor: darkBrown,
                  iconColor: iconYellow,
                  textColor: darkBrown,
                ),

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

  Widget _buildProfileRow(SettingsCustomerPetViewModel viewModel) {
    return GestureDetector(
      onTap: viewModel.onUpdateProfileTapped,
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
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    viewModel.userPhone,
                    style: const TextStyle(
                      color: darkBrown,
                      fontSize: 15,
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

  Widget _buildRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color bgColor,
    required Color borderColor,
    required Color iconColor,
    required Color textColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 65,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: borderColor, width: 3.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 38),
            const SizedBox(width: 20),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 20, 
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeChangeRow(SettingsCustomerPetViewModel viewModel) {
    return Container(
      width: double.infinity,
      height: 65,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: darkBrown,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: btnGreen, width: 3.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.swap_vert, color: btnGreen, size: 42),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'MODE\nCHANGE',
              style: TextStyle(
                color: iconYellow,
                fontSize: 18, 
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
          ),
          Transform.scale(
            scale: 1.5,
            child: Switch(
              value: viewModel.isModeEnabled,
              onChanged: viewModel.toggleMode,
              activeThumbColor: Colors.white,
              activeTrackColor: Colors.green,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(SettingsCustomerPetViewModel viewModel) {
    return GestureDetector(
      onTap: viewModel.onLogoutTapped,
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
  SettingsCustomerPetViewModel viewModelBuilder(BuildContext context) =>
      SettingsCustomerPetViewModel();

  @override
  void onViewModelReady(SettingsCustomerPetViewModel viewModel) {
    viewModel.initialize();
    super.onViewModelReady(viewModel);
  }
}
