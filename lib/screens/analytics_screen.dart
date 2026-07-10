// lib/screens/analytics_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/db_service.dart';
import '../models/models.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final batches = DBService.getBatches();
    final strains = DBService.getStrains();

    final costData = batches
        .map((b) => b.costPerGram(0) != null ? (b.label, b.costPerGram(0)!) : null)
        .whereType<(String, double)>()
        .toList();

    final totalYield = batches.fold<double>(0, (sum, b) => sum + b.totalYieldG);

    final byStrain = <String, List<Batch>>{};
    for (final b in batches) {
      final name = strains.where((s) => s.id == b.strainId).firstOrNull?.name ?? 'Unknown';
      byStrain.putIfAbsent(name, () => []).add(b);
    }
    final contamRates = byStrain.entries.map((e) {
      final total = e.value.length;
      final contaminated = e.value.where((b) => b.status == BatchStatus.contaminated).length;
      final rate = total > 0 ? (contaminated / total) * 100 : 0.0;
      return (e.key, rate, total);
    }).toList()
      ..sort((a, b) => b.$2.compareTo(a.$2));

    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: batches.isEmpty
          ? const Center(child: Text('No data yet - log some batches to see insights.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    _summaryCard('Total Yield', '${totalYield.toInt()}g', Icons.scale, Colors.green),
                    const SizedBox(width: 12),
                    _summaryCard('Batches', '${batches.length}', Icons.inventory_2, Colors.purple),
                  ],
                ),
                const SizedBox(height: 24),
                if (costData.isNotEmpty) ...[
                  const Text('Cost per Gram', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 200,
                    child: BarChart(BarChartData(
                      barGroups: costData.asMap().entries.map((e) {
                        return BarChartGroupData(x: e.key, barRods: [
                          BarChartRodData(toY: e.value.$2, color: Colors.green, width: 18),
                        ]);
                      }).toList(),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, meta) => Text(costData[v.toInt()].$1, style: const TextStyle(fontSize: 10)),
                        )),
                      ),
                    )),
                  ),
                  const SizedBox(height: 24),
                ],
                if (contamRates.isNotEmpty) ...[
                  const Text('Contamination Rate by Strain', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  ...contamRates.map((c) => ListTile(
                        title: Text(c.$1),
                        trailing: Text('${c.$2.toStringAsFixed(1)}% (${c.$3} batches)'),
                      )),
                ],
              ],
            ),
    );
  }

  Widget _summaryCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 6),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}
