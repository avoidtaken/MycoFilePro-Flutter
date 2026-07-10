// lib/services/db_service.dart
// Isar database singleton - fully local, offline-first.

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/models.dart';

class DBService {
  static late Isar isar;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [
        GrowSpaceSchema,
        StrainSchema,
        InventoryItemSchema,
        RecipeSchema,
        RecipeIngredientSchema,
        BatchSchema,
        ItemSchema,
        ActivityLogSchema,
      ],
      directory: dir.path,
    );
  }

  // ---------- Strains ----------
  static Future<int> addStrain(Strain s) => isar.writeTxn(() => isar.strains.put(s));
  static List<Strain> getStrains() => isar.strains.where().findAllSync();

  // ---------- Grow Spaces ----------
  static Future<int> addGrowSpace(GrowSpace g) => isar.writeTxn(() => isar.growSpaces.put(g));
  static List<GrowSpace> getGrowSpaces() => isar.growSpaces.where().findAllSync();

  // ---------- Inventory ----------
  static Future<int> addInventoryItem(InventoryItem i) => isar.writeTxn(() => isar.inventoryItems.put(i));
  static List<InventoryItem> getInventory() => isar.inventoryItems.where().findAllSync();

  // ---------- Recipes ----------
  static Future<int> addRecipe(Recipe r) => isar.writeTxn(() => isar.recipes.put(r));
  static List<Recipe> getRecipes() => isar.recipes.where().findAllSync();
  static Future<int> addRecipeIngredient(RecipeIngredient ri) =>
      isar.writeTxn(() => isar.recipeIngredients.put(ri));
  static List<RecipeIngredient> getIngredientsForRecipe(int recipeId) =>
      isar.recipeIngredients.filter().recipeIdEqualTo(recipeId).findAllSync();

  // ---------- Batches ----------
  static Future<int> addBatch(Batch b) => isar.writeTxn(() => isar.batchs.put(b));
  static List<Batch> getBatches() =>
      isar.batchs.where().sortByCreatedAtDesc().findAllSync();
  static Future<void> updateBatch(Batch b) => isar.writeTxn(() => isar.batchs.put(b));

  // ---------- Items ----------
  static Future<int> addItem(Item item) => isar.writeTxn(() => isar.items.put(item));
  static List<Item> getItemsForBatch(int batchId) =>
      isar.items.filter().batchIdEqualTo(batchId).findAllSync();
  static List<Item> getAllItems() => isar.items.where().findAllSync();
  static Item? findItemByQr(String qr) => isar.items.filter().qrCodeEqualTo(qr).findFirstSync();
  static Future<void> mergeItemsIntoBatch(int batchId, List<int> itemIds) async {
    await isar.writeTxn(() async {
      for (final id in itemIds) {
        final item = await isar.items.get(id);
        if (item != null) {
          item.batchId = batchId;
          await isar.items.put(item);
        }
      }
    });
  }

  // ---------- Activity Logs ----------
  static Future<int> addLog(ActivityLog log) => isar.writeTxn(() => isar.activityLogs.put(log));
  static List<ActivityLog> getLogsForItem(int itemId) => isar.activityLogs
      .filter()
      .itemIdEqualTo(itemId)
      .isDeletedEqualTo(false)
      .sortByLoggedAtDesc()
      .findAllSync();
  static Future<void> editLog(ActivityLog log, {String? note, double? value}) async {
    if (note != null) log.note = note;
    if (value != null) log.valueNumeric = value;
    log.editedAt = DateTime.now();
    await isar.writeTxn(() => isar.activityLogs.put(log));
  }
  static Future<void> softDeleteLog(ActivityLog log) async {
    log.isDeleted = true;
    await isar.writeTxn(() => isar.activityLogs.put(log));
  }
}
