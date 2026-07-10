// lib/screens/new_batch_screen.dart
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/db_service.dart';

class NewBatchScreen extends StatefulWidget {
  const NewBatchScreen({super.key});
  @override
  State<NewBatchScreen> createState() => _NewBatchScreenState();
}

class _NewBatchScreenState extends State<NewBatchScreen> {
  final labelCtrl = TextEditingController();
  Strain? strain;
  Recipe? recipe;
  GrowSpace? space;

  @override
  Widget build(BuildContext context) {
    final strains = DBService.getStrains();
    final recipes = DBService.getRecipes();
    final spaces = DBService.getGrowSpaces();

    return Scaffold(
      appBar: AppBar(title: const Text('New Batch')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: labelCtrl, decoration: const InputDecoration(labelText: 'Label (e.g. GT-01)')),
          const SizedBox(height: 16),
          DropdownButtonFormField<Strain>(
            decoration: const InputDecoration(labelText: 'Strain'),
            items: strains.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
            onChanged: (v) => setState(() => strain = v),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<Recipe>(
            decoration: const InputDecoration(labelText: 'Recipe (optional)'),
            items: recipes.map((r) => DropdownMenuItem(value: r, child: Text(r.name))).toList(),
            onChanged: (v) => setState(() => recipe = v),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<GrowSpace>(
            decoration: const InputDecoration(labelText: 'Grow Space (optional)'),
            items: spaces.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
            onChanged: (v) => setState(() => space = v),
          ),
          if (strains.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text('No strains yet - add one from Settings first.',
                  style: TextStyle(color: Colors.orange)),
            ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: labelCtrl.text.isEmpty || strain == null ? null : _save,
            child: const Text('Create Batch'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final batch = Batch()
      ..label = labelCtrl.text
      ..strainId = strain?.id
      ..recipeId = recipe?.id
      ..growSpaceId = space?.id
      ..inoculatedAt = DateTime.now();
    if (strain?.defaultColonizationDays != null) {
      batch.expectedColonizedAt = DateTime.now().add(Duration(days: strain!.defaultColonizationDays!));
    }
    await DBService.addBatch(batch);
    if (mounted) Navigator.pop(context);
  }
}
