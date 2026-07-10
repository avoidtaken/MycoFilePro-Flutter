// lib/screens/scan_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/models.dart';
import '../services/db_service.dart';
import 'new_log_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});
  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  Item? matched;
  String? lastCode;

  void _onDetect(BarcodeCapture capture) {
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code == null || code == lastCode) return;
    lastCode = code;
    final item = DBService.findItemByQr(code);
    setState(() => matched = item);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan to Log')),
      body: Stack(
        children: [
          MobileScanner(onDetect: _onDetect),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: matched != null ? _matchedCard(matched!) : _noMatchCard(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _matchedCard(Item item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(item.containerType ?? 'Item', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(item.qrCode, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (_) => NewLogScreen(item: item)));
                setState(() => matched = null);
              },
              child: const Text('Log Activity'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _noMatchCard() {
    if (lastCode == null) return const SizedBox.shrink();
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      color: Colors.red[50],
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No item matches this QR code'),
      ),
    );
  }
}
