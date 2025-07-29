import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool _isScanned = false;

  @override
  void initState() {
    super.initState();
    _checkScriptForWeb();
  }

  void _checkScriptForWeb() {
    if (kIsWeb) {
      final scriptUrl = 'https://unpkg.com/@zxing/library@latest';
      MobileScannerPlatform.instance.setBarcodeLibraryScriptUrl(scriptUrl);
    }
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
              if (_isScanned) return;
              final barcode = capture.barcodes.firstOrNull;
              final value = barcode?.rawValue;

              if (value != null) {
                final uri = Uri.tryParse(value);
                final isUrl =
                    uri != null &&
                    (uri.hasScheme &&
                        (uri.scheme == 'http' || uri.scheme == 'https'));
                setState(() => _isScanned = true);

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
                          setState(() => _isScanned = false);
                        },
                        child: const Text('Quét lại'),
                      ),
                    ],
                  ),
                );
              }
            },
            errorBuilder: (context, error) {
              return Center(
                child: AlertDialog(
                  title: const Text('Lỗi'),
                  content: Text("Vui lòng cấp quyền camera để sử dụng!"),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
