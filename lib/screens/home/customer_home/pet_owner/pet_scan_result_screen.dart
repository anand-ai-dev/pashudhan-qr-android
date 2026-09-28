import 'package:flutter/material.dart';
import 'package:pashudhan_qr/models/pet_model.dart';

/// Displays the pet details fetched after a QR scan.
class PetScanResultScreen extends StatelessWidget {
  final Pet pet;

  const PetScanResultScreen({super.key, required this.pet});

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
          'Pet Details',
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
            _infoCard('Pet Name', pet.name),
            _infoCard('Pet ID Number', pet.petIdNumber),
            _infoCard('Category', pet.category),
            _infoCard('Breed', pet.breed),
            _infoCard('Weight (kg)', pet.weight.toString()),
            _infoCard('Height (cm)', pet.heightInCms.toString()),
            _infoCard('UUID', pet.uuid),
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
          const Icon(Icons.pets, color: primaryYellow, size: 36),
          const SizedBox(height: 8),
          Text(
            pet.name.isNotEmpty ? pet.name : 'Pet',
            style: const TextStyle(
              color: primaryYellow,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            pet.petIdNumber,
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
