import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:right_touch/utils/app_theme.dart';

/// Temporary screen to display and copy the FCM token.
/// Navigate here by tapping 5 times on the app title/logo.
class FcmTokenScreen extends StatefulWidget {
  const FcmTokenScreen({super.key});

  @override
  State<FcmTokenScreen> createState() => _FcmTokenScreenState();
}

class _FcmTokenScreenState extends State<FcmTokenScreen> {
  String _status = 'Fetching FCM token...';
  String? _token;

  @override
  void initState() {
    super.initState();
    _fetchToken();
  }

  Future<void> _fetchToken() async {
    for (int attempt = 1; attempt <= 5; attempt++) {
      try {
        setState(() {
          _status = 'Attempt $attempt of 5...';
        });
        final token = await FirebaseMessaging.instance
            .getToken()
            .timeout(const Duration(seconds: 15));
        if (token != null && token.isNotEmpty) {
          setState(() {
            _token = token;
            _status = 'Token retrieved successfully!';
          });
          return;
        } else {
          setState(() {
            _status = 'Attempt $attempt: Got null/empty token. Retrying in 3s...';
          });
        }
      } catch (e) {
        setState(() {
          _status = 'Attempt $attempt failed: $e\nRetrying in 3s...';
        });
      }
      await Future.delayed(const Duration(seconds: 3));
    }
    setState(() {
      _status = 'Failed after 5 attempts. Make sure:\n'
          '1. Internet (Wi-Fi/Mobile Data) is ON\n'
          '2. Google Play Services is updated\n'
          '3. Firebase project is correctly configured';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FCM Token'),
        backgroundColor: AppTheme.teal,
        foregroundColor: AppTheme.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status
            Card(
              color: _token != null ? AppTheme.green.shade50 : AppTheme.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  _status,
                  style: TextStyle(
                    fontSize: 14,
                    color: _token != null ? AppTheme.green.shade800 : AppTheme.orange.shade800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Token display
            if (_token != null) ...[
              const Text(
                'Your FCM Token:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.grey.shade300),
                ),
                child: SelectableText(
                  _token!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _token!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('FCM Token copied to clipboard!'),
                      backgroundColor: AppTheme.green,
                    ),
                  );
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copy Token'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.teal,
                  foregroundColor: AppTheme.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],

            // Retry button
            if (_token == null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _fetchToken,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.teal,
                  foregroundColor: AppTheme.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
