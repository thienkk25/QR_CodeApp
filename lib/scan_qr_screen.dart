import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
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

  void checkScriptForWeb(BuildContext context) {
    if (kIsWeb) {
      final scriptUrl = 'https://unpkg.com/@zxing/library@latest';
      MobileScannerPlatform.instance.setBarcodeLibraryScriptUrl(scriptUrl);
    } else {
      requestCameraPhotoPermissionAndroidIOS(context);
    }
  }

  Future<void> requestCameraPhotoPermissionAndroidIOS(
    BuildContext context,
  ) async {
    final cameraStatus = await Permission.camera.status;
    final photoStatus = await Permission.photos.status;

    if ((cameraStatus.isGranted || cameraStatus.isLimited) &&
        (photoStatus.isGranted || photoStatus.isLimited)) {
      return;
    }

    if (cameraStatus.isPermanentlyDenied || photoStatus.isPermanentlyDenied) {
      openAppSettings();
      return;
    }

    if (cameraStatus.isRestricted) {
      if (!context.mounted) return;
      await showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text("Không thể truy cập camera"),
          content: Text(
            "Quyền camera đã bị hệ thống hạn chế kiểm soát cha mẹ hoặc thiết bị không cho phép.",
          ),
        ),
      );
      return;
    }

    if (photoStatus.isRestricted) {
      if (!context.mounted) return;
      await showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text("Không thể truy cập thư viện ảnh"),
          content: Text(
            "Quyền truy cập thư viện ảnh đã bị hệ thống hạn chế kiểm soát cha mẹ hoặc thiết bị không cho phép.",
          ),
        ),
      );
      return;
    }

    await Future.wait([
      withCallbacks(Permission.camera).request(),
      withCallbacks(Permission.photos).request(),
    ]);
  }

  Permission withCallbacks(Permission permission) {
    return permission
        .onGrantedCallback(() {})
        .onDeniedCallback(() {})
        .onPermanentlyDeniedCallback(() {
          openAppSettings();
        })
        .onRestrictedCallback(() {})
        .onLimitedCallback(() {});
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.photo),
            onPressed: () async {
              controller.stop();
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(
                source: ImageSource.gallery,
              );
              if (image != null) {
                final MobileScannerController controllerPhoto =
                    MobileScannerController();
                final BarcodeCapture? capture = await controllerPhoto
                    .analyzeImage(image.path);
                final barcode = capture?.barcodes.firstOrNull;
                final value = barcode?.rawValue;
                if (value != null) {
                  final uri = Uri.tryParse(value);
                  final isUrl =
                      uri != null &&
                      (uri.hasScheme &&
                          (uri.scheme == 'http' || uri.scheme == 'https'));
                  if (!context.mounted) return;
                  showDialog(
                    barrierDismissible: false,
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
                            Clipboard.setData(ClipboardData(text: value));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Sao chép thành công")),
                            );
                          },
                          child: const Text('Sao chép'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Đóng'),
                        ),
                      ],
                    ),
                  );
                } else {
                  if (!context.mounted) return;
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Ảnh không đúng định dạng'),
                      content: Text("Vui lòng thử lại"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Đóng'),
                        ),
                      ],
                    ),
                  );
                }
                await controllerPhoto.dispose();
              }
              controller.start();
            },
          ),
        ],
      ),
      body: MobileScanner(
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
              barrierDismissible: false,
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
                      Clipboard.setData(ClipboardData(text: value));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Sao chép thành công")),
                      );
                    },
                    child: const Text('Sao chép'),
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
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.flash_on),
              onPressed: () {
                controller.toggleTorch();
              },
            ),
            IconButton(
              icon: const Icon(Icons.cameraswitch),
              onPressed: () {
                controller.switchCamera();
              },
            ),
          ],
        ),
      ),
    );
  }
}
