import 'package:flutter/material.dart';
import 'package:right_touch/utils/app_theme.dart';

class LegalPolicyScreen extends StatelessWidget {
  final String title;
  final String content;

  const LegalPolicyScreen({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: AppTheme.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF424242),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: Text(
                "© ${DateTime.now().year} Right Touch. All rights reserved.",
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
