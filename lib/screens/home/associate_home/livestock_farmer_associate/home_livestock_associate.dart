import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'home_livestock_associate_viewmodel.dart';
import 'add_livestock_details_livestock_associate.dart';

import 'breeding_details_livestock_associate.dart';
import 'vaccination_details_livestock_associate.dart';
import 'pashudhan_card_livestock_associate.dart';
import 'settings_livestock_associate.dart';
import 'package:pashudhan_qr/widgets/ad_player_widget.dart';

class HomeLivestockAssociate
    extends StackedView<HomeLivestockAssociateViewModel> {
  const HomeLivestockAssociate({super.key});

  // Colors based on the provided image
  static const Color primaryYellow = Color(0xFFEDC93A);
  static const Color primaryGreen = Color(0xFFA1BC2A);
  static const Color buttonYellow = Color(0xFFF3D133);
  static const Color darkBrown = Color(0xFF452B14);
  static const Color notificationRed = Color(0xFFF13E42);

  Widget builder(
    BuildContext context,
    HomeLivestockAssociateViewModel viewModel,
    Widget? child,
  ) {
    final double sw = MediaQuery.of(context).size.width;
    final double sc = sw / 360.0 > 1.25 ? 1.25 : (sw / 360.0 < 0.85 ? 0.85 : sw / 360.0);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(viewModel),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              // Ad Space
              SizedBox(
                height: 135 * sc,
                child: _buildAdSpace(onTap: () {}),
              ),
              const SizedBox(height: 12),

              // Middle Input Row
              SizedBox(
                height: 62 * sc,
                child: _buildMiddleInputRow(context, viewModel),
              ),
              const SizedBox(height: 12),

                // Overview
                _buildSectionTitle('Overview'),
                const SizedBox(height: 4),
                SizedBox(
                  height: 110 * sc,
                  child: _buildOverviewCard(viewModel),
                ),
                const SizedBox(height: 14),

                // Quick Actions
                _buildSectionTitle('Quick Actions'),
                const SizedBox(height: 8),
                _buildQuickActions(context, viewModel),
                const SizedBox(height: 0),
              ],
            ),
          ),
        ),
        ),
        bottomNavigationBar: _buildBottomNav(context, viewModel),
      ),
    );
  }

  @override
  HomeLivestockAssociateViewModel viewModelBuilder(BuildContext context) =>
      HomeLivestockAssociateViewModel();

  @override
  void onViewModelReady(HomeLivestockAssociateViewModel viewModel) {
    // ignore: avoid_print
    print("ASSOCIATE SCREEN LOADED");
    viewModel.initialize();
    super.onViewModelReady(viewModel);
  }

  // --- AppBar ---
  PreferredSizeWidget _buildAppBar(HomeLivestockAssociateViewModel viewModel) {
    return AppBar(
      backgroundColor: primaryYellow,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 90,
      shape: const Border(bottom: BorderSide(color: darkBrown, width: 4.0)),
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
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: darkBrown),
                  ),
                  Text(
                    viewModel.userName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: darkBrown),
                  ),
                  const Text(
                    'ID-123456',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
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
                        Icons.notifications_none_outlined,
                        viewModel.notificationCount),
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
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: primaryGreen,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: darkBrown, width: 2.0),
      ),
      child: Icon(icon, color: darkBrown, size: 30),
    );
  }

  Widget _buildProfileAvatar(HomeLivestockAssociateViewModel viewModel) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: primaryGreen,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: darkBrown, width: 2.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: viewModel.isFetchingPic
            ? const Padding(
                padding: EdgeInsets.all(10.0),
                child:
                    CircularProgressIndicator(color: darkBrown, strokeWidth: 2),
              )
            : viewModel.profilePicBytes != null
                ? Image.memory(
                    viewModel.profilePicBytes!,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.person_outline, color: darkBrown, size: 30),
      ),
    );
  }

  // --- Ad Space ---
  Widget _buildAdSpace({VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: primaryGreen,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: darkBrown, width: 3.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () {},
          borderRadius: BorderRadius.circular(18),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: AdPlayerWidget(
              targetAudience: 'ASSOCIATE',
              apiBaseUrl: 'https://pashudhanqr-api-f5b0885dd324.herokuapp.com',
            ),
          ),
        ),
      ),
    );
  }

  // --- Middle Input Row ---
  Widget _buildMiddleInputRow(
      BuildContext context, HomeLivestockAssociateViewModel viewModel) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: primaryGreen,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: darkBrown, width: 3.0),
            ),
            alignment: Alignment.center,
            child: TextField(
              controller: viewModel.searchController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.phone,
              style: const TextStyle(
                color: darkBrown,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
              decoration: const InputDecoration(
                hintText: 'Enter registered mobile no',
                hintStyle: TextStyle(
                  color: darkBrown,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: () => viewModel.searchCustomer(context),
            child: Container(
              decoration: BoxDecoration(
                color: darkBrown,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: buttonYellow, width: 3.0),
              ),
              child: const Center(
                child: Icon(Icons.search, color: buttonYellow, size: 40),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: () => viewModel.scanQr(context),
            child: Container(
              decoration: BoxDecoration(
                color: buttonYellow,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: darkBrown, width: 3.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Image.asset(
                  'assets/icons_home/customer/pet_owner/qr_image1.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- Common Titles ---
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: darkBrown,
      ),
    );
  }

  // --- Overview Card ---
  Widget _buildOverviewCard(HomeLivestockAssociateViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: BoxDecoration(
        color: primaryGreen,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: darkBrown, width: 3.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Registered Livestocks',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: darkBrown,
                    height: 1.0),
              ),
              // CHANGED from buttonYellow to darkBrown
              Text(
                '${viewModel.totalAnimals}',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: darkBrown,
                    height: 1.0),
              ),
            ],
          ),
          SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child:
                        _buildAnimalCountPill('${viewModel.cowCount}', 'COW')),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildAnimalCountPill(
                        '${viewModel.buffaloCount}', 'BUFFALO')),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildAnimalCountPill(
                        '${viewModel.goatCount}', 'GOAT')),
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
        color: buttonYellow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: darkBrown, width: 2.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            count,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: darkBrown,
                height: 1.0),
          ),
          Text(
            label,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: darkBrown,
                height: 1.0),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(
      BuildContext context, HomeLivestockAssociateViewModel viewModel) {
    return LayoutBuilder(builder: (context, constraints) {
      double totalWidth = constraints.maxWidth;
      // 4 tiles, 3 spaces of 8px
      double tileWidth = (totalWidth - 24) / 4;
      double rowHeight = tileWidth * 1.45; // Dynamic aspect ratio based on tile width

      return Column(
        children: [
          // Row 1
          SizedBox(
            height: rowHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: tileWidth,
                  child: _buildActionTile(
                    imageAsset:
                        'assets/icons_home/customer/livestock_farmer/vaccination_yellow_report.png',
                    label: 'Add Livestock\nVaccination\nReport',
                    bgColor: const Color(0xFFF0D735),
                    borderColor: primaryGreen,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const VaccinationDetailsLivestockAssociate(),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: tileWidth * 2 + 8,
                  child: _buildScanMeWideTile(
                    onTap: () => viewModel.scanMuzzle(context),
                  ),
                ),
                SizedBox(
                  width: tileWidth,
                  child: _buildActionTile(
                    imageAsset:
                        'assets/icons_home/customer/livestock_farmer/breading_report.png',
                    label: 'Add Livestock\nBreeding\nReport',
                    bgColor: const Color(0xFFF0D735),
                    borderColor: primaryGreen,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const BreedingDetailsLivestockAssociate(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Row 2
          SizedBox(
            height: rowHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: tileWidth,
                  child: _buildActionTile(
                    imageAsset:
                        'assets/icons_home/customer/livestock_farmer/health_certificate_green.png',
                    label: 'Add Livestock\nHealth\nCertificate',
                    bgColor: primaryGreen,
                    borderColor: const Color(0xFFF0D735),
                    onTap: () {},
                  ),
                ),
                SizedBox(
                  width: tileWidth,
                  child: _buildActionTile(
                    imageAsset:
                        'assets/icons_home/customer/livestock_farmer/add_livestock_farmer.png',
                    label: 'Add Livestock\nFarmer',
                    bgColor: const Color(0xFFF0D735),
                    borderColor: primaryGreen,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const AddLivestockDetailsLivestockAssociate(),
                      ),
                    ).then((_) => viewModel.refresh()),
                  ),
                ),
                SizedBox(
                  width: tileWidth,
                  child: _buildActionTile(
                    imageAsset:
                        'assets/icons_home/customer/livestock_farmer/pashudhan_qr.png',
                    label: 'Update Livestock\nPashuDhanQR',
                    bgColor: const Color(0xFFF0D735),
                    borderColor: primaryGreen,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PashudhanCardLivestockAssociate(),
                      ),
                    ).then((_) => viewModel.refresh()),
                  ),
                ),
                SizedBox(
                  width: tileWidth,
                  child: _buildActionTile(
                    imageAsset:
                        'assets/icons_home/customer/livestock_farmer/trest_livestock.png',
                    label: 'Coming Soon',
                    bgColor: Colors.white,
                    borderColor: darkBrown,
                    fontSize: 10.0,
                    iconScale: 1.5,
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildActionTile({
    String? imageAsset,
    IconData? icon,
    Widget? customIconWidget,
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
                    child: customIconWidget ??
                        (imageAsset != null
                            ? Image.asset(imageAsset,
                                fit: BoxFit.contain,
                                errorBuilder: (c, e, s) =>
                                    Icon(icon, color: darkBrown))
                            : FittedBox(
                                child:
                                    Icon(icon, color: iconColor ?? darkBrown),
                              )),
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

  Widget _buildScanMeWideTile({VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: primaryGreen,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0D735), width: 3.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? () {},
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 7,
                  // REMOVED 'SCAN ME' custom widget entirely, relying solely on image now!
                  child: Transform.scale(
                    scale: 1.5,
                    child: Image.asset(
                      'assets/icons_home/customer/livestock_farmer/muzzle.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Expanded(
                  flex: 3,
                  child: Text(
                    'Scan Muzzle',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: darkBrown,
                      height: 1.1,
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

  // --- Bottom Nav ---
  Widget _buildBottomNav(
      BuildContext context, HomeLivestockAssociateViewModel viewModel) {
    return Container(
      decoration: const BoxDecoration(
        color: primaryGreen,
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
                  imageAsset:
                      'assets/icons_home/customer/livestock_farmer/home_icon.png',
                  icon: Icons.home_outlined,
                  label: 'Home',
                  fontSize: 16,
                  isActive: true,
                  onTap: () {}), // Already on Home
              _buildNavItem(
                  context: context,
                  imageAsset:
                      'assets/icons_home/customer/livestock_farmer/new_livestock.png',
                  label: 'Add New\nLivestock',
                  fontSize: 14,
                  onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const AddLivestockDetailsLivestockAssociate(),
                        ),
                      ).then((_) => viewModel.refresh())),
              _buildNavItem(
                  context: context,
                  imageAsset:
                      'assets/icons_home/customer/livestock_farmer/update_livestock.png',
                  label: 'Update Livestock\nOwnership',
                  fontSize: 10.5,
                  onTap: () {}),
              _buildNavItem(
                  context: context,
                  imageAsset:
                      'assets/icons_home/customer/livestock_farmer/settings.png',
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  fontSize: 16,
                  onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SettingsLivestockAssociate()),
                      )),
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
      child: SizedBox(
        width: itemSize,
        height: itemSize,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFF0D735),
            borderRadius: BorderRadius.circular(22 * scale),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
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
              const SizedBox(height: 3),
              FittedBox(
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
            ],
          ),
        ),
      ),
    );
  }
}
