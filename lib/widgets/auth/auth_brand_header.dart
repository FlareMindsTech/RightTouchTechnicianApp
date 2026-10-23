import 'package:flutter/material.dart';

class AuthBrandHeader extends StatelessWidget {
  const AuthBrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "RIGHT TOUCH",
          style: TextStyle(
            color: Color(0xFF00B050),
            fontWeight: FontWeight.w900,
            fontSize: 30,
            letterSpacing: 1.5,
            height: 1.0,
          ),
        ),
        SizedBox(height: 6),
        Text(
          "P A R T N E R",
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 8.0,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}
