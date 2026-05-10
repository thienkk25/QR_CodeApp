import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:qr_code_app/config/format_time.dart';
import 'package:qr_code_app/models/scan_history_model.dart';
import 'package:qr_code_app/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_code_app/l10n/app_localizations.dart';

class HistoryScannerScreen extends StatefulWidget {
  const HistoryScannerScreen({super.key});

  @override
  State<HistoryScannerScreen> createState() => _HistoryScannerScreenState();
}

class _HistoryScannerScreenState extends State<HistoryScannerScreen> {
  final box = Hive.box<ScanHistoryModel>('scan_history');

  Future<void> _confirmClearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.get('confirm_delete_all_title')),
        content: Text(context.l10n.get('confirm_delete_all_desc')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.get('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: context.colors.error),
            child: Text(context.l10n.get('delete_all_confirm')),
          ),
        ],
      ),
    );
    if (confirmed == true) box.clear();
  }

  bool _isUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bgDeep,
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, value, child) {
          if (box.isEmpty) {
            return _buildEmptyState();
          }

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = box.getAt(box.length - 1 - index)!;
                      return _buildHistoryCard(context, item, index);
                    },
                    childCount: box.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Scaffold(
      backgroundColor: context.colors.bgDeep,
      appBar: AppBar(
        title: Text(context.l10n.get('scan_history')),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: context.colors.bgCardSolid,
                shape: BoxShape.circle,
                border: Border.all(color: context.colors.glassBorder),
              ),
              child: Icon(
                Icons.history_rounded,
                size: 42,
                color: context.colors.textMuted,
              ),
            ),
            const SizedBox(height: 20),
            Text(context.l10n.get('no_history'), style: AppTextStyles.titleMedium),
            const SizedBox(height: 8),
            Text(
              context.l10n.get('no_history_desc'),
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: context.colors.bgDeep,
      elevation: 0,
      pinned: true,
      floating: true,
      centerTitle: true,
      title: Text(context.l10n.get('scan_history'), style: AppTextStyles.titleLarge),
      actions: [
        // Count badge
        ValueListenableBuilder(
          valueListenable: box.listenable(),
          builder: (_, __, ___) => Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: context.colors.accentPurple.withAlpha(25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: context.colors.accentPurple.withAlpha(60)),
            ),
            child: Text(
              '${box.length}',
              style: TextStyle(
                fontSize: 12,
                color: context.colors.accentPurple,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        // Clear all button
        IconButton(
          tooltip: context.l10n.get('delete_all'),
          icon: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: context.colors.error.withAlpha(18),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: context.colors.error.withAlpha(50)),
            ),
            child: Icon(
              Icons.delete_sweep_rounded,
              color: context.colors.error,
              size: 18,
            ),
          ),
          onPressed: _confirmClearAll,
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: context.colors.glassBorder),
      ),
    );
  }

  Widget _buildHistoryCard(
      BuildContext context, ScanHistoryModel item, int index) {
    final isUrl = _isUrl(item.content);
    final domain = isUrl ? Uri.tryParse(item.content)?.host ?? '' : '';

    return Dismissible(
      key: Key('history_${box.length - 1 - index}_${item.scannedAt}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: context.colors.error.withAlpha(25),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.colors.error.withAlpha(70)),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_rounded, color: context.colors.error, size: 22),
            const SizedBox(height: 4),
            Text(
              context.l10n.get('delete'),
              style: TextStyle(
                color: context.colors.error,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (_) => box.deleteAt(box.length - 1 - index),
      child: GestureDetector(
        onTap: () {
          Clipboard.setData(ClipboardData(text: item.content));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.get('copied'))),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: context.colors.bgCardSolid,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.colors.glassBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header row: icon + label + action ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Type icon
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: isUrl
                            ? context.colors.accentPurple.withAlpha(25)
                            : context.colors.bgSurface,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          color: isUrl
                              ? context.colors.accentPurple.withAlpha(55)
                              : context.colors.glassBorder,
                        ),
                      ),
                      child: Icon(
                        isUrl ? Icons.link_rounded : Icons.qr_code_rounded,
                        size: 17,
                        color: isUrl
                            ? context.colors.accentPurple
                            : context.colors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Domain / type label
                    Expanded(
                      child: Text(
                        isUrl && domain.isNotEmpty
                            ? domain
                            : (isUrl ? 'URL' : context.l10n.get('text')),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isUrl
                              ? context.colors.accentPurple
                              : context.colors.textMuted,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Open URL compact button
                    if (isUrl)
                      GestureDetector(
                        onTap: () async {
                          final url = Uri.parse(item.content);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url,
                                mode: LaunchMode.externalApplication);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: context.colors.accentBlue.withAlpha(20),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: context.colors.accentBlue.withAlpha(55)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.open_in_new_rounded,
                                  size: 12, color: context.colors.accentBlue),
                              const SizedBox(width: 4),
                              Text(
                                  context.l10n.get('open'),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: context.colors.accentBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Copy hint (non-URL)
                    if (!isUrl)
                      Icon(Icons.copy_rounded,
                          size: 14, color: context.colors.textMuted),
                  ],
                ),

                const SizedBox(height: 8),

                // ── Content ──
                Text(
                  item.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyLarge.copyWith(fontSize: 13),
                ),

                const SizedBox(height: 8),

                // ── Timestamp ──
                Row(
                  children: [
                    Icon(Icons.access_time_rounded,
                        size: 11, color: context.colors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      FormatTime()
                          .coverTimeFromIso(item.scannedAt.toIso8601String()),
                      style: AppTextStyles.labelSmall,
                    ),
                    const Spacer(),
                    Text(
                      context.l10n.get('tap_to_copy'),
                      style: AppTextStyles.labelSmall
                          .copyWith(color: context.colors.textMuted.withAlpha(130)),
                    ),
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
