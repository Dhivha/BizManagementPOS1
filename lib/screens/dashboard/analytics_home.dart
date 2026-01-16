// Analytics Widget
import 'package:flutter/material.dart';

class AnalyticsWidget extends StatelessWidget {
  const AnalyticsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics, size: 100, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Analytics Coming Soon',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Business analytics will be available here'),
        ],
      ),
    );
  }
}
