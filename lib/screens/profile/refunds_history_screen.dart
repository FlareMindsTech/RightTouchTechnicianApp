import 'package:flutter/material.dart';
import 'package:right_touch/utils/app_theme.dart';
import 'package:right_touch/widgets/empty_state.dart';

class RefundsHistoryScreen extends StatelessWidget {
  const RefundsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        title: const Text(
          "Refunds History",
          style: TextStyle(
            color: AppTheme.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppTheme.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: EmptyState(
            icon: Icons.currency_exchange_rounded,
            title: "No Refunds Deducted",
            subtitle:
                "Great job! There are no customer refunds or deductions on your account.",
          ),
        ),
      ),
    );
  }
}

