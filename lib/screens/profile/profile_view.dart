import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'package:pashudhan_qr/screens/profile/profile_viewmodel.dart';

class ProfileView extends StackedView<ProfileViewModel> {
  const ProfileView({super.key});

  static const Color primaryYellow = Color(0xFFEDC93A);
  static const Color primaryGreen = Color(0xFFA1BC2A);
  static const Color buttonYellow = Color(0xFFF3D133);
  static const Color darkBrown = Color(0xFF452B14);
  static const Color lightBrown = Color(0xFF8A5A2B);
  static const Color cream = Color(0xFFFFF8E7);

  @override
  void onViewModelReady(ProfileViewModel viewModel) => viewModel.init();

  @override
  ProfileViewModel viewModelBuilder(BuildContext context) => ProfileViewModel();

  @override
  Widget builder(
      BuildContext context, ProfileViewModel viewModel, Widget? child) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: cream,
        body: viewModel.isBusy
            ? const Center(child: CircularProgressIndicator(color: darkBrown))
            : CustomScrollView(
                slivers: [
                  // ── Green header with avatar ──────────────────
                  SliverToBoxAdapter(child: _buildHeader(context, viewModel)),

                  // ── Detail cards ──────────────────────────────
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Edit mode
                        if (viewModel.isEditing) ...[
                          _buildEditSection(viewModel),
                        ] else ...[
                          if (viewModel.userRole.toUpperCase() == 'CUSTOMER') ...[
                            _buildDetailTile(
                              icon: Icons.person_rounded,
                              label: 'Full Name',
                              value: (viewModel.customer?.name != null && viewModel.customer!.name.isNotEmpty)
                                  ? viewModel.customer!.name
                                  : viewModel.userName,
                            ),
                            _buildDetailTile(
                              icon: Icons.phone_android_rounded,
                              label: 'Mobile Number',
                              value: (viewModel.customer?.userName != null && viewModel.customer!.userName.isNotEmpty)
                                  ? viewModel.customer!.userName
                                  : viewModel.userPhone,
                            ),
                            _buildDetailTile(
                              icon: Icons.badge_rounded,
                              label: 'Aadhar Number',
                              value: viewModel.customer?.aadharNumber ?? '—',
                            ),
                            _buildDetailTile(
                              icon: Icons.pin_drop_rounded,
                              label: 'Pincode',
                              value: viewModel.customer?.pincode?.toString() ?? '—',
                            ),
                          ] else ...[
                            _buildDetailTile(
                              icon: Icons.person_rounded,
                              label: 'Full Name',
                              value: viewModel.associate?.fullName ??
                                  viewModel.userName,
                            ),
                            _buildDetailTile(
                              icon: Icons.phone_android_rounded,
                              label: 'Mobile Number',
                              value: viewModel.associate?.userName ??
                                  viewModel.userName,
                            ),
                            _buildDetailTile(
                              icon: Icons.badge_rounded,
                              label: 'ID Number',
                              value: viewModel.associate?.idNo ?? '—',
                            ),
                            _buildDetailTile(
                              icon: Icons.verified_rounded,
                              label: 'Approval Status',
                              value: viewModel.associate != null
                                  ? (viewModel.associate!.approved
                                      ? 'Approved'
                                      : 'Pending Review')
                                  : '—',
                              valueColor: viewModel.associate?.approved == true
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFFE65100),
                              trailing: viewModel.associate != null
                                  ? Icon(
                                      viewModel.associate!.approved
                                          ? Icons.check_circle
                                          : Icons.hourglass_top_rounded,
                                      color: viewModel.associate!.approved
                                          ? const Color(0xFF2E7D32)
                                          : const Color(0xFFE65100),
                                      size: 22,
                                    )
                                  : null,
                            ),
                          ],
                          const SizedBox(height: 30),
                          GestureDetector(
                            onTap: viewModel.isBusy
                                ? null
                                : viewModel.deleteAccount,
                            child: Container(
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFDE8E8),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: const Color(0xFFF8B4B4), width: 2.5),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.delete_forever_rounded,
                                      color: Colors.red, size: 24),
                                  SizedBox(width: 8),
                                  Text(
                                    'Deactivate Account',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ]),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  HEADER — curved green card with avatar + name + edit button
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildHeader(BuildContext context, ProfileViewModel viewModel) {
    final displayName = viewModel.userRole.toUpperCase() == 'CUSTOMER'
        ? (viewModel.customer?.name ?? viewModel.userName)
        : (viewModel.associate?.fullName ?? viewModel.userName);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ── Green background ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 16, bottom: 50),
          decoration: const BoxDecoration(
            color: primaryGreen,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
          ),
          child: Column(
            children: [
              // ── Top row: back + title + edit ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: darkBrown, size: 26),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Expanded(
                      child: Text(
                        'My Profile',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: darkBrown,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    if (!viewModel.isEditing && viewModel.userRole.toUpperCase() != 'CUSTOMER')
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: darkBrown,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.edit_rounded,
                              color: primaryYellow, size: 18),
                        ),
                        onPressed: viewModel.startEditing,
                      )
                    else
                      const SizedBox(width: 48),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Avatar circle ──
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: buttonYellow,
                      border: Border.all(color: darkBrown, width: 3.5),
                      boxShadow: [
                        BoxShadow(
                          color: darkBrown.withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: viewModel.isUploadingPic ||
                            viewModel.isDeletingPic ||
                            viewModel.isFetchingPic
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: darkBrown, strokeWidth: 3))
                        : ClipOval(
                            child: viewModel.profilePicBytes != null
                                ? Image.memory(
                                    viewModel.profilePicBytes!,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _defaultAvatar(displayName),
                                  )
                                : _defaultAvatar(displayName),
                          ),
                  ),
                  // Camera button
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: GestureDetector(
                      onTap: () => _showPhotoOptions(context, viewModel),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: darkBrown,
                          shape: BoxShape.circle,
                          border: Border.all(color: primaryYellow, width: 2.5),
                        ),
                        child: const Icon(Icons.camera_alt_rounded,
                            color: primaryYellow, size: 16),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ── Name ──
              Text(
                displayName.isNotEmpty ? displayName : 'User',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: darkBrown,
                ),
              ),

              const SizedBox(height: 6),

              // ── Role badge ──
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                decoration: BoxDecoration(
                  color: darkBrown,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _formatRole(viewModel.userRole),
                  style: const TextStyle(
                    color: primaryYellow,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── "Your Details" label overlapping ──
        Positioned(
          bottom: -18,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 10),
              decoration: BoxDecoration(
                color: darkBrown,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: darkBrown.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                'Your Details',
                style: TextStyle(
                  color: primaryYellow,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  DETAIL TILE — each row of user info
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildDetailTile({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: primaryGreen.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: darkBrown.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon circle
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: primaryGreen.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: darkBrown, size: 20),
          ),
          const SizedBox(width: 14),
          // Label + value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: lightBrown,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: valueColor ?? darkBrown,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  EDIT SECTION — inline edit fields
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildEditSection(ProfileViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryGreen, width: 2),
        boxShadow: [
          BoxShadow(
            color: darkBrown.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.edit_note_rounded, color: primaryGreen, size: 24),
              SizedBox(width: 8),
              Text(
                'Edit Your Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: darkBrown,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _editField(
            label: 'Full Name',
            initialValue: viewModel.editedName,
            icon: Icons.person_rounded,
            onChanged: viewModel.setEditedName,
          ),
          const SizedBox(height: 14),
          _editField(
            label: 'ID Number',
            initialValue: viewModel.editedIdNo,
            icon: Icons.badge_rounded,
            onChanged: viewModel.setEditedIdNo,
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: viewModel.cancelEditing,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(14),
                      border:
                          Border.all(color: Colors.grey.shade300, width: 1.5),
                    ),
                    child: const Center(
                      child: Text('Cancel',
                          style: TextStyle(
                              color: darkBrown,
                              fontWeight: FontWeight.w700,
                              fontSize: 15)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: viewModel.isBusy ? null : viewModel.saveProfile,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: primaryGreen,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: darkBrown, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        viewModel.isBusy ? 'Saving…' : 'Save',
                        style: const TextStyle(
                          color: darkBrown,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _editField({
    required String label,
    required String initialValue,
    required IconData icon,
    required void Function(String) onChanged,
  }) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      style: const TextStyle(
          color: darkBrown, fontWeight: FontWeight.w700, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            const TextStyle(color: lightBrown, fontWeight: FontWeight.w600),
        prefixIcon: Icon(icon, color: primaryGreen, size: 22),
        filled: true,
        fillColor: cream,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryGreen, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: darkBrown, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
              color: primaryGreen.withValues(alpha: 0.5), width: 1.5),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  DEFAULT AVATAR
  // ══════════════════════════════════════════════════════════════════════
  Widget _defaultAvatar(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      width: 120,
      height: 120,
      color: buttonYellow,
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 52,
            fontWeight: FontWeight.w900,
            color: darkBrown,
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  PHOTO OPTIONS — camera / gallery / remove bottom sheet
  // ══════════════════════════════════════════════════════════════════════
  void _showPhotoOptions(BuildContext context, ProfileViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 18),
            const Text('Profile Photo',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: darkBrown)),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _sourceOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  color: primaryGreen,
                  onTap: () {
                    Navigator.pop(context);
                    viewModel.uploadProfilePicFromCamera();
                  },
                ),
                _sourceOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  color: primaryGreen,
                  onTap: () {
                    Navigator.pop(context);
                    viewModel.uploadProfilePicFromGallery();
                  },
                ),
                if (viewModel.profilePicBytes != null)
                  _sourceOption(
                    icon: Icons.delete_outline_rounded,
                    label: 'Remove',
                    color: Colors.red.shade400,
                    onTap: () {
                      Navigator.pop(context);
                      viewModel.deleteProfilePic();
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sourceOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(icon, size: 30, color: color),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  HELPERS
  // ══════════════════════════════════════════════════════════════════════
  String _formatRole(String role) {
    switch (role.toUpperCase()) {
      case 'ASSOCIATE':
        return 'ASSOCIATE';
      case 'CUSTOMER':
        return 'CUSTOMER';
      case 'ADMIN':
        return 'ADMIN';
      default:
        return role.toUpperCase();
    }
  }
}
