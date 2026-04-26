// lib/screens/home/widgets/deadline_card.dart

import 'package:flutter/material.dart';

class DeadlineCard extends StatelessWidget {
  final String title;
  final VoidCallback onDone;

  const DeadlineCard({
    super.key,
    required this.title,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          ElevatedButton(
            onPressed: onDone,
            child: const Text("Selesai"),
          ),
        ],
      ),
    );
  }
}