import 'package:flutter/material.dart';

class BottomCharactersWidget extends StatelessWidget {
  const BottomCharactersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    const double characterHeight = 400;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: SizedBox(
            height: characterHeight,
            child: Image.asset(
              'assets/women1.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        Expanded(
          child: SizedBox(
            height: characterHeight,
            child: Image.asset(
              'assets/doctor1.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        Expanded(
          child: SizedBox(
            height: characterHeight,
            child: Image.asset(
              'assets/men1.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}
