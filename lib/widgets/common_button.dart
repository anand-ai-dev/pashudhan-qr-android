import 'package:flutter/material.dart';

class CommonButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final bool isBusy;
  
  const CommonButton({
    super.key, 
    required this.title, 
    required this.onPressed,
    this.isBusy = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD4E157), // Light green/yellowish from design
          foregroundColor: Colors.black, // Text color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 4),
        ),
        onPressed: isBusy ? null : onPressed,
        child: isBusy
            ? const Center(child: CircularProgressIndicator.adaptive())
            : Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
