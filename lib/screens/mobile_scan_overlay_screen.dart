import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_code_app/screens/scanner_animation_line_screen.dart';
import 'package:qr_code_app/theme/app_theme.dart';

class MobileScanOverlayScreen extends StatefulWidget {
  final void Function(MobileScannerController controllerChild) toggleMode;
  final bool isAutoOpenLink;
  final Future<void> Function(String) autoOpenLink;
  final Future<void> Function(bool isUrl, String value) manualOpenLink;

  const MobileScanOverlayScreen({
    super.key,
    required this.toggleMode,
    required this.isAutoOpenLink,
    required this.autoOpenLink,
    required this.manualOpenLink,
  });

  @override
  State<MobileScanOverlayScreen> createState() =>
      _MobileScanOverlayScreenState();
}

class _MobileScanOverlayScreenState extends State<MobileScanOverlayScreen>
    with SingleTickerProviderStateMixin {
  MobileScannerController controller = MobileScannerController();
  bool isScanned = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.toggleMode(controller);
    });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
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
        await widget.manualOpenLink(isUrl, value);
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
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;

    // Responsive scan window size
    final windowSize = (screenSize.width * 0.65).clamp(200.0, 300.0);

    // Body extends behind AppBar (extendBodyBehindAppBar: true) so center on full screen
    final scanWindowCenter = Offset(
      screenSize.width / 2,
      screenSize.height / 2,
    );

    final scanWindow = Rect.fromCenter(
      center: scanWindowCenter,
      width: windowSize,
      height: windowSize,
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

        // Dark overlay with cut-out
        ValueListenableBuilder(
          valueListenable: controller,
          builder: (context, value, child) {
            if (!value.isInitialized ||
                !value.isRunning ||
                value.error != null) {
              return Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.bgCardSolid.withAlpha(200),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    value.error?.errorDetails?.message ??
                        'Đang khởi tạo máy quét...',
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 15),
                  ),
                ),
              );
            }
            return CustomPaint(
              painter: _ScanWindowOverlay(scanWindow: scanWindow),
            );
          },
        ),

        // Animated scan window frame
        Positioned(
          left: scanWindow.left,
          top: scanWindow.top,
          width: scanWindow.width,
          height: scanWindow.height,
          child: ScaleTransition(
            scale: _pulseAnim,
            child: _ScanFrame(size: windowSize),
          ),
        ),

        // Animated scan line inside window
        Positioned.fromRect(
          rect: scanWindow,
          child: const ScannerAnimationLineScreen(),
        ),

        // "Point camera at QR code" label
        Positioned(
          left: 0,
          right: 0,
          top: scanWindow.bottom + 20,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.bgCardSolid.withAlpha(180),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: const Text(
                'Hướng camera vào mã QR / Barcode',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Corner-bracket frame with glow
class _ScanFrame extends StatelessWidget {
  final double size;
  const _ScanFrame({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _FramePainter(),
    );
  }
}

class _FramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const cornerLen = 36.0;
    const strokeW = 4.0;

    final glowPaint = Paint()
      ..color = AppColors.accentPurple.withAlpha(100)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW + 8
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final cornerPaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.accentPurple, AppColors.accentCyan],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round;

    final corners = [
      // Top-left
      [Offset(0, cornerLen), Offset.zero, Offset(cornerLen, 0)],
      // Top-right
      [
        Offset(size.width - cornerLen, 0),
        Offset(size.width, 0),
        Offset(size.width, cornerLen)
      ],
      // Bottom-left
      [
        Offset(0, size.height - cornerLen),
        Offset(0, size.height),
        Offset(cornerLen, size.height)
      ],
      // Bottom-right
      [
        Offset(size.width - cornerLen, size.height),
        Offset(size.width, size.height),
        Offset(size.width, size.height - cornerLen)
      ],
    ];

    for (final corner in corners) {
      final path = Path()
        ..moveTo(corner[0].dx, corner[0].dy)
        ..lineTo(corner[1].dx, corner[1].dy)
        ..lineTo(corner[2].dx, corner[2].dy);
      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, cornerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Dark semi-transparent overlay with transparent cut-out
class _ScanWindowOverlay extends CustomPainter {
  final Rect scanWindow;
  _ScanWindowOverlay({required this.scanWindow});

  @override
  void paint(Canvas canvas, Size size) {
    final outerRect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Vignette gradient overlay
    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.2,
        colors: [
          Colors.black.withAlpha(30),
          Colors.black.withAlpha(160),
        ],
      ).createShader(outerRect);

    final path = Path()
      ..addRect(outerRect)
      ..addRRect(
          RRect.fromRectAndRadius(scanWindow, const Radius.circular(4)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
