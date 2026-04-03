import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_app/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

/// Custom bottom sheet that replaces AlertDialog for scan results.
/// Shows the scanned value with URL detection, copy & open-link buttons.
Future<void> showScanResultSheet({
  required BuildContext context,
  required String value,
  required bool isUrl,
  required VoidCallback onClose,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (_) => _ScanResultSheet(
      value: value,
      isUrl: isUrl,
      onClose: onClose,
    ),
  );
}

class _ScanResultSheet extends StatefulWidget {
  final String value;
  final bool isUrl;
  final VoidCallback onClose;

  const _ScanResultSheet({
    required this.value,
    required this.isUrl,
    required this.onClose,
  });

  @override
  State<_ScanResultSheet> createState() => _ScanResultSheetState();
}

class _ScanResultSheetState extends State<_ScanResultSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _copyToClipboard(BuildContext ctx) async {
    await Clipboard.setData(ClipboardData(text: widget.value));
    setState(() => _copied = true);
    if (!ctx.mounted) return;
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 18),
            const SizedBox(width: 8),
            const Text('Đã sao chép vào clipboard!'),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _openUrl() async {
    final url = Uri.parse(widget.value);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUrl = widget.isUrl;
    final domain = isUrl ? Uri.tryParse(widget.value)?.host ?? '' : '';

    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bgCardSolid,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.glassBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentPurple.withAlpha(40),
              blurRadius: 40,
              spreadRadius: 0,
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.textMuted,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Header row with icon badge + title
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: isUrl
                            ? AppColors.accentGradient
                            : const LinearGradient(
                                colors: [Color(0xFF4A4A6A), Color(0xFF2A2A4A)],
                              ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isUrl ? Icons.link_rounded : Icons.qr_code_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Đã quét thành công',
                          style: AppTextStyles.titleMedium,
                        ),
                        Text(
                          isUrl ? 'Đường dẫn URL' : 'Văn bản',
                          style: AppTextStyles.labelSmall,
                        ),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        widget.onClose();
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.bgSurface,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // URL domain chip (if URL)
                if (isUrl && domain.isNotEmpty) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.accentPurple.withAlpha(25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.accentPurple.withAlpha(80)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          domain,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.accentPurple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Content card
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxHeight: 120),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.bgSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      widget.value,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontFamily: 'monospace',
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Action buttons
                Row(
                  children: [
                    // Copy button
                    Expanded(
                      child: _ActionBtn(
                        icon: _copied
                            ? Icons.check_circle_rounded
                            : Icons.copy_rounded,
                        label: _copied ? 'Đã sao chép' : 'Sao chép',
                        onTap: () => _copyToClipboard(context),
                        color: _copied ? AppColors.success : AppColors.textSecondary,
                        filled: false,
                      ),
                    ),
                    if (isUrl) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ActionBtn(
                          icon: Icons.open_in_browser_rounded,
                          label: 'Mở liên kết',
                          onTap: _openUrl,
                          color: AppColors.accentPurple,
                          filled: true,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool filled;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: filled ? color : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(12),
          border: filled ? null : Border.all(color: AppColors.glassBorder),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: color.withAlpha(60),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 17, color: filled ? Colors.white : color),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                color: filled ? Colors.white : color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
