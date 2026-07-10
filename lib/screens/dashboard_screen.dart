// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/db_service.dart';
import '../widgets/batch_card.dart';
import '../widgets/status_pill.dart';
import 'new_batch_screen.dart';
import 'batch_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Batch> batches = [];
  BatchStatus? filter;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => setState(() => batches = DBService.getBatches());

  List<Batch> get filtered =>
      filter == null ? batches : batches.where((b) => b.status == filter).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Grows')),
      body: RefreshIndicator(
        onRefresh: () async => _load(),
        child: filtered.isEmpty
            ? _emptyState()
            : ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  _filterBar(),
                  const SizedBox(height: 8),
                  ...filtered.map((b) => BatchCard(
                        batch: b,
                        onTap: () async {
                          await Navigator.push(context,
                              MaterialPageRoute(builder: (_) => BatchDetailScreen(batch: b)));
                          _load();
                        },
                      )),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: async_newBatch,
      ),
    );
  }

  Future<void> async_newBatch() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const NewBatchScreen()));
    _load();
  }

  Widget _filterBar() {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _chip('All', filter == null, () => setState(() => filter = null)),
          ...BatchStatus.values.map((s) => _chip(
              s.name[0].toUpperCase() + s.name.substring(1), filter == s, () => setState(() => filter = s))),
        ],
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(label: Text(label), selected: selected, onSelected: (_) => onTap()),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.eco, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text('No grows yet', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text('Tap + to start tracking your first batch.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
