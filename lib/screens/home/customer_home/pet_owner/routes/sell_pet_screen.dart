import 'package:flutter/material.dart';

class SellPetScreen extends StatelessWidget {
  const SellPetScreen({super.key});

  static const Color primaryYellow = Color(0xFFEDC93A);
  static const Color primaryGreen = Color(0xFFA1BC2A);
  static const Color darkBrown = Color(0xFF452B14);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryYellow,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: darkBrown),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Sell Pets',
          style: TextStyle(
            color: darkBrown,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sell, size: 100, color: Color(0xFFA1BC2A)),
            SizedBox(height: 20),
            Text(
              'Sell Pets',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF452B14),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Form to list a pet for sale goes here',
              style: TextStyle(fontSize: 14, color: Color(0xFF452B14)),
            ),
          ],
        ),
      ),
    ));
  }
}
