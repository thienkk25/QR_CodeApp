import 'package:flutter/material.dart';
import 'package:qr_code_app/l10n/app_localizations.dart';
import 'package:qr_code_app/theme/app_theme.dart';

class HelpClientScreen extends StatelessWidget {
  const HelpClientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bgDeep,
      appBar: AppBar(
        title: Text(context.l10n.get('help')),
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: context.colors.accentGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: context.colors.accentPurple.withAlpha(80),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.qr_code_scanner, color: Colors.white, size: 48),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'QR Scanner',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.l10n.get('app_desc'),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              _SectionTitle(title: context.l10n.get('main_features')),
              const SizedBox(height: 12),

              _HelpCard(
                icon: Icons.flash_on_rounded,
                iconColor: context.colors.warning,
                title: context.l10n.get('flashlight'),
                description: context.l10n.get('flashlight_desc'),
              ),
              _HelpCard(
                icon: Icons.photo_library_rounded,
                iconColor: context.colors.accentBlue,
                title: context.l10n.get('photo_library'),
                description: context.l10n.get('photo_library_desc'),
              ),
              _HelpCard(
                icon: Icons.cameraswitch_rounded,
                iconColor: context.colors.accentCyan,
                title: context.l10n.get('switch_camera'),
                description: context.l10n.get('switch_camera_desc'),
              ),
              _HelpCard(
                icon: Icons.pinch_rounded,
                iconColor: context.colors.accentPurple,
                title: context.l10n.get('pinch_zoom'),
                description: context.l10n.get('pinch_zoom_desc'),
              ),

              const SizedBox(height: 20),
              _SectionTitle(title: context.l10n.get('settings')),
              const SizedBox(height: 12),

              _HelpCard(
                icon: Icons.history_rounded,
                iconColor: context.colors.accentBlue,
                title: context.l10n.get('scan_history'),
                description: context.l10n.get('scan_history_desc'),
              ),
              _HelpCard(
                icon: Icons.open_in_browser_rounded,
                iconColor: context.colors.accentCyan,
                title: context.l10n.get('auto_open_url'),
                description: context.l10n.get('auto_open_url_desc'),
              ),
              _HelpCard(
                icon: Icons.brightness_6_rounded,
                iconColor: context.colors.warning,
                title: context.l10n.get('theme'),
                description: context.l10n.get('theme_desc'),
              ),
              _HelpCard(
                icon: Icons.crop_free_rounded,
                iconColor: context.colors.accentPurple,
                title: context.l10n.get('enable_scan_frame'),
                description: context.l10n.get('enable_scan_frame_desc'),
              ),

              const SizedBox(height: 20),
              _SectionTitle(title: context.l10n.get('create_code')),
              const SizedBox(height: 12),

              _HelpCard(
                icon: Icons.add_box_outlined,
                iconColor: context.colors.accentPurple,
                title: context.l10n.get('create_qr_barcode'),
                description: context.l10n.get('create_qr_barcode_desc'),
              ),

              const SizedBox(height: 32),

              // Footer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colors.bgCardSolid,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.colors.glassBorder),
                ),
                child: Column(
                  children: [
                    Text(
                      context.l10n.get('developed_by'),
                      style: AppTextStyles.labelSmall,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Thiện Nguyễn',
                      style: TextStyle(
                        color: context.colors.accentPurple,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Version 1.3.0',
                      style: AppTextStyles.labelSmall,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            gradient: context.colors.accentGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.titleMedium,
        ),
      ],
    );
  }
}

class _HelpCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  const _HelpCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.bgCardSolid,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colors.glassBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyLarge),
                const SizedBox(height: 3),
                Text(description, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
