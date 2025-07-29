import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool isScanned = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkScriptForWeb(context);
    });
    super.initState();
  }

  void checkScriptForWeb(BuildContext content) {
    if (kIsWeb) {
      final scriptUrl = 'https://unpkg.com/@zxing/library@latest';
      MobileScannerPlatform.instance.setBarcodeLibraryScriptUrl(scriptUrl);
    } else {
      requestCameraPermissionAndroidIOS(content);
    }
  }

  Future<void> requestCameraPermissionAndroidIOS(BuildContext content) async {
    final status = await Permission.camera.status;
    if (status.isGranted || status.isLimited || status.isRestricted) {
      return;
    }
    if (status.isPermanentlyDenied) {
      openAppSettings();
      return;
    }
    if (status.isRestricted) {
      if (!content.mounted) return;
      showDialog(
        context: content,
        builder: (context) => AlertDialog(
          title: const Text("Không thể truy cập camera"),
          content: const Text(
            "Quyền camera đã bị hệ thống hạn chế kiểm soát cha mẹ hoặc thiết bị không cho phép.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Đóng"),
            ),
          ],
        ),
      );
      return;
    }
    await Permission.camera
        .onGrantedCallback(() {})
        .onDeniedCallback(() {})
        .onPermanentlyDeniedCallback(() {
          openAppSettings();
        })
        .onRestrictedCallback(() {})
        .onLimitedCallback(() {})
        .request();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Scanner')),
      body: Center(
        child: SizedBox(
          width: 300,
          height: 300,
          child: MobileScanner(
            controller: controller,
            onDetect: (capture) async {
              if (isScanned) return;
              final barcode = capture.barcodes.firstOrNull;
              final value = barcode?.rawValue;

              if (value != null) {
                final uri = Uri.tryParse(value);
                final isUrl =
                    uri != null &&
                    (uri.hasScheme &&
                        (uri.scheme == 'http' || uri.scheme == 'https'));
                setState(() => isScanned = true);

                controller.stop();

                if (!mounted) return;
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Đã quét mã'),
                    content: Text(value),
                    actions: [
                      if (isUrl)
                        TextButton(
                          onPressed: () async {
                            final url = Uri.parse(value);
                            if (await canLaunchUrl(url)) {
                              await launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          },
                          child: const Text('Mở liên kết'),
                        ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          controller.start();
                          setState(() => isScanned = false);
                        },
                        child: const Text('Quét lại'),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
