// lib/screens/merge_items_screen.dart
// Retroactive batch grouping - key fix over the original MycoFile app.
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/db_service.dart';

class MergeItemsScreen extends StatefulWidget {
  final Batch targetBatch;
  const MergeItemsScreen({super.key, required this.targetBatch});
  @override
  State<MergeItemsScreen> createState() => _MergeItemsScreenState();
}

class _MergeItemsScreenState extends State<MergeItemsScreen> {
  final Set<int> selected = {};

  @override
  Widget build(BuildContext context) {
    final items = DBService.getAllItems().where((i) => i.batchId != widget.targetBatch.id).toList();
    final batches = DBService.getBatches();

    return Scaffold(
      appBar: AppBar(
        title: Text('Merge Into ${widget.targetBatch.label}'),
        actions: [
          TextButton(
            onPressed: selected.isEmpty ? null : _merge,
            child: Text('Merge (${selected.length})'),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, i) {
          final item = items[i];
          final batchLabel = batches.where((b) => b.id == item.batchId).firstOrNull?.label ?? 'No batch';
          final isSelected = selected.contains(item.id);
          return CheckboxListTile(
            value: isSelected,
            title: Text(item.containerType ?? 'Item'),
            subtitle: Text(batchLabel),
            onChanged: (v) => setState(() {
              if (v == true) selected.add(item.id); else selected.remove(item.id);
            }),
          );
        },
      ),
    );
  }

  Future<void> _merge() async {
    await DBService.mergeItemsIntoBatch(widget.targetBatch.id, selected.toList());
    if (mounted) Navigator.pop(context);
  }
}
