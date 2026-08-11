import 'package:flutter/material.dart';
import 'package:right_touch/utils/app_theme.dart';

class ServicesTab extends StatelessWidget {
  const ServicesTab({super.key});

  final List<Map<String, dynamic>> _services = const [
    {'name': 'AC Repair', 'icon': Icons.ac_unit, 'price': '₹499'},
    {'name': 'TV Repair', 'icon': Icons.tv, 'price': '₹399'},
    {'name': 'Refrigerator Repair', 'icon': Icons.kitchen, 'price': '₹599'},
    {
      'name': 'Washing Machine',
      'icon': Icons.local_laundry_service,
      'price': '₹699',
    },
    {'name': 'Microwave Repair', 'icon': Icons.microwave, 'price': '₹299'},
    {'name': 'RO Purifier Repair', 'icon': Icons.water_drop, 'price': '₹449'},
    {'name': 'Geyser Repair', 'icon': Icons.whatshot, 'price': '₹349'},
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Available Services",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "You are eligible for the following services",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: _services.length,
                itemBuilder: (context, index) {
                  final service = _services[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            service['icon'],
                            size: 32,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          service['name'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          service['price'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
