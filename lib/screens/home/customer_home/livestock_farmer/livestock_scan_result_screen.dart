import 'package:flutter/material.dart';
import 'package:pashudhan_qr/models/pashudhan_model.dart';

/// Displays the livestock details fetched after a QR scan.
/// Receives the already-fetched [pashudhan] object from the calling screen.
class LivestockScanResultScreen extends StatelessWidget {
  final Pashudhan pashudhan;

  const LivestockScanResultScreen({super.key, required this.pashudhan});

  static const Color primaryYellow = Color(0xFFEDC93A);
  static const Color primaryGreen = Color(0xFFA1BC2A);
  static const Color darkBrown = Color(0xFF452B14);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryGreen,
      appBar: AppBar(
        backgroundColor: darkBrown,
        title: const Text(
          'Livestock Details',
          style: TextStyle(
            color: primaryYellow,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: primaryYellow),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _header(),
            const SizedBox(height: 20),
            _infoCard('Animal Name', pashudhan.name),
            _infoCard('Ear Tag Number', pashudhan.earTagNumber),
            _infoCard('Category', pashudhan.category),
            _infoCard('Breed', pashudhan.breed),
            _infoCard('Age (months)', pashudhan.ageInMonths.toString()),
            _infoCard('Weight (kg)', pashudhan.weight.toString()),
            _infoCard('Lactation No.', pashudhan.lactationNumber.toString()),
            const SizedBox(height: 12),
            const Text(
              'Owner Details',
              style: TextStyle(
                color: darkBrown,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            _infoCard('Name', pashudhan.ownerName ?? '—'),
            _infoCard('Phone Number', pashudhan.ownerPhone ?? '—'),
            _infoCard('Location', pashudhan.ownerLocation ?? '—'),
            const SizedBox(height: 12),
            _infoCard('UUID', pashudhan.uuid),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: darkBrown,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primaryYellow, width: 2.5),
      ),
      child: Column(
        children: [
          const Icon(Icons.verified, color: primaryYellow, size: 36),
          const SizedBox(height: 8),
          Text(
            pashudhan.name.isNotEmpty ? pashudhan.name : 'Livestock',
            style: const TextStyle(
              color: primaryYellow,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            pashudhan.earTagNumber,
            style: const TextStyle(
              color: Color(0xFFD4B83B),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: primaryYellow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: darkBrown, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: darkBrown,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value.isNotEmpty ? value : '—',
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF678122),
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
