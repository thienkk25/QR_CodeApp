import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_code_app/theme/app_theme.dart';
import 'package:qr_code_app/widgets/glass_container.dart';
import 'package:qr_code_app/l10n/app_localizations.dart';
import 'package:gal/gal.dart';
import 'package:qr_code_app/utils/web_downloader.dart';

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

  Color qrColor = Colors.black;
  Color qrBgColor = Colors.white;

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

  Future<String> getDesktopPath(String notFoundMsg) async {
    final home =
        Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'];
    final desktop = Directory('$home/Desktop');
    if (!desktop.existsSync()) {
      throw Exception(notFoundMsg);
    }
    return desktop.path;
  }

  Future<void> savePng(BuildContext context) async {
    final widgetNotFoundMsg = context.l10n.get('widget_not_found');
    final cannotConvertPngMsg = context.l10n.get('cannot_convert_png');
    final savedToGalleryMsg = context.l10n.get('saved_to_gallery');
    final desktopNotFoundMsg = context.l10n.get('desktop_not_found');
    final savedToMsg = context.l10n.get('saved_to');
    final errorPrefixMsg = context.l10n.get('error_prefix');

    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final boundary = globalKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception(widgetNotFoundMsg);
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception(cannotConvertPngMsg);
      }

      Uint8List pngBytes = byteData.buffer.asUint8List();

      if (kIsWeb) {
        downloadWebImage(pngBytes, 'qr_${DateTime.now().millisecondsSinceEpoch}.png');
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: context.colors.success, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(savedToGalleryMsg)),
              ],
            ),
          ),
        );
        return;
      }

      if (Platform.isAndroid || Platform.isIOS) {
        final hasAccess = await Gal.hasAccess();
        if (!hasAccess) {
          await Gal.requestAccess();
        }
        await Gal.putImageBytes(pngBytes, album: 'ScanQR');
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: context.colors.success, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(savedToGalleryMsg)),
              ],
            ),
          ),
        );
      } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        final path = await getDesktopPath(desktopNotFoundMsg);
        final file = File('$path/qr_${DateTime.now().millisecondsSinceEpoch}.png');
        await file.writeAsBytes(pngBytes);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: context.colors.success, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text('$savedToMsg${file.path}')),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_rounded, color: context.colors.error, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text('$errorPrefixMsg$e')),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildColorIndicator(Color color, bool isForeground) {
    final selectedColor = isForeground ? qrColor : qrBgColor;
    final isSelected = selectedColor == color;
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isForeground) {
            qrColor = color;
          } else {
            qrBgColor = color;
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? context.colors.accentPurple
                : (color == Colors.white ? Colors.grey.shade400 : Colors.transparent),
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: context.colors.accentPurple.withAlpha(80),
                    blurRadius: 4,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasContent = textController.text.isNotEmpty;

    return Scaffold(
      backgroundColor: context.colors.bgDeep,
      appBar: AppBar(
        title: Text(context.l10n.get('create_qr_barcode')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.colors.bgCardSolid,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: context.colors.glassBorder),
            ),
            child: Icon(Icons.arrow_back_rounded,
                color: context.colors.textPrimary, size: 20),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Input field ──────────────────────────────
            _SectionLabel(label: context.l10n.get('content_label')),
            const SizedBox(height: 8),
            TextField(
              controller: textController,
              style: TextStyle(color: context.colors.textPrimary),
              decoration: InputDecoration(
                hintText: context.l10n.get('enter_content_hint'),
                prefixIcon: Icon(Icons.edit_rounded,
                    color: context.colors.textMuted, size: 20),
              ),
              cursorColor: context.colors.accentPurple,
              onChanged: _onTextChanged,
              maxLines: 3,
              minLines: 1,
              keyboardType: TextInputType.text,
            ),

            const SizedBox(height: 20),

            // ── Type selector ────────────────────────────
            _SectionLabel(label: context.l10n.get('code_type_label')),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: selectedType,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.qr_code_2_rounded,
                    color: context.colors.textMuted, size: 20),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                filled: true,
                fillColor: context.colors.bgCardSolid,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.colors.glassBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.colors.glassBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: context.colors.accentPurple, width: 2),
                ),
              ),
              dropdownColor: context.colors.bgCardSolid,
              icon: Icon(Icons.expand_more_rounded,
                  color: context.colors.textSecondary),
              style: TextStyle(
                  color: context.colors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500),
              items: barcodeTypes.keys
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => selectedType = v!),
            ),

            const SizedBox(height: 20),

            _SectionLabel(label: context.l10n.get('color_customization')),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.l10n.get('foreground_color'), style: AppTextStyles.labelSmall.copyWith(fontSize: 11)),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 36,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          children: [
                            _buildColorIndicator(Colors.black, true),
                            _buildColorIndicator(const Color(0xFF6200EE), true),
                            _buildColorIndicator(const Color(0xFF1B5E20), true),
                            _buildColorIndicator(const Color(0xFFB71C1C), true),
                            _buildColorIndicator(const Color(0xFF1A237E), true),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.l10n.get('background_color'), style: AppTextStyles.labelSmall.copyWith(fontSize: 11)),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 36,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          children: [
                            _buildColorIndicator(Colors.white, false),
                            _buildColorIndicator(const Color(0xFFF3E5F5), false),
                            _buildColorIndicator(const Color(0xFFE8F5E9), false),
                            _buildColorIndicator(const Color(0xFFFFFDE7), false),
                            _buildColorIndicator(const Color(0xFFECEFF1), false),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
                          _SectionLabel(
                              label: context.l10n.get('preview_label')),
                          const SizedBox(height: 12),

                          // Barcode card with glow
                          Container(
                            decoration: BoxDecoration(
                              color: qrBgColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      context.colors.accentPurple.withAlpha(40),
                                  blurRadius: 30,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(20),
                            child: RepaintBoundary(
                              key: globalKey,
                              child: Container(
                                color: qrBgColor,
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
                                  color: qrColor,
                                  backgroundColor: qrBgColor,
                                  errorBuilder: (_, error) => Container(
                                    height: 80,
                                    alignment: Alignment.center,
                                    child: Text(
                                      error,
                                      style: TextStyle(
                                          color: context.colors.error,
                                          fontSize: 13),
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.download_rounded,
                                    color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  context.l10n.get('save_image'),
                                  style: const TextStyle(
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
                        color: context.colors.bgCardSolid,
                        shape: BoxShape.circle,
                        border: Border.all(color: context.colors.glassBorder),
                      ),
                      child: Icon(Icons.qr_code_2_rounded,
                          size: 38, color: context.colors.textMuted),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.get('enter_content_to_create'),
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
