import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:right_touch/utils/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class ArrivalAssistanceSheet extends StatelessWidget {
  final String customerName;
  final String? customerPhone;
  final String location;

  const ArrivalAssistanceSheet({
    super.key,
    required this.customerName,
    this.customerPhone,
    required this.location,
  });

  static Future<void> show(
    BuildContext context, {
    required String customerName,
    String? customerPhone,
    required String location,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ArrivalAssistanceSheet(
        customerName: customerName,
        customerPhone: customerPhone,
        location: location,
      ),
    );
  }

  Future<void> _makeCall(BuildContext context) async {
    if (customerPhone == null || customerPhone!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Customer phone number not available")),
      );
      return;
    }
    final uri = Uri.parse('tel:$customerPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendSms(BuildContext context, String message) async {
    if (customerPhone == null || customerPhone!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Customer phone number not available")),
      );
      return;
    }
    final cleanPhone = customerPhone!.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('sms:$cleanPhone?body=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWhatsApp(BuildContext context, String message) async {
    if (customerPhone == null || customerPhone!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Customer phone number not available")),
      );
      return;
    }
    String phone = customerPhone!.replaceAll(RegExp(r'[^0-9]'), '');
    if (!phone.startsWith('91') && phone.length == 10) {
      phone = '91$phone';
    }
    final uri = Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _sendSms(context, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final templates = [
      "👋 Hello $customerName, I am your technician from Right Touch. I have arrived outside your location.",
      "📍 Hi, I am at $location. Could you please confirm your flat number or gate entry code?",
      "⏳ Hello, I am waiting at the door. Please let me know once you are ready for the service.",
      "🛵 Stuck in heavy traffic nearby. Arriving in approximately 10 minutes.",
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.support_agent_rounded,
                    color: AppTheme.primaryColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Arrival Assistance",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.black,
                      ),
                    ),
                    Text(
                      "Contact $customerName or report arrival difficulty",
                      style: TextStyle(fontSize: 12, color: AppTheme.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Call button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _makeCall(context),
              icon: const Icon(Icons.call_rounded, size: 18),
              label: Text("Call $customerName (${customerPhone ?? 'Direct'})"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.green,
                foregroundColor: AppTheme.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            "Quick 1-Tap Messages (WhatsApp / SMS)",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 8),

          ...templates.map((msg) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      msg,
                      style: const TextStyle(fontSize: 12.5, height: 1.3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.message_outlined, size: 20, color: Color(0xFF1976D2)),
                    tooltip: "Send SMS",
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _sendSms(context, msg);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline_rounded,
                        size: 20, color: Color(0xFF25D366)),
                    tooltip: "Send WhatsApp",
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _openWhatsApp(context, msg);
                    },
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 12),

          // Emergency / Unreachable Alert Notice
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFE0B2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: Color(0xFFEF6C00), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Customer not responding? Please wait at least 10 minutes at the location before contacting support.",
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Colors.brown.shade800,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

