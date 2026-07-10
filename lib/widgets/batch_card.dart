// lib/widgets/batch_card.dart
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/db_service.dart';
import 'status_pill.dart';

class BatchCard extends StatelessWidget {
  final Batch batch;
  final VoidCallback onTap;
  const BatchCard({super.key, required this.batch, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final strain = batch.strainId != null
        ? DBService.getStrains().where((s) => s.id == batch.strainId).firstOrNull
        : null;
    final itemCount = DBService.getItemsForBatch(batch.id).length;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(batch.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(strain?.name ?? 'Unknown strain',
                            style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      ],
                    ),
                  ),
                  StatusPill(status: batch.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.scale, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text('${batch.totalYieldG.toInt()}g', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  const SizedBox(width: 16),
                  const Spacer(),
                  Text('$itemCount item${itemCount == 1 ? "" : "s"}',
                      style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
