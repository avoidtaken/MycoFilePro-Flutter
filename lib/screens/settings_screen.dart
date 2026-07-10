// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/models.dart';
import '../services/db_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final strains = DBService.getStrains();
    final spaces = DBService.getGrowSpaces();
    final recipes = DBService.getRecipes();
    final inventory = DBService.getInventory();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _section('Strains', strains.map((s) => s.name).toList(), _addStrain),
          _section('Grow Spaces', spaces.map((s) => s.name).toList(), _addGrowSpace),
          _section('Recipes', recipes.map((r) => r.name).toList(), _addRecipe),
          _section('Inventory', inventory.map((i) => '${i.name} (${i.quantityOnHand}${i.unit})').toList(), _addInventory),
          const Divider(),
          ListTile(
            title: const Text('Export All Data (JSON)'),
            trailing: const Icon(Icons.download),
            onTap: () => _export('json'),
          ),
          ListTile(
            title: const Text('Export All Data (CSV)'),
            trailing: const Icon(Icons.download),
            onTap: () => _export('csv'),
          ),
          const Divider(),
          const ListTile(title: Text('MycoFile Pro'), subtitle: Text('v1.0.0 - fully offline, on-device tracking')),
        ],
      ),
    );
  }

  Widget _section(String title, List<String> entries, VoidCallback onAdd) {
    return ExpansionTile(
      title: Text(title),
      children: [
        ...entries.map((e) => ListTile(title: Text(e))),
        ListTile(
          leading: const Icon(Icons.add),
          title: Text('Add $title'),
          onTap: onAdd,
        ),
      ],
    );
  }

  void _addStrain() {
    final nameCtrl = TextEditingController();
    final daysCtrl = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('New Strain'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name (e.g. Golden Teacher)')),
        TextField(controller: daysCtrl, decoration: const InputDecoration(labelText: 'Default colonization days'), keyboardType: TextInputType.number),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () async {
            final s = Strain()..name = nameCtrl.text..defaultColonizationDays = int.tryParse(daysCtrl.text);
            await DBService.addStrain(s);
            if (mounted) { Navigator.pop(context); setState(() {}); }
          },
          child: const Text('Save'),
        ),
      ],
    ));
  }

  void _addGrowSpace() {
    final nameCtrl = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('New Grow Space'),
      content: TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name (e.g. Fruiting Tent)')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () async {
            final g = GrowSpace()..name = nameCtrl.text;
            await DBService.addGrowSpace(g);
            if (mounted) { Navigator.pop(context); setState(() {}); }
          },
          child: const Text('Save'),
        ),
      ],
    ));
  }

  void _addRecipe() {
    final nameCtrl = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('New Recipe'),
      content: TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name (e.g. CVG)')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () async {
            final r = Recipe()..name = nameCtrl.text;
            await DBService.addRecipe(r);
            if (mounted) { Navigator.pop(context); setState(() {}); }
          },
          child: const Text('Save'),
        ),
      ],
    ));
  }

  void _addInventory() {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();
    final costCtrl = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('New Inventory Item'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name (e.g. Vermiculite)')),
        TextField(controller: qtyCtrl, decoration: const InputDecoration(labelText: 'Quantity on hand'), keyboardType: TextInputType.number),
        TextField(controller: costCtrl, decoration: const InputDecoration(labelText: 'Cost per unit'), keyboardType: TextInputType.number),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () async {
            final i = InventoryItem()
              ..name = nameCtrl.text
              ..quantityOnHand = double.tryParse(qtyCtrl.text) ?? 0
              ..costPerUnit = double.tryParse(costCtrl.text) ?? 0;
            await DBService.addInventoryItem(i);
            if (mounted) { Navigator.pop(context); setState(() {}); }
          },
          child: const Text('Save'),
        ),
      ],
    ));
  }

  Future<void> _export(String format) async {
    final batches = DBService.getBatches();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/mycofile_export.$format');

    if (format == 'json') {
      final data = batches.map((b) => {
        'label': b.label, 'status': b.status.name, 'yield_g': b.totalYieldG,
      }).toList();
      await file.writeAsString(jsonEncode(data));
    } else {
      final rows = ['label,status,yield_g'];
      for (final b in batches) {
        rows.add('${b.label},${b.status.name},${b.totalYieldG}');
      }
      await file.writeAsString(rows.join('\n'));
    }
    await Share.shareXFiles([XFile(file.path)]);
  }
}
