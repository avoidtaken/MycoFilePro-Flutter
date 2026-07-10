// lib/screens/batch_detail_screen.dart
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/db_service.dart';
import '../widgets/status_pill.dart';
import 'merge_items_screen.dart';
import 'new_log_screen.dart';
import 'edit_log_screen.dart';

class BatchDetailScreen extends StatefulWidget {
  final Batch batch;
  const BatchDetailScreen({super.key, required this.batch});
  @override
  State<BatchDetailScreen> createState() => _BatchDetailScreenState();
}

class _BatchDetailScreenState extends State<BatchDetailScreen> {
  final harvestCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final batch = widget.batch;
    final items = DBService.getItemsForBatch(batch.id);
    final strain = batch.strainId != null
        ? DBService.getStrains().where((s) => s.id == batch.strainId).firstOrNull
        : null;
    final allLogs = items.expand((i) => DBService.getLogsForItem(i.id)).toList()
      ..sort((a, b) => b.loggedAt.compareTo(a.loggedAt));

    return Scaffold(
      appBar: AppBar(
        title: Text(batch.label),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'log' && items.isNotEmpty) {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => NewLogScreen(item: items.first)));
              } else if (v == 'harvest') {
                _showHarvestDialog();
              }
              setState(() {});
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'log', child: Text('Log Activity')),
              PopupMenuItem(value: 'harvest', child: Text('Record Harvest')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(strain?.name ?? 'Unknown strain', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 8),
          StatusPill(status: batch.status),
          const SizedBox(height: 16),
          Row(
            children: [
              _stat('Yield', '${batch.totalYieldG.toInt()}g'),
              const SizedBox(width: 24),
              _stat('Items', '${items.length}'),
            ],
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            icon: const Icon(Icons.merge_type),
            label: const Text('Merge existing items into this batch'),
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => MergeItemsScreen(targetBatch: batch)));
              setState(() {});
            },
          ),
          const Divider(height: 32),
          Text('Recent Activity', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...allLogs.map((log) => ListTile(
                leading: Icon(log.source == 'sensor' ? Icons.sensors : Icons.edit_note),
                title: Text(log.type.name),
                subtitle: log.note != null ? Text(log.note!) : null,
                trailing: log.editedAt != null ? const Text('edited', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 11)) : null,
                onTap: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (_) => EditLogScreen(log: log)));
                  setState(() {});
                },
              )),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  void _showHarvestDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Record Harvest'),
        content: TextField(
          controller: harvestCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Weight (grams)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final w = double.tryParse(harvestCtrl.text);
              if (w != null) {
                widget.batch.totalYieldG += w;
                widget.batch.status = BatchStatus.harvested;
                await DBService.updateBatch(widget.batch);
              }
              if (mounted) { Navigator.pop(context); setState(() {}); }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
