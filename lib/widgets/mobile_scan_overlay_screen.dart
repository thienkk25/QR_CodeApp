import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class MobileScanOverlayScreen extends StatefulWidget {
  final MobileScannerController controller;
  final bool mode;
  final bool isAutoOpenLink;
  final Future<void> Function(String) autoOpenLink;
  final void Function(bool isUrl, String value) manualOpenLink;
  const MobileScanOverlayScreen(
      {super.key,
      required this.controller,
      required this.mode,
      required this.isAutoOpenLink,
      required this.autoOpenLink,
      required this.manualOpenLink});

  @override
  State<MobileScanOverlayScreen> createState() =>
      _MobileScanOverlayScreenState();
}

class _MobileScanOverlayScreenState extends State<MobileScanOverlayScreen> {
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

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() => isScanned = false);
        }
      });
    }
  }

  Widget _buildNormalScanner() {
    return MobileScanner(
      controller: widget.controller,
      onDetect: _handleDetect,
    );
  }

  Widget _buildOverlayScanner(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final padding = mediaQuery.padding;

    const appBarHeight = 82.7;
    const bottomAppBarHeight = 56.0;

    final availableHeight = screenSize.height -
        appBarHeight -
        bottomAppBarHeight -
        padding.top -
        padding.bottom;

    final scanWindowCenter = Offset(
      screenSize.width / 2,
      availableHeight / 2,
    );

    final scanWindow = Rect.fromCenter(
      center: scanWindowCenter,
      width: 200,
      height: 200,
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        MobileScanner(
          controller: widget.controller,
          scanWindow: scanWindow,
          fit: BoxFit.cover,
          onDetect: _handleDetect,
        ),
        ValueListenableBuilder(
          valueListenable: widget.controller,
          builder: (context, value, child) {
            if (!value.isInitialized ||
                !value.isRunning ||
                value.error != null) {
              return Center(
                child: Text(
                  value.error?.errorDetails?.message ??
                      'Đang khởi tạo máy quét...',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              );
            }
            return CustomPaint(
              painter: ScanWindowOverlay(scanWindow: scanWindow),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mode) {
      return _buildOverlayScanner(context);
    } else {
      return _buildNormalScanner();
    }
  }
}

class ScanWindowOverlay extends CustomPainter {
  final Rect scanWindow;

  ScanWindowOverlay({required this.scanWindow});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black45
      ..style = PaintingStyle.fill;

    final outerRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final path = Path()
      ..addRect(outerRect)
      ..addRect(scanWindow)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    canvas.drawRect(scanWindow, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
