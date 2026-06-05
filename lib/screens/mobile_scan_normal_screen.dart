import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class MobileScanNormalScreen extends StatefulWidget {
  final MobileScannerController controller;
  final bool isAutoOpenLink;
  final Future<void> Function(String value, {String? format}) autoOpenLink;
  final Future<void> Function(bool isUrl, String value, {String? format}) manualOpenLink;
  const MobileScanNormalScreen(
      {super.key,
      required this.controller,
      required this.isAutoOpenLink,
      required this.autoOpenLink,
      required this.manualOpenLink});

  @override
  State<MobileScanNormalScreen> createState() => _MobileScanNormalScreenState();
}

class _MobileScanNormalScreenState extends State<MobileScanNormalScreen> {

  bool isScanned = false;

  Future<void> _handleDetect(BarcodeCapture capture) async {
    if (isScanned) return;
    final barcode = capture.barcodes.firstOrNull;
    final value = barcode?.rawValue;

    if (value != null) {
      final uri = Uri.tryParse(value);
      final isUrl = uri != null &&
          (uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https'));

      setState(() => isScanned = true);

      if (isUrl && widget.isAutoOpenLink) {
        await widget.autoOpenLink(value, format: barcode?.format.name);
      } else {
        await widget.manualOpenLink(isUrl, value, format: barcode?.format.name);
      }
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() => isScanned = false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MobileScanner(
      scanWindow: Rect.largest,
      controller: widget.controller,
      onDetect: _handleDetect,
    );
  }
}
