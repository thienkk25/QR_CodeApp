import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:qr_code_app/config/format_time.dart';
import 'package:qr_code_app/models/scan_history_model.dart';
import 'package:qr_code_app/theme/app_theme.dart';
import 'package:qr_code_app/l10n/app_localizations.dart';
import 'package:qr_code_app/widgets/custom_result_dialog.dart';

class HistoryScannerScreen extends StatefulWidget {
  const HistoryScannerScreen({super.key});

  @override
  State<HistoryScannerScreen> createState() => _HistoryScannerScreenState();
}

class _HistoryScannerScreenState extends State<HistoryScannerScreen> {
  final box = Hive.box<ScanHistoryModel>('scan_history');
  String _searchQuery = '';
  String _selectedFilter = 'all'; // all, url, wifi, contact, text

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
    if (confirmed == true) {
      box.clear();
      setState(() {});
    }
  }

  List<MapEntry<int, ScanHistoryModel>> _getFilteredHistory() {
    final List<MapEntry<int, ScanHistoryModel>> list = [];
    for (int i = 0; i < box.length; i++) {
      final item = box.getAt(i);
      if (item != null) {
        // Search filter
        final cleanContent = item.content.toLowerCase();
        if (_searchQuery.isNotEmpty && !cleanContent.contains(_searchQuery.toLowerCase())) {
          continue;
        }

        // Tab category filter
        if (_selectedFilter != 'all') {
          final parsed = parseBarcodeContent(item.content);
          if (_selectedFilter == 'url' && parsed.type != ParsedContentType.url) {
            continue;
          }
          if (_selectedFilter == 'wifi' && parsed.type != ParsedContentType.wifi) {
            continue;
          }
          if (_selectedFilter == 'contact' && parsed.type != ParsedContentType.contact) {
            continue;
          }
          if (_selectedFilter == 'text' && 
              parsed.type != ParsedContentType.text && 
              parsed.type != ParsedContentType.phone && 
              parsed.type != ParsedContentType.sms && 
              parsed.type != ParsedContentType.email && 
              parsed.type != ParsedContentType.geo) {
            continue;
          }
        }

        list.add(MapEntry(i, item));
      }
    }
    return list.reversed.toList();
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

          final filteredItems = _getFilteredHistory();

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              _buildSearchBarAndFilters(),
              if (filteredItems.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 48,
                          color: context.colors.textMuted,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Không tìm thấy kết quả phù hợp',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: context.colors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final entry = filteredItems[index];
                        // pass direct index for deletion mapping
                        return _buildHistoryCard(context, entry.value, entry.key);
                      },
                      childCount: filteredItems.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
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
        centerTitle: true,
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
      floating: false,
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
    );
  }

  Widget _buildSearchBarAndFilters() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: Column(
          children: [
            // Search Input
            Container(
              decoration: BoxDecoration(
                color: context.colors.bgCardSolid,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.colors.glassBorder),
              ),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                style: TextStyle(color: context.colors.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm nội dung lịch sử...',
                  hintStyle: TextStyle(color: context.colors.textMuted, fontSize: 13.5),
                  prefixIcon: Icon(Icons.search_rounded, color: context.colors.textSecondary, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded, color: context.colors.textSecondary, size: 18),
                          onPressed: () {
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Filter Chips Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildFilterChip('all', 'Tất cả', Icons.all_inclusive_rounded),
                  _buildFilterChip('url', 'Liên kết', Icons.link_rounded),
                  _buildFilterChip('wifi', 'Wi-Fi', Icons.wifi_rounded),
                  _buildFilterChip('contact', 'Liên hệ', Icons.contact_phone_rounded),
                  _buildFilterChip('text', 'Văn bản', Icons.text_snippet_rounded),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String filter, String label, IconData icon) {
    final isSelected = _selectedFilter == filter;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilter = filter),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? context.colors.accentPurple.withAlpha(25) : context.colors.bgCardSolid,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? context.colors.accentPurple : context.colors.glassBorder,
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? context.colors.accentPurple : context.colors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? context.colors.accentPurple : context.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, ScanHistoryModel item, int originalIndex) {
    final parsed = parseBarcodeContent(item.content);
    final isUrl = parsed.type == ParsedContentType.url;
    final domain = isUrl ? Uri.tryParse(item.content)?.host ?? '' : '';

    return Dismissible(
      key: Key('history_${originalIndex}_${item.scannedAt}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
      onDismissed: (_) {
        box.deleteAt(originalIndex);
        setState(() {});
      },
      child: GestureDetector(
        onTap: () {
          showScanResultSheet(
            context: context,
            value: item.content,
            isUrl: isUrl,
            format: item.format,
            onClose: () {},
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: context.colors.bgCardSolid,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.colors.glassBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icon
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isUrl
                            ? context.colors.accentPurple.withAlpha(25)
                            : context.colors.bgSurface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isUrl
                              ? context.colors.accentPurple.withAlpha(55)
                              : context.colors.glassBorder,
                        ),
                      ),
                      child: Icon(
                        parsed.icon,
                        size: 18,
                        color: isUrl ? context.colors.accentPurple : context.colors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Label / domain + format badge
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isUrl && domain.isNotEmpty
                                ? domain
                                : parsed.displayTitle,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: isUrl ? context.colors.accentPurple : context.colors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: context.colors.accentPurple.withAlpha(18),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              (item.format ?? 'QR CODE').toUpperCase(),
                              style: TextStyle(
                                fontSize: 9,
                                color: context.colors.accentPurple,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Navigation icon indicators
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: context.colors.textMuted,
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Content preview
                Text(
                  item.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13,
                    color: context.colors.textSecondary,
                  ),
                ),

                const SizedBox(height: 10),

                // Timestamp
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 12, color: context.colors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      FormatTime().coverTimeFromIso(item.scannedAt.toIso8601String()),
                      style: AppTextStyles.labelSmall.copyWith(color: context.colors.textMuted),
                    ),
                    const Spacer(),
                    Text(
                      'Xem chi tiết',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: context.colors.accentPurple,
                        fontWeight: FontWeight.w600,
                      ),
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
