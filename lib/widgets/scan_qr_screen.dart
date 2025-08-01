import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_app/widgets/help_client_screen.dart';
import 'package:qr_code_app/widgets/history_scanner_screen.dart';
import 'package:qr_code_app/widgets/mobile_scan_overlay_screen.dart';
import 'package:qr_code_app/models/scan_history_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen>
    with WidgetsBindingObserver {
  final MobileScannerController controller = MobileScannerController();
  bool isScanMode = false;
  bool isFlashOn = false;
  bool isScanned = false;
  bool isAutoOpenLink = false;
  double currentZoom = 0.0;
  double baseZoom = 1.0;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      startSharedPreferences();
      checkScriptForWeb(context);
    });
    super.initState();
  }

  Future<void> startSharedPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool? getAutoOpenLink = prefs.getBool('isAutoOpenLink');
    final bool? getScanMode = prefs.getBool('isScanMode');

    setState(() {
      isAutoOpenLink = getAutoOpenLink ?? false;
      isScanMode = getScanMode ?? false;
    });
  }

  Future<void> checkScriptForWeb(BuildContext context) async {
    if (kIsWeb) {
      final scriptUrl = 'https://unpkg.com/@zxing/library@latest';
      MobileScannerPlatform.instance.setBarcodeLibraryScriptUrl(scriptUrl);
    } else {
      await requestCameraPhotoPermissionAndroidIOS(context);
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

    await withCallbacks(Permission.camera).request();
    await withCallbacks(Permission.photos).request();
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && isScanned) {
      controller.start();
      setState(() => isScanned = false);
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              showGeneralDialog(
                context: context,
                barrierDismissible: true,
                barrierLabel: "Cài đặt",
                pageBuilder: (context, animation, secondaryAnimation) {
                  return SafeArea(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Material(
                        child: Container(
                          height: double.infinity,
                          width: MediaQuery.of(context).size.width * 0.8,
                          color: Theme.of(context).scaffoldBackgroundColor,
                          child: Column(
                            children: [
                              AppBar(
                                title: Text("Cài đặt"),
                                automaticallyImplyLeading: false,
                                centerTitle: true,
                              ),
                              ListTile(
                                leading: Icon(Icons.history),
                                title: Text("Lịch sử quét"),
                                onTap: () {
                                  controller.stop();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          HistoryScannerScreen(),
                                    ),
                                  ).then((_) => controller.start());
                                },
                              ),
                              StatefulBuilder(
                                builder: (context, setStateBuilder) {
                                  return ListTile(
                                    leading: Icon(Icons.link),
                                    title: Text("Tự động mở liên kết"),
                                    trailing: Switch(
                                      value: isAutoOpenLink,
                                      onChanged: (value) async {
                                        final prefs = await SharedPreferences
                                            .getInstance();
                                        await prefs.setBool(
                                          'isAutoOpenLink',
                                          value,
                                        );
                                        setState(() {
                                          setStateBuilder(() {
                                            isAutoOpenLink = value;
                                          });
                                        });
                                      },
                                    ),
                                  );
                                },
                              ),
                              StatefulBuilder(
                                builder: (context, setStateBuilder) {
                                  return ListTile(
                                    leading: Icon(Icons.qr_code),
                                    title: Text("Bật/Tắt khung QR"),
                                    trailing: Switch(
                                      value: isScanMode,
                                      onChanged: (value) async {
                                        await controller.stop();
                                        final prefs = await SharedPreferences
                                            .getInstance();
                                        await prefs.setBool(
                                          'isScanMode',
                                          value,
                                        );
                                        setState(() {
                                          setStateBuilder(() {
                                            isScanMode = value;
                                          });
                                        });
                                      },
                                    ),
                                  );
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.help_outline),
                                title: Text("Hướng dẫn"),
                                onTap: () {
                                  controller.stop();
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            HelpClientScreen(),
                                      )).then((value) => controller.start());
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                transitionBuilder:
                    (context, animation, secondaryAnimation, child) {
                  final tween = Tween<Offset>(
                    begin: Offset(1, 0),
                    end: Offset.zero,
                  );
                  return SlideTransition(
                    position: tween.animate(animation),
                    child: child,
                  );
                },
                transitionDuration: Duration(milliseconds: 300),
              );
            },
          ),
        ],
      ),
      body: StatefulBuilder(
        builder: (context, setStateBody) {
          return GestureDetector(
            onScaleStart: (details) {
              baseZoom = currentZoom;
            },
            onScaleUpdate: (details) {
              double newZoom = baseZoom * details.scale;
              newZoom = newZoom.clamp(0.1, 5.0);
              setStateBody(() {
                currentZoom = newZoom;
                controller.setZoomScale(currentZoom);
              });
            },
            child: MobileScanOverlayScreen(
              controller: controller,
              mode: isScanMode,
              isAutoOpenLink: isAutoOpenLink,
              autoOpenLink: (value) => autoOpenLink(value),
              manualOpenLink: (isUrl, value) => manualOpenLink(isUrl, value),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        height: 56,
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            StatefulBuilder(
              builder: (context, setStateBuilder) {
                return IconButton(
                  icon: Icon(
                    isFlashOn ? Icons.flash_on : Icons.flash_off,
                    color: isFlashOn
                        ? Colors.orange
                        : Theme.of(context).appBarTheme.foregroundColor,
                  ),
                  onPressed: () {
                    controller.toggleTorch();
                    setStateBuilder(() => isFlashOn = !isFlashOn);
                  },
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.photo),
              onPressed: () async {
                await controller.stop();
                final ImagePicker picker = ImagePicker();
                final XFile? image = await picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (image != null) {
                  if (isScanned) return;
                  final MobileScannerController controllerPhoto =
                      MobileScannerController();
                  final BarcodeCapture? capture =
                      await controllerPhoto.analyzeImage(image.path);
                  final barcode = capture?.barcodes.firstOrNull;
                  final value = barcode?.rawValue;
                  if (value != null) {
                    final uri = Uri.tryParse(value);
                    final isUrl = uri != null &&
                        (uri.hasScheme &&
                            (uri.scheme == 'http' || uri.scheme == 'https'));
                    setState(() => isScanned = true);

                    if (isUrl && isAutoOpenLink) {
                      await autoOpenLink(value);
                    } else {
                      manualOpenLink(isUrl, value);
                    }
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
                await controller.start();
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

  Future<void> autoOpenLink(String value) async {
    saveHistory(value);
    final url = Uri.parse(value);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void manualOpenLink(bool isUrl, String value) {
    saveHistory(value);
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
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              child: const Text('Mở liên kết'),
            ),
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("Sao chép thành công")));
            },
            child: const Text('Sao chép'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => isScanned = false);
            },
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void saveHistory(String value) {
    final box = Hive.box<ScanHistoryModel>('scan_history');
    final history = ScanHistoryModel(
      content: value,
      scannedAt: DateTime.now(),
    );

    box.add(history);
  }
}
