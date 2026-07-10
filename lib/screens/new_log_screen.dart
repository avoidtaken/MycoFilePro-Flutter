// lib/screens/new_log_screen.dart
// Editable log creation - pairs with EditLogScreen for the non-destructive fix.
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/db_service.dart';

class NewLogScreen extends StatefulWidget {
  final Item item;
  const NewLogScreen({super.key, required this.item});
  @override
  State<NewLogScreen> createState() => _NewLogScreenState();
}

class _NewLogScreenState extends State<NewLogScreen> {
  ActivityType type = ActivityType.note;
  final noteCtrl = TextEditingController();
  final valueCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final needsValue = type == ActivityType.tempHumidity || type == ActivityType.harvest;
    return Scaffold(
      appBar: AppBar(title: const Text('Log Activity'), actions: [
        TextButton(onPressed: _save, child: const Text('Save')),
      ]),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<ActivityType>(
            value: type,
            decoration: const InputDecoration(labelText: 'Type'),
            items: ActivityType.values
                .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                .toList(),
            onChanged: (v) => setState(() => type = v!),
          ),
          if (needsValue) ...[
            const SizedBox(height: 16),
            TextField(
              controller: valueCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Value (°C, %, or grams)'),
            ),
          ],
          const SizedBox(height: 16),
          TextField(
            controller: noteCtrl,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Note', border: OutlineInputBorder()),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final log = ActivityLog()
      ..itemId = widget.item.id
      ..type = type
      ..note = noteCtrl.text.isEmpty ? null : noteCtrl.text
      ..valueNumeric = double.tryParse(valueCtrl.text);
    await DBService.addLog(log);
    if (mounted) Navigator.pop(context);
  }
}
