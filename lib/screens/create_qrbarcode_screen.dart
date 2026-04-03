import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_code_app/theme/app_theme.dart';
import 'package:qr_code_app/widgets/glass_container.dart';

class CreateQrbarcodeScreen extends StatefulWidget {
  const CreateQrbarcodeScreen({super.key});

  @override
  State<CreateQrbarcodeScreen> createState() => _CreateQrbarcodeScreenState();
}

class _CreateQrbarcodeScreenState extends State<CreateQrbarcodeScreen>
    with SingleTickerProviderStateMixin {
  TextEditingController textController = TextEditingController();
  GlobalKey globalKey = GlobalKey();
  String selectedType = 'QR Code';
  late AnimationController _previewAnim;
  late Animation<double> _previewFade;
  late Animation<Offset> _previewSlide;

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

  @override
  void initState() {
    super.initState();
    _previewAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _previewFade = CurvedAnimation(parent: _previewAnim, curve: Curves.easeOut);
    _previewSlide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _previewAnim, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    textController.dispose();
    _previewAnim.dispose();
    super.dispose();
  }

  void _onTextChanged(String text) {
    setState(() {});
    if (text.isNotEmpty) {
      _previewAnim.forward();
    } else {
      _previewAnim.reverse();
    }
  }

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
      if (boundary == null) throw Exception('Không tìm thấy widget.');

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw Exception('Không thể chuyển thành PNG.');

      Uint8List pngBytes = byteData.buffer.asUint8List();

      String path;
      if (!kIsWeb && Platform.isAndroid) {
        final dir = Directory('/storage/emulated/0/Pictures/ScanQR');
        if (!dir.existsSync()) dir.createSync(recursive: true);
        path = dir.path;
      } else if (!kIsWeb && Platform.isIOS) {
        final dir = await getApplicationDocumentsDirectory();
        path = dir.path;
      } else if (!kIsWeb &&
          (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
        path = await getDesktopPath();
      } else {
        throw UnsupportedError('Nền tảng chưa hỗ trợ lưu ảnh.');
      }

      final file =
          File('$path/qr_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(pngBytes);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle,
                  color: AppColors.success, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text('Đã lưu: ${file.path}')),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_rounded, color: AppColors.error, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text('Lỗi: $e')),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasContent = textController.text.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        title: const Text('Tạo mã QR / Barcode'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.bgCardSolid,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: const Icon(Icons.arrow_back_rounded,
                color: AppColors.textPrimary, size: 20),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Input field ──────────────────────────────
            _SectionLabel(label: 'Nội dung'),
            const SizedBox(height: 8),
            TextField(
              controller: textController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Nhập URL, văn bản, số điện thoại...',
                prefixIcon: Icon(Icons.edit_rounded,
                    color: AppColors.textMuted, size: 20),
              ),
              cursorColor: AppColors.accentPurple,
              onChanged: _onTextChanged,
              maxLines: 3,
              minLines: 1,
            ),

            const SizedBox(height: 20),

            // ── Type selector ────────────────────────────
            _SectionLabel(label: 'Loại mã'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: selectedType,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.qr_code_2_rounded,
                    color: AppColors.textMuted, size: 20),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                filled: true,
                fillColor: AppColors.bgCardSolid,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.glassBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.glassBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.accentPurple, width: 2),
                ),
              ),
              dropdownColor: AppColors.bgCardSolid,
              icon: const Icon(Icons.expand_more_rounded,
                  color: AppColors.textSecondary),
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500),
              items: barcodeTypes.keys
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => selectedType = v!),
            ),

            const SizedBox(height: 28),

            // ── Preview (animated) ───────────────────────
            FadeTransition(
              opacity: _previewFade,
              child: SlideTransition(
                position: _previewSlide,
                child: hasContent
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _SectionLabel(label: 'Xem trước'),
                          const SizedBox(height: 12),

                          // Barcode card with glow
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accentPurple.withAlpha(60),
                                  blurRadius: 30,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(20),
                            child: RepaintBoundary(
                              key: globalKey,
                              child: Container(
                                color: Colors.white,
                                padding: const EdgeInsets.all(12),
                                child: BarcodeWidget(
                                  barcode: barcodeTypes[selectedType]!,
                                  data: textController.text,
                                  width: double.infinity,
                                  height: selectedType == 'QR Code' ||
                                          selectedType == 'Data Matrix' ||
                                          selectedType == 'Aztec' ||
                                          selectedType == 'PDF417'
                                      ? 220
                                      : 130,
                                  color: Colors.black,
                                  errorBuilder: (_, error) => Container(
                                    height: 80,
                                    alignment: Alignment.center,
                                    child: Text(
                                      error,
                                      style: const TextStyle(
                                          color: AppColors.error, fontSize: 13),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Save button
                          GradientButton(
                            onTap: () => savePng(context),
                            width: double.infinity,
                            height: 52,
                            padding: EdgeInsets.zero,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.download_rounded,
                                    color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Lưu ảnh',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ),

            // Empty placeholder
            if (!hasContent)
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.bgCardSolid,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: const Icon(Icons.qr_code_2_rounded,
                          size: 38, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Nhập nội dung để tạo mã',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: AppTextStyles.labelSmall.copyWith(
        letterSpacing: 1.2,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
