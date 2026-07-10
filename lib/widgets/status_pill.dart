// lib/widgets/status_pill.dart
import 'package:flutter/material.dart';
import '../models/models.dart';

Color statusColor(BatchStatus s) {
  switch (s) {
    case BatchStatus.incubating: return Colors.orange;
    case BatchStatus.fruiting: return Colors.green;
    case BatchStatus.harvested: return Colors.blue;
    case BatchStatus.contaminated: return Colors.red;
    case BatchStatus.retired: return Colors.grey;
  }
}

class StatusPill extends StatelessWidget {
  final BatchStatus status;
  const StatusPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
      child: Text(
        status.name[0].toUpperCase() + status.name.substring(1),
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
