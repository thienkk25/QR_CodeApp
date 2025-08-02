import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class MobileScanOverlayScreen extends StatefulWidget {
  final void Function(MobileScannerController controllerChild) toggleMode;
  final bool isAutoOpenLink;
  final Future<void> Function(String) autoOpenLink;
  final void Function(bool isUrl, String value) manualOpenLink;
  const MobileScanOverlayScreen(
      {super.key,
      required this.toggleMode,
      required this.isAutoOpenLink,
      required this.autoOpenLink,
      required this.manualOpenLink});

  @override
  State<MobileScanOverlayScreen> createState() =>
      _MobileScanOverlayScreenState();
}

class _MobileScanOverlayScreenState extends State<MobileScanOverlayScreen> {
  MobileScannerController controller = MobileScannerController();
  bool isScanned = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.toggleMode(controller);
    });
    super.initState();
  }

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
          controller: controller,
          scanWindow: scanWindow,
          fit: BoxFit.cover,
          onDetect: _handleDetect,
        ),
        ValueListenableBuilder(
          valueListenable: controller,
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
      ..color = Colors.white.withAlpha(100)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    canvas.drawRect(scanWindow, borderPaint);

    final cornerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round;

    const cornerLength = 30.0;
    canvas.drawLine(
      scanWindow.topLeft,
      scanWindow.topLeft + const Offset(cornerLength, 0),
      cornerPaint,
    );
    canvas.drawLine(
      scanWindow.topLeft,
      scanWindow.topLeft + const Offset(0, cornerLength),
      cornerPaint,
    );

    canvas.drawLine(
      scanWindow.topRight,
      scanWindow.topRight + const Offset(-cornerLength, 0),
      cornerPaint,
    );
    canvas.drawLine(
      scanWindow.topRight,
      scanWindow.topRight + const Offset(0, cornerLength),
      cornerPaint,
    );

    canvas.drawLine(
      scanWindow.bottomLeft,
      scanWindow.bottomLeft + const Offset(cornerLength, 0),
      cornerPaint,
    );
    canvas.drawLine(
      scanWindow.bottomLeft,
      scanWindow.bottomLeft + const Offset(0, -cornerLength),
      cornerPaint,
    );

    canvas.drawLine(
      scanWindow.bottomRight,
      scanWindow.bottomRight + const Offset(-cornerLength, 0),
      cornerPaint,
    );
    canvas.drawLine(
      scanWindow.bottomRight,
      scanWindow.bottomRight + const Offset(0, -cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
