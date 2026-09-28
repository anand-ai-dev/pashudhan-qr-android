import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'home_customer_pet_viewmodel.dart';
import 'package:pashudhan_qr/screens/home/customer_home/pet_owner/reminders_customer_pet.dart';
import 'package:pashudhan_qr/screens/home/customer_home/pet_owner/vaccination_details_customer_pet.dart';
import 'pashudhan_card_customer_pet.dart';
import 'breeding_details_customer_pet.dart';
import 'settings_customer_pet.dart';
import 'deworming_details_customer_pet.dart';
import 'routes/health_report_pet_screen.dart';
import 'routes/buy_pet_screen.dart';
import 'routes/sell_pet_screen.dart';
import 'package:pashudhan_qr/widgets/ad_player_widget.dart';

class HomeCustomerPet extends StackedView<HomeCustomerPetViewModel> {
  const HomeCustomerPet({super.key});

  // Colors based on the provided image
  static const Color primaryYellow = Color(0xFFEDC93A);
  static const Color primaryGreen = Color(0xFFA1BC2A);
  static const Color buttonYellow = Color(0xFFF3D133);
  static const Color darkBrown = Color(0xFF452B14);
  static const Color notificationRed = Color(0xFFF13E42);

  @override
  Widget builder(
    BuildContext context,
    HomeCustomerPetViewModel viewModel,
    Widget? child,
  ) {
    return SafeArea(child: Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(viewModel),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 130,
                  child: _buildAdSpace(onTap: () {}),
                ),
                const SizedBox(height: 12),
                _buildSectionTitle('Overview'),
                const SizedBox(height: 6),
                SizedBox(
                  height: 110,
                  child: _buildOverviewCard(viewModel),
                ),
                const SizedBox(height: 12),
                _buildSectionTitle('Quick Actions'),
                const SizedBox(height: 8),
                SizedBox(
                  height: 220,
                  child: _buildQuickActions(context, viewModel),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 55,
                  child: _buildOtherServices(context, viewModel),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, viewModel),
    ));
  }

  @override
  HomeCustomerPetViewModel viewModelBuilder(BuildContext context) =>
      HomeCustomerPetViewModel();

  @override
  void onViewModelReady(HomeCustomerPetViewModel viewModel) {
    viewModel.initialize();
    super.onViewModelReady(viewModel);
  }

  // --- AppBar ---
  PreferredSizeWidget _buildAppBar(HomeCustomerPetViewModel viewModel) {
    return AppBar(
      backgroundColor: primaryYellow,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 70,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: darkBrown),
                  ),
                  Text(
                    viewModel.userName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: darkBrown),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: viewModel.onNotificationIconTapped,
                    child: _buildTopIconWithBadge(
                        Icons.notifications_none_outlined, viewModel.notificationCount),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: viewModel.onProfileIconTapped,
                    child: _buildProfileAvatar(viewModel),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopIconWithBadge(IconData icon, int count) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _buildTopIcon(icon),
        if (count > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                color: notificationRed,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
              ),
            ),
          )
      ],
    );
  }

  Widget _buildTopIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: primaryGreen,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: darkBrown, width: 1.5),
      ),
      child: Icon(icon, color: darkBrown, size: 26),
    );
  }

  Widget _buildProfileAvatar(HomeCustomerPetViewModel viewModel) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: primaryGreen,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: darkBrown, width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: viewModel.isFetchingPic
            ? const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(
                    color: darkBrown, strokeWidth: 2),
              )
            : viewModel.profilePicBytes != null
                ? Image.memory(
                    viewModel.profilePicBytes!,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.person_outline, color: darkBrown, size: 26),
      ),
    );
  }

  Widget _buildAdSpace({VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: primaryGreen, // Green for Pet Owner mock
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: darkBrown, width: 2.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () {},
          borderRadius: BorderRadius.circular(18),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: const AdPlayerWidget(
              targetAudience: 'PET_CUSTOMER',
              apiBaseUrl: 'https://pashudhanqr-api-f5b0885dd324.herokuapp.com',
            ),
          ),
        ),
      ),
    );
  }

  // --- Common Titles ---
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: darkBrown,
      ),
    );
  }

  // --- Overview Card ---
  Widget _buildOverviewCard(HomeCustomerPetViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: primaryYellow, // yellow in Pet Owner mock
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: darkBrown, width: 2.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Registered Pets', // Different text
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: darkBrown),
          ),
          Text(
            viewModel.totalPets.toString().padLeft(2, '0'), // '03'
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: darkBrown), // Number is brown
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: _buildAnimalCountPill('${viewModel.maleDogCount}', 'Male Dog')),
                const SizedBox(width: 8),
                Expanded(child: _buildAnimalCountPill('${viewModel.femaleDogCount}', 'Female Dog')),
                const SizedBox(width: 8),
                Expanded(child: _buildAnimalCountPill('${viewModel.catCount}', 'CAT')),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAnimalCountPill(String count, String label) {
    return Container(
      decoration: BoxDecoration(
        color: primaryGreen, // Green backgrounds in pill for Pet Owner
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: darkBrown, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      count,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w900, color: darkBrown, height: 1.0),
                    ),
                  ),
                ),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w900, color: darkBrown, height: 1.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Quick Actions Grid ---
  Widget _buildQuickActions(BuildContext context, HomeCustomerPetViewModel viewModel) {
    return Column(
      children: [
        // Row 1 (3 items uniformly)
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildActionTile(
                  imageAsset: 'assets/icons_home/customer/pet_owner/pashudhan_qr_petowner.png',
                  label: 'Get Pashudhan QR\nReport of your Pet',
                  bgColor: primaryGreen,
                  borderColor: darkBrown,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PashudhanCardCustomerPet())),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionTile(
                  imageAsset: 'assets/icons_home/customer/pet_owner/pet_breading_report.png',
                  label: 'Get Breeding\nReport of Your Pet',
                  bgColor: buttonYellow,
                  borderColor: darkBrown,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BreedingDetailsCustomerPet())),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionTile(
                  imageAsset: 'assets/icons_home/customer/pet_owner/vaccination_yellow_report.png',
                  label: 'Get Vaccination\nReport of Your Pet',
                  bgColor: primaryGreen,
                  borderColor: darkBrown,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VaccinationDetailsCustomerPet())),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Row 2
        Expanded(
          child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _buildActionTile(
                      imageAsset: 'assets/icons_home/customer/pet_owner/pet_deworming_report.png',
                      label: 'Get Deworming\nReport of Your Pet',
                      bgColor: buttonYellow,
                      borderColor: darkBrown,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DewormingDetailsCustomerPet())),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildActionTile(
                      imageAsset: 'assets/icons_home/customer/pet_owner/health_report.png',
                      label: 'Get Health\nReport of Your Pet',
                      bgColor: primaryGreen,
                      borderColor: darkBrown,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HealthReportPetScreen())),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildActionTile(
                      imageAsset:
                          'assets/icons_home/customer/pet_owner/trest_livestock.png',
                      label: 'Coming Soon',
                      bgColor: Colors.white,
                      borderColor: darkBrown,
                      iconScale: 1.5,
                      fontSize: 13.0,
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
  }

  Widget _buildActionTile({
    String? imageAsset,
    IconData? icon,
    required String label,
    required Color bgColor,
    required Color borderColor,
    Color? iconColor,
    VoidCallback? onTap,
    double iconScale = 1.0,
    double fontSize = 11.0,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 2.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () {},
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
               children: [
                Expanded(
                  flex: 5,
                  child: Transform.scale(
                    scale: iconScale,
                    child: imageAsset != null
                        ? Image.asset(imageAsset, fit: BoxFit.contain)
                        : FittedBox(
                            child: Icon(icon, color: iconColor ?? darkBrown),
                          ),
                  ),
                ),
                const SizedBox(height: 2),
                Expanded(
                  flex: 2,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w800,
                        color: darkBrown,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Other Services (Bottom Row) ---
  Widget _buildOtherServices(BuildContext context, HomeCustomerPetViewModel viewModel) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _buildServicePill(
                  imageAsset: 'assets/icons_home/customer/pet_owner/pets_insurence.png',
                  label: 'Pets\nInsurance', 
                  bgColor: primaryGreen, 
                  onTap: () {}
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildServicePill(
                  imageAsset: 'assets/icons_home/customer/pet_owner/pets_show.png',
                  label: 'Pets\nShow', 
                  bgColor: buttonYellow, 
                  centerContent: true,
                  onTap: () {}
                ),
              ),
              const SizedBox(width: 8),
        Expanded(
          child: _buildServicePill(
            imageAsset: 'assets/icons_home/customer/pet_owner/reminder_pets.png',
            label: 'Reminder\nfor pets', 
            bgColor: primaryGreen, 
            notificationCount: viewModel.notificationCount, 
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RemindersCustomerPetScreen()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildServicePill({
    String? imageAsset,
    IconData? icon,
    required String label,
    required Color bgColor,
    VoidCallback? onTap,
    int? notificationCount,
    bool centerContent = false,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: double.infinity,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: darkBrown, width: 2.5),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap ?? () {},
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    centerContent
                       ? Flexible(
                          flex: 4,
                          child: Transform.scale(
                            scale: 1.2,
                            child: imageAsset != null
                                ? Image.asset(imageAsset, fit: BoxFit.contain)
                                : FittedBox(
                                    child: Icon(icon, color: darkBrown),
                                  ),
                          ),
                        )
                       : Expanded(
                          flex: 4,
                          child: Transform.scale(
                            scale: 1.2,
                            child: imageAsset != null
                                ? Image.asset(imageAsset, fit: BoxFit.contain)
                                : FittedBox(
                                    child: Icon(icon, color: darkBrown),
                                  ),
                          ),
                        ),
                    const SizedBox(width: 4),
                    centerContent
                       ? Flexible(
                          flex: 5,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.center,
                            child: Text(
                              label,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13, // Matched farmer size!
                                fontWeight: FontWeight.w800,
                                color: darkBrown,
                                height: 1.1,
                              ),
                            ),
                          ),
                        )
                       : Expanded(
                          flex: 5,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              label,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13, // Matched farmer size!
                                fontWeight: FontWeight.w800,
                                color: darkBrown,
                                height: 1.1,
                              ),
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (notificationCount != null && notificationCount > 0)
          Positioned(
            right: -2,
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: notificationRed,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$notificationCount',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold),
              ),
            ),
          )
      ],
    );
  }

  // --- Bottom Nav ---
  Widget _buildBottomNav(BuildContext context, HomeCustomerPetViewModel viewModel) {
    return Container(
      decoration: const BoxDecoration(
        color: primaryGreen, // Green for Pet Owner mock bottom nav
        border: Border(top: BorderSide(color: darkBrown, width: 4.0)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: SafeArea(
        child: SizedBox(
          height: 90,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(
                  context: context,
                  imageAsset: 'assets/icons_home/customer/pet_owner/home_icon.png',
                  label: 'Home',
                  fontSize: 16,
                  isActive: true,
                  onTap: () {}),
              _buildNavItem(
                  context: context,
                  imageAsset: 'assets/icons_home/customer/pet_owner/buy_pets.png',
                  label: 'Buy Pets',
                  fontSize: 14,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BuyPetScreen()))),
              _buildNavItem(
                  context: context,
                  imageAsset: 'assets/icons_home/customer/pet_owner/sell_pets.png',
                  label: 'Sell Pets',
                  fontSize: 14,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SellPetScreen()))),
              _buildNavItem(
                  context: context,
                  imageAsset: 'assets/icons_home/customer/pet_owner/settings.png',
                  label: 'Setting',
                  fontSize: 16,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsCustomerPet()))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    String? imageAsset,
    IconData? icon,
    required String label,
    required double fontSize,
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    final double screenWidth = MediaQuery.of(context).size.width;
    // Account for 24px total horizontal padding and 8px spacing between the 4 buttons (3 gaps)
    double itemSize = (screenWidth - 24 - (3 * 8.0)) / 4;
    if (itemSize > 88) {
      itemSize = 88;
    }
    final double scale = itemSize / 88.0;

    return GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
        width: itemSize,
        height: itemSize,
        padding: EdgeInsets.all(4 * scale),
        decoration: BoxDecoration(
          color: primaryYellow,
          borderRadius: BorderRadius.circular(22 * scale),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 5,
              child: Center(
                child: imageAsset != null
                    ? Image.asset(
                        imageAsset,
                        width: 48 * scale,
                        height: 48 * scale,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(icon, color: darkBrown, size: 48 * scale),
                      )
                    : Icon(icon, color: darkBrown, size: 48 * scale),
              ),
            ),
            SizedBox(height: 3 * scale),
            Expanded(
              flex: 4,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: fontSize * scale,
                      fontWeight: FontWeight.w900,
                      color: darkBrown,
                      height: 1.05,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}