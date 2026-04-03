import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_app/screens/create_qrbarcode_screen.dart';
import 'package:qr_code_app/screens/help_client_screen.dart';
import 'package:qr_code_app/screens/history_scanner_screen.dart';
import 'package:qr_code_app/screens/mobile_scan_normal_screen.dart';
import 'package:qr_code_app/screens/mobile_scan_overlay_screen.dart';
import 'package:qr_code_app/models/scan_history_model.dart';
import 'package:qr_code_app/theme/app_theme.dart';
import 'package:qr_code_app/widgets/custom_result_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  MobileScannerController? controller;
  late bool isScanMode;
  bool isFlashOn = false;
  bool isScanned = false;
  late bool isAutoOpenLink;
  // Zoom — giá trị thực tế 1.0=normal .. 5.0=max
  double _zoomFactor = 1.0;
  double _baseZoomFactor = 1.0;
  static const double _minZoom = 1.0;
  static const double _maxZoom = 5.0;
  bool isLoading = true;

  late AnimationController _fabAnimController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await checkScriptForWeb(context);
      await startSharedPreferences();
    });

    _fabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  void toggleMode(MobileScannerController controllerChild) async {
    if (controller != controllerChild) {
      setState(() {
        controller = controllerChild;
      });
    }
    _fabAnimController.forward(from: 0);
  }

  Future<void> startSharedPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool? getAutoOpenLink = prefs.getBool('isAutoOpenLink');
    final bool? getScanMode = prefs.getBool('isScanMode');

    setState(() {
      isAutoOpenLink = getAutoOpenLink ?? false;
      isScanMode = getScanMode ?? false;
      isLoading = false;
    });
  }

  Future<void> checkScriptForWeb(BuildContext context) async {
    if (kIsWeb) {
      const scriptUrl = 'https://unpkg.com/@zxing/library@latest';
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
      controller?.start();
      setState(() => isScanned = false);
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _fabAnimController.dispose();
    super.dispose();
    controller?.dispose();
  }

  // ── Loading Screen ──────────────────────────────────────
  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentPurple.withAlpha(100),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(Icons.qr_code_scanner,
                  color: Colors.white, size: 40),
            ),
            const SizedBox(height: 24),
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.accentPurple,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Đang khởi động...',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  // ── Settings drawer (slide-in from right) ───────────────
  void _openSettings() {
    controller?.stop();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Cài đặt",
      barrierColor: Colors.black54,
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
          child: Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(24),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    height: double.infinity,
                    width: MediaQuery.of(context).size.width * 0.82,
                    decoration: const BoxDecoration(
                      color: AppColors.bgCardSolid,
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(24),
                      ),
                      border: Border(
                        left: BorderSide(color: AppColors.glassBorder),
                      ),
                    ),
                    child: _SettingsPanel(
                      isAutoOpenLink: isAutoOpenLink,
                      isScanMode: isScanMode,
                      onAutoOpenLinkChanged: (v) async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('isAutoOpenLink', v);
                        setState(() => isAutoOpenLink = v);
                      },
                      onScanModeChanged: (v) async {
                        controller?.stop();
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('isScanMode', v);
                        setState(() => isScanMode = v);
                      },
                      onHistoryTap: () {
                        Navigator.push(
                          context,
                          _slideRoute(const HistoryScannerScreen()),
                        ).then((_) => controller?.start());
                      },
                      onHelpTap: () {
                        Navigator.push(
                          context,
                          _slideRoute(const HelpClientScreen()),
                        ).then((_) => controller?.start());
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 320),
    ).then((_) => controller?.start());
  }

  PageRoute _slideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, a, b) => page,
      transitionsBuilder: (_, anim, __, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
        child: FadeTransition(opacity: anim, child: child),
      ),
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return _buildLoadingScreen();

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: GestureDetector(
        onScaleStart: (details) {
          if (details.pointerCount < 2) return;
          _baseZoomFactor = _zoomFactor;
        },
        onScaleUpdate: (details) {
          if (details.pointerCount < 2) return; // chỉ xử lý pinch 2 ngón
          final newZoom =
              (_baseZoomFactor * details.scale).clamp(_minZoom, _maxZoom);
          // Threshold tránh noise nhỏ gây giật
          if ((newZoom - _zoomFactor).abs() < 0.02) return;
          _zoomFactor = newZoom;
          // Normalize sang 0.0–1.0 mà setZoomScale yêu cầu
          final normalized = (newZoom - _minZoom) / (_maxZoom - _minZoom);
          controller?.setZoomScale(normalized.clamp(0.0, 1.0));
        },
        onScaleEnd: (_) {
          // Giữ nguyên mức zoom sau khi nhả tay
          _baseZoomFactor = _zoomFactor;
        },
        child: isScanMode
            ? MobileScanOverlayScreen(
                toggleMode: toggleMode,
                isAutoOpenLink: isAutoOpenLink,
                autoOpenLink: autoOpenLink,
                manualOpenLink: manualOpenLink,
              )
            : MobileScanNormalScreen(
                toggleMode: toggleMode,
                isAutoOpenLink: isAutoOpenLink,
                autoOpenLink: autoOpenLink,
                manualOpenLink: manualOpenLink,
              ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.bgDeep.withAlpha(220),
                  AppColors.bgDeep.withAlpha(100),
                ],
              ),
              border: const Border(
                bottom: BorderSide(color: AppColors.glassBorder),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: 60,
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    // Create QR button
                    _AppBarBtn(
                      icon: Icons.add_box_outlined,
                      tooltip: 'Tạo mã',
                      onTap: () {
                        controller?.stop();
                        Navigator.push(
                          context,
                          _slideRoute(const CreateQrbarcodeScreen()),
                        ).then((_) => controller?.start());
                      },
                    ),
                    const Spacer(),
                    // Title with gradient
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppColors.accentGradientH.createShader(bounds),
                      child: const Text(
                        'QR Scanner Pro',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Settings button
                    _AppBarBtn(
                      icon: Icons.tune_rounded,
                      tooltip: 'Cài đặt',
                      onTap: _openSettings,
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                AppColors.bgDeep.withAlpha(230),
                AppColors.bgDeep.withAlpha(120),
              ],
            ),
            border: const Border(
              top: BorderSide(color: AppColors.glassBorder),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Flash toggle
                StatefulBuilder(
                  builder: (context, setSt) {
                    return _BottomBtn(
                      icon: isFlashOn
                          ? Icons.flash_on_rounded
                          : Icons.flash_off_rounded,
                      label: isFlashOn ? 'Đèn bật' : 'Đèn tắt',
                      color: isFlashOn
                          ? AppColors.warning
                          : AppColors.textSecondary,
                      isActive: isFlashOn,
                      onTap: () {
                        controller?.toggleTorch();
                        setSt(() => isFlashOn = !isFlashOn);
                      },
                    );
                  },
                ),

                // Gallery picker
                _BottomBtn(
                  icon: Icons.photo_library_rounded,
                  label: 'Thư viện',
                  color: AppColors.textSecondary,
                  onTap: _pickFromGallery,
                ),

                // Switch camera
                _BottomBtn(
                  icon: Icons.cameraswitch_rounded,
                  label: 'Đổi camera',
                  color: AppColors.textSecondary,
                  onTap: () => controller?.switchCamera(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    await controller?.stop();
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (isScanned) return;
      final MobileScannerController controllerPhoto = MobileScannerController();
      final BarcodeCapture? capture =
          await controllerPhoto.analyzeImage(image.path);
      final barcode = capture?.barcodes.firstOrNull;
      final value = barcode?.rawValue;
      if (value != null) {
        final uri = Uri.tryParse(value);
        final isUrl = uri != null &&
            (uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https'));
        setState(() => isScanned = true);
        if (isUrl && isAutoOpenLink) {
          await autoOpenLink(value);
        } else {
          manualOpenLink(isUrl, value);
        }
      } else {
        if (!mounted) return;
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Ảnh không đúng định dạng'),
            content: const Text("Vui lòng thử lại"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
            ],
          ),
        );
      }
      await controllerPhoto.dispose();
    }
    await controller?.start();
  }

  Future<void> autoOpenLink(String value) async {
    saveHistory(value);
    HapticFeedback.mediumImpact();
    final url = Uri.parse(value);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> manualOpenLink(bool isUrl, String value) async {
    saveHistory(value);
    HapticFeedback.mediumImpact();
    if (!mounted) return;
    await showScanResultSheet(
      context: context,
      value: value,
      isUrl: isUrl,
      onClose: () => setState(() => isScanned = false),
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

// ── AppBar button widget ─────────────────────────────────
class _AppBarBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _AppBarBtn({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.glassBlur,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Icon(icon, size: 20, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

// ── Bottom bar icon button ───────────────────────────────
class _BottomBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isActive;

  const _BottomBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? color.withAlpha(30) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isActive ? Border.all(color: color.withAlpha(80)) : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Settings Panel ───────────────────────────────────────
class _SettingsPanel extends StatefulWidget {
  final bool isAutoOpenLink;
  final bool isScanMode;
  final ValueChanged<bool> onAutoOpenLinkChanged;
  final ValueChanged<bool> onScanModeChanged;
  final VoidCallback onHistoryTap;
  final VoidCallback onHelpTap;

  const _SettingsPanel({
    required this.isAutoOpenLink,
    required this.isScanMode,
    required this.onAutoOpenLinkChanged,
    required this.onScanModeChanged,
    required this.onHistoryTap,
    required this.onHelpTap,
  });

  @override
  State<_SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<_SettingsPanel> {
  late bool _autoOpen;
  late bool _scanMode;

  @override
  void initState() {
    super.initState();
    _autoOpen = widget.isAutoOpenLink;
    _scanMode = widget.isScanMode;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 16, 20),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.tune_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Cài đặt', style: AppTextStyles.titleMedium),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.bgSurface,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: const Icon(Icons.close,
                      size: 16, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
        const Divider(color: AppColors.glassBorder, height: 1),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              // History
              _SettingsTile(
                icon: Icons.history_rounded,
                iconColor: AppColors.accentBlue,
                title: 'Lịch sử quét',
                subtitle: 'Xem lại các mã đã quét',
                onTap: () {
                  Navigator.pop(context);
                  widget.onHistoryTap();
                },
                trailing: const Icon(Icons.chevron_right,
                    color: AppColors.textMuted, size: 20),
              ),

              const SizedBox(height: 8),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Text('Tuỳ chỉnh', style: AppTextStyles.labelSmall),
              ),

              // Auto open link
              _SettingsTile(
                icon: Icons.open_in_browser_rounded,
                iconColor: AppColors.accentCyan,
                title: 'Tự động mở liên kết',
                subtitle: 'Mở trình duyệt khi quét URL',
                trailing: Switch(
                  value: _autoOpen,
                  onChanged: (v) {
                    setState(() => _autoOpen = v);
                    widget.onAutoOpenLinkChanged(v);
                  },
                ),
              ),

              // Scan frame toggle
              _SettingsTile(
                icon: Icons.crop_free_rounded,
                iconColor: AppColors.accentPurple,
                title: 'Bật khung quét',
                subtitle: 'Hiển thị khung QR scanner',
                trailing: Switch(
                  value: _scanMode,
                  onChanged: (v) {
                    setState(() => _scanMode = v);
                    widget.onScanModeChanged(v);
                  },
                ),
              ),

              const Divider(
                  color: AppColors.glassBorder, height: 24, indent: 20),

              // Help
              _SettingsTile(
                icon: Icons.help_outline_rounded,
                iconColor: AppColors.textSecondary,
                title: 'Hướng dẫn',
                subtitle: 'Hướng dẫn sử dụng ứng dụng',
                onTap: () {
                  Navigator.pop(context);
                  widget.onHelpTap();
                },
                trailing: const Icon(Icons.chevron_right,
                    color: AppColors.textMuted, size: 20),
              ),
            ],
          ),
        ),

        // Footer
        Container(
          padding: const EdgeInsets.all(20),
          child: const Text(
            'QR Scanner Pro  •  v1.3.0',
            style: AppTextStyles.labelSmall,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withAlpha(30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyLarge),
                  Text(subtitle, style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
