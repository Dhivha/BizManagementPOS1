// Business List Widget
import 'package:flutter/material.dart';

class BusinessListWidget extends StatelessWidget {
  const BusinessListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.business, size: 100, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No businesses yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Add your first business to get started'),
        ],
      ),
    );
  }
}
