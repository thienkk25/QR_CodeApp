import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class MobileScanNormalScreen extends StatefulWidget {
  final void Function(MobileScannerController controllerChild) toggleMode;
  final bool isAutoOpenLink;
  final Future<void> Function(String) autoOpenLink;
  final void Function(bool isUrl, String value) manualOpenLink;
  const MobileScanNormalScreen(
      {super.key,
      required this.toggleMode,
      required this.isAutoOpenLink,
      required this.autoOpenLink,
      required this.manualOpenLink});

  @override
  State<MobileScanNormalScreen> createState() => _MobileScanNormalScreenState();
}

class _MobileScanNormalScreenState extends State<MobileScanNormalScreen> {
  MobileScannerController controller = MobileScannerController();
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      widget.toggleMode(controller);
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

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
        await widget.autoOpenLink(value);
      } else {
        widget.manualOpenLink(isUrl, value);
      }

      Future.delayed(const Duration(seconds: 2), () {
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
      controller: controller,
      onDetect: _handleDetect,
    );
  }
}
