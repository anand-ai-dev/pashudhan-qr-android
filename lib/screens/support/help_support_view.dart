import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportView extends StatelessWidget {
  const HelpSupportView({super.key});

  static const Color primaryYellow = Color(0xFFEDC93A);
  static const Color primaryGreen = Color(0xFFA1BC2A);
  static const Color buttonYellow = Color(0xFFF3D133);
  static const Color darkBrown = Color(0xFF452B14);
  static const Color lightBrown = Color(0xFF8A5A2B);
  static const Color cream = Color(0xFFFFF8E7);

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _sendEmail(String emailAddress) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: emailAddress,
      queryParameters: {
        'subject': 'Support Request - Pashudhan QR',
      },
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: cream,
        body: CustomScrollView(
          slivers: [
            // Curved Header
            SliverToBoxAdapter(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 16, bottom: 50),
                    decoration: const BoxDecoration(
                      color: primaryGreen,
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
                    ),
                    child: Column(
                      children: [
                        // Back + Title Row
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back_rounded, color: darkBrown, size: 26),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              const Expanded(
                                child: Text(
                                  'Help & Support',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: darkBrown,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 48), // Spacer to balance the back button
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Support Headset Icon
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: buttonYellow,
                            border: Border.all(color: darkBrown, width: 3.5),
                            boxShadow: [
                              BoxShadow(
                                color: darkBrown.withValues(alpha: 0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.headset_mic_rounded,
                            color: darkBrown,
                            size: 52,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'How can we help you?',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: darkBrown,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40.0),
                          child: Text(
                            'Reach out to our support team for any queries or technical assistance.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: darkBrown,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Overlapping label
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
                          'Support Contacts',
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
              ),
            ),

            // Support Contact Cards
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 45, 20, 30),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Phone Card 1
                  _buildContactCard(
                    icon: Icons.phone_android_rounded,
                    label: 'Call Us',
                    value: '8222012356',
                    onTap: () => _makePhoneCall('8222012356'),
                  ),
                  const SizedBox(height: 16),
                  // Phone Card 2
                  _buildContactCard(
                    icon: Icons.phone_android_rounded,
                    label: 'Call Us',
                    value: '8059512356',
                    onTap: () => _makePhoneCall('8059512356'),
                  ),
                  const SizedBox(height: 16),
                  // Email Card
                  _buildContactCard(
                    icon: Icons.email_rounded,
                    label: 'Email Us',
                    value: 'info@pashudhanqr.com',
                    onTap: () => _sendEmail('info@pashudhanqr.com'),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryGreen.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: darkBrown.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Row(
              children: [
                // Icon circle
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: primaryGreen.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: darkBrown, size: 22),
                ),
                const SizedBox(width: 16),
                // Label + value
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: lightBrown,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: darkBrown,
                        ),
                      ),
                    ],
                  ),
                ),
                // Actions indicator arrow
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: lightBrown,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
