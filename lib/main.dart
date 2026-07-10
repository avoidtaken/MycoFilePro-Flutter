// lib/main.dart
// MycoFile Pro - Flutter entry point. Offline-first, Isar local database.

import 'package:flutter/material.dart';
import 'services/db_service.dart';
import 'screens/root_tab_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBService.init();
  runApp(const MycoFileApp());
}

class MycoFileApp extends StatelessWidget {
  const MycoFileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MycoFile Pro',
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const RootTabView(),
    );
  }
}
