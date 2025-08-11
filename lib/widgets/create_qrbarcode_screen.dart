import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

class CreateQrbarcodeScreen extends StatefulWidget {
  const CreateQrbarcodeScreen({super.key});

  @override
  State<CreateQrbarcodeScreen> createState() => _CreateQrbarcodeScreenState();
}

class _CreateQrbarcodeScreenState extends State<CreateQrbarcodeScreen> {
  TextEditingController controller = TextEditingController();
  GlobalKey globalKey = GlobalKey();
  String selectedType = 'QR Code';

  final barcodeTypes = {
    'QR Code': Barcode.qrCode(),
    'ISBN': Barcode.isbn(),
    'Code39': Barcode.code39(),
    'Code93': Barcode.code93(),
    'Code128': Barcode.code128(),
    'GS128': Barcode.gs128(),
    'ITF': Barcode.itf(),
    'ITF14': Barcode.itf14(),
    'ITF16': Barcode.itf16(),
    'EAN13': Barcode.ean13(),
    'EAN2': Barcode.ean2(),
    'EAN5': Barcode.ean5(),
    'EAN8': Barcode.ean8(),
    'UPCA': Barcode.upcA(),
    'UPCE': Barcode.upcE(),
    'Telepen': Barcode.telepen(),
    'Codabar': Barcode.codabar(),
    'RM4SCC': Barcode.rm4scc(),
    'Postnet': Barcode.postnet(),
    'PDF417': Barcode.pdf417(),
    'Data Matrix': Barcode.dataMatrix(),
    'Aztec': Barcode.aztec(),
  };

  Future<String> getDesktopPath() async {
    final home =
        Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'];
    final desktop = Directory('$home/Desktop');
    if (!desktop.existsSync()) {
      throw Exception('Không tìm thấy thư mục Desktop.');
    }
    return desktop.path;
  }

  Future<void> savePng(BuildContext context) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));

      final boundary = globalKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Không tìm thấy widget để chụp ảnh.');
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Không thể chuyển widget thành PNG.');
      }

      Uint8List pngBytes = byteData.buffer.asUint8List();

      String path;
      if (Platform.isAndroid) {
        final dir = Directory('/storage/emulated/0/Pictures');
        if (!dir.existsSync()) {
          dir.createSync(recursive: true);
        }
        path = dir.path;
      } else if (Platform.isIOS) {
        final dir = await getApplicationDocumentsDirectory();
        path = dir.path;
      } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        path = await getDesktopPath();
      } else {
        throw UnsupportedError('Hệ điều hành chưa hỗ trợ.');
      }

      final file =
          File('$path/qr_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(pngBytes);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ảnh đã lưu tại: ${file.path}')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi lưu ảnh: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo mã'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            spacing: 10,
            children: [
              TextField(
                controller: controller,
                style: TextStyle(color: Theme.of(context).secondaryHeaderColor),
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).secondaryHeaderColor),
                  ),
                  border: const OutlineInputBorder(),
                  labelText: 'Nhập dữ liệu',
                  labelStyle:
                      TextStyle(color: Theme.of(context).secondaryHeaderColor),
                ),
                cursorColor: Theme.of(context).secondaryHeaderColor,
                onChanged: (_) => setState(() {}),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Loại:"),
                  DropdownButton<String>(
                    value: selectedType,
                    items: barcodeTypes.keys
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) => setState(() => selectedType = value!),
                  ),
                ],
              ),
              if (controller.text.isNotEmpty)
                Column(
                  spacing: 30,
                  children: [
                    Center(
                      child: RepaintBoundary(
                        key: globalKey,
                        child: BarcodeWidget(
                          barcode: barcodeTypes[selectedType]!,
                          data: controller.text,
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: 200,
                          color: Theme.of(context).secondaryHeaderColor,
                          errorBuilder: (context, error) => Text(error),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async => await savePng(context),
                      child: Container(
                        height: 50,
                        width: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(width: 1),
                          gradient: const LinearGradient(
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                            colors: [Colors.blueGrey, Colors.greenAccent],
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Lưu ảnh',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
