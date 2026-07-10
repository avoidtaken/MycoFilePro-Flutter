// lib/models/models.dart
// Isar (local NoSQL) schema - offline-first, no backend server needed.
// Covers Strains, Batches, Items (lineage), Activity Logs, Recipes,
// Inventory, and Grow Spaces.

import 'package:isar/isar.dart';

part 'models.g.dart';

enum ActivityType {
  inoculation,
  colonizationCheck,
  fruiting,
  misting,
  harvest,
  contamination,
  note,
  tempHumidity,
}

enum BatchStatus { incubating, fruiting, harvested, contaminated, retired }

@collection
class GrowSpace {
  Id id = Isar.autoIncrement;
  late String name;
  String? locationNote;
  double? targetTempC;
  double? targetHumidityPct;
  String? sensorId;
}

@collection
class Strain {
  Id id = Isar.autoIncrement;
  @Index()
  late String name;
  String? species;
  int? defaultColonizationDays;
  int? defaultFruitingDays;
  String? notes;
  String? photoPath;
  DateTime createdAt = DateTime.now();
}

@collection
class InventoryItem {
  Id id = Isar.autoIncrement;
  late String name;
  String unit = 'g';
  double quantityOnHand = 0;
  double costPerUnit = 0;
  double? reorderThreshold;
  String? supplier;
}

@collection
class Recipe {
  Id id = Isar.autoIncrement;
  late String name;
  String? description;
  List<int> ingredientIds = []; // RecipeIngredient ids

  double totalCost(List<RecipeIngredient> ingredients, List<InventoryItem> inventory) {
    double total = 0;
    for (final ing in ingredients) {
      final item = inventory.where((i) => i.id == ing.inventoryItemId).firstOrNull;
      if (item != null) total += ing.quantity * item.costPerUnit;
    }
    return total;
  }
}

@collection
class RecipeIngredient {
  Id id = Isar.autoIncrement;
  late int recipeId;
  late int inventoryItemId;
  late double quantity;
}

@collection
class Batch {
  Id id = Isar.autoIncrement;
  late String label;
  int? strainId;
  int? recipeId;
  int? growSpaceId;
  @enumerated
  BatchStatus status = BatchStatus.incubating;
  DateTime createdAt = DateTime.now();
  DateTime? inoculatedAt;
  DateTime? expectedColonizedAt;
  double totalYieldG = 0;
  double? totalCostOverride;

  double? costPerGram(double recipeCost) {
    final cost = totalCostOverride ?? recipeCost;
    if (totalYieldG > 0 && cost > 0) {
      return (cost / totalYieldG * 100).roundToDouble() / 100;
    }
    return null;
  }
}

@collection
class Item {
  Id id = Isar.autoIncrement;
  late int batchId;
  int? parentItemId;
  @Index(unique: true)
  late String qrCode;
  String? containerType;
  @enumerated
  BatchStatus status = BatchStatus.incubating;
  double yieldG = 0;
  DateTime createdAt = DateTime.now();
}

@collection
class ActivityLog {
  Id id = Isar.autoIncrement;
  late int itemId;
  @enumerated
  late ActivityType type;
  String? note;
  String? photoPath;
  double? valueNumeric;
  DateTime loggedAt = DateTime.now();
  DateTime? editedAt;
  bool isDeleted = false; // soft-delete: fixes original app's permanent-log flaw
  String source = 'manual'; // manual or sensor
}
