// lib/screens/edit_log_screen.dart
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/db_service.dart';

class EditLogScreen extends StatefulWidget {
  final ActivityLog log;
  const EditLogScreen({super.key, required this.log});
  @override
  State<EditLogScreen> createState() => _EditLogScreenState();
}

class _EditLogScreenState extends State<EditLogScreen> {
  late TextEditingController noteCtrl;
  late TextEditingController valueCtrl;

  @override
  void initState() {
    super.initState();
    noteCtrl = TextEditingController(text: widget.log.note ?? '');
    valueCtrl = TextEditingController(text: widget.log.valueNumeric?.toString() ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Log'), actions: [
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () async {
            await DBService.softDeleteLog(widget.log);
            if (mounted) Navigator.pop(context);
          },
        ),
        TextButton(onPressed: _save, child: const Text('Save')),
      ]),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: valueCtrl, decoration: const InputDecoration(labelText: 'Value')),
          const SizedBox(height: 16),
          TextField(controller: noteCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Note')),
          if (widget.log.editedAt != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text('Last edited ${widget.log.editedAt}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    await DBService.editLog(widget.log, note: noteCtrl.text, value: double.tryParse(valueCtrl.text));
    if (mounted) Navigator.pop(context);
  }
}
