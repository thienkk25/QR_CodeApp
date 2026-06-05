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
import 'package:qr_code_app/main.dart';
import 'package:qr_code_app/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late final MobileScannerController controller;
  late bool isScanMode;
  bool isFlashOn = false;
  bool isScanned = false;
  late bool isAutoOpenLink;
  late bool isDarkMode;
  // Zoom — giá trị thực tế 1.0=normal .. 5.0=max
  double _zoomFactor = 1.0;
  double _baseZoomFactor = 1.0;
  static const double _minZoom = 1.0;
  static const double _maxZoom = 5.0;
  bool isLoading = true;
  bool _hasCameraPermission = false;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await checkScriptForWeb(context);
      await startSharedPreferences();
    });
  }

  Future<void> startSharedPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool? getAutoOpenLink = prefs.getBool('isAutoOpenLink');
    final bool? getScanMode = prefs.getBool('isScanMode');
    final bool? getDarkMode = prefs.getBool('isDarkMode');

    setState(() {
      isAutoOpenLink = getAutoOpenLink ?? false;
      isScanMode = getScanMode ?? false;
      isDarkMode = getDarkMode ?? true;
      isLoading = false;
    });
  }

  Future<void> _safeStopController() async {
    try {
      await controller.stop();
    } catch (_) {}
  }

  Future<void> _safeStartController() async {
    try {
      await controller.start();
    } catch (_) {}
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
    final granted = cameraStatus.isGranted || cameraStatus.isLimited;

    setState(() {
      _hasCameraPermission = granted;
    });

    if (!granted) {
      if (!cameraStatus.isPermanentlyDenied) {
        final status = await Permission.camera.request();
        setState(() {
          _hasCameraPermission = status.isGranted || status.isLimited;
        });
      }
    }

    final photoStatus = await Permission.photos.status;
    if (!photoStatus.isGranted && !photoStatus.isLimited) {
      if (!photoStatus.isPermanentlyDenied && !photoStatus.isRestricted) {
        await Permission.photos.request();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissionOnResume();
    }
    super.didChangeAppLifecycleState(state);
  }

  Future<void> _checkPermissionOnResume() async {
    final status = await Permission.camera.status;
    final granted = status.isGranted || status.isLimited;
    setState(() {
      _hasCameraPermission = granted;
    });
    if (granted && !isScanned) {
      await _safeStartController();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    controller.dispose();
  }

  // ── Loading Screen ──────────────────────────────────────
  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: context.colors.bgDeep,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: context.colors.accentGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: context.colors.accentPurple.withAlpha(100),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(Icons.qr_code_scanner,
                  color: Colors.white, size: 40),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: context.colors.accentPurple,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.get('starting'),
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionScreen() {
    return Scaffold(
      backgroundColor: context.colors.bgDeep,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  gradient: context.colors.accentGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: context.colors.accentPurple.withAlpha(80),
                      blurRadius: 40,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 42,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                context.l10n.get('camera_permission_required'),
                style: AppTextStyles.titleLarge
                    .copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                context.l10n.get('camera_permission_desc'),
                style: AppTextStyles.bodyMedium
                    .copyWith(color: context.colors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),
              GestureDetector(
                onTap: () async {
                  final status = await Permission.camera.request();
                  if (status.isGranted || status.isLimited) {
                    setState(() {
                      _hasCameraPermission = true;
                    });
                    await _safeStartController();
                  } else {
                    await openAppSettings();
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: context.colors.accentGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: context.colors.accentPurple.withAlpha(65),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    context.l10n.get('grant_permission'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  void _openSettings() {
    _safeStopController();
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
                    decoration: BoxDecoration(
                      color: context.colors.bgCardSolid,
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(24),
                      ),
                      border: Border(
                        left: BorderSide(color: context.colors.glassBorder),
                      ),
                    ),
                    child: _SettingsPanel(
                      isAutoOpenLink: isAutoOpenLink,
                      isScanMode: isScanMode,
                      isDarkMode: isDarkMode,
                      onDarkModeChanged: (v) async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('isDarkMode', v);
                        themeNotifier.value =
                            v ? ThemeMode.dark : ThemeMode.light;
                        setState(() => isDarkMode = v);
                      },
                      onAutoOpenLinkChanged: (v) async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('isAutoOpenLink', v);
                        setState(() => isAutoOpenLink = v);
                      },
                      onScanModeChanged: (v) async {
                        await _safeStopController();
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('isScanMode', v);
                        setState(() => isScanMode = v);
                      },
                      onHistoryTap: () {
                        Navigator.push(
                          context,
                          _slideRoute(const HistoryScannerScreen()),
                        ).then((_) => _safeStartController());
                      },
                      onHelpTap: () {
                        Navigator.push(
                          context,
                          _slideRoute(const HelpClientScreen()),
                        ).then((_) => _safeStartController());
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
    ).then((_) => _safeStartController());
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
    if (!_hasCameraPermission) return _buildPermissionScreen();

    return Scaffold(
      backgroundColor: context.colors.bgDeep,
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
          try {
            controller.setZoomScale(normalized.clamp(0.0, 1.0));
          } catch (e) {
            debugPrint('Set zoom scale failed: $e');
          }
        },
        onScaleEnd: (_) {
          // Giữ nguyên mức zoom sau khi nhả tay
          _baseZoomFactor = _zoomFactor;
        },
        child: isScanMode
            ? MobileScanOverlayScreen(
                controller: controller,
                isAutoOpenLink: isAutoOpenLink,
                autoOpenLink: autoOpenLink,
                manualOpenLink: manualOpenLink,
              )
            : MobileScanNormalScreen(
                controller: controller,
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
                  context.colors.bgDeep.withAlpha(220),
                  context.colors.bgDeep.withAlpha(100),
                ],
              ),
              border: Border(
                bottom: BorderSide(color: context.colors.glassBorder),
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
                      tooltip: context.l10n.get('create_code'),
                      onTap: () {
                        _safeStopController();
                        Navigator.push(
                          context,
                          _slideRoute(const CreateQrbarcodeScreen()),
                        ).then((_) => _safeStartController());
                      },
                    ),
                    const Spacer(),
                    // Title with gradient
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          context.colors.accentGradientH.createShader(bounds),
                      child: const Text(
                        'QR Scanner',
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
                      tooltip: context.l10n.get('settings'),
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
          padding: const EdgeInsets.only(top: 12, bottom: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                context.colors.bgDeep.withAlpha(230),
                context.colors.bgDeep.withAlpha(120),
              ],
            ),
            border: Border(
              top: BorderSide(color: context.colors.glassBorder),
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
                      label: context.l10n.get('flashlight'),
                      color: isFlashOn
                          ? context.colors.warning
                          : context.colors.textSecondary,
                      isActive: isFlashOn,
                      onTap: () async {
                        try {
                          await controller.toggleTorch();
                          setSt(() => isFlashOn = !isFlashOn);
                        } catch (e) {
                          debugPrint('Toggle torch failed: $e');
                        }
                      },
                    );
                  },
                ),

                // Gallery picker
                _BottomBtn(
                  icon: Icons.photo_library_rounded,
                  label: context.l10n.get('gallery'),
                  color: context.colors.textSecondary,
                  onTap: _pickFromGallery,
                ),

                // Switch camera
                _BottomBtn(
                  icon: Icons.cameraswitch_rounded,
                  label: context.l10n.get('switch_camera'),
                  color: context.colors.textSecondary,
                  onTap: () async {
                    try {
                      await controller.switchCamera();
                    } catch (e) {
                      debugPrint('Switch camera failed: $e');
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    await _safeStopController();
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
          await autoOpenLink(value, format: barcode?.format.name);
        } else {
          manualOpenLink(isUrl, value, format: barcode?.format.name);
        }
      } else {
        if (!mounted) return;
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (_) => AlertDialog(
            title: Text(context.l10n.get('invalid_image_format')),
            content: const Text("Vui lòng thử lại"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(context.l10n.get('close')),
              ),
            ],
          ),
        );
      }
      await controllerPhoto.dispose();
    }
    await _safeStartController();
  }

  Future<void> autoOpenLink(String value, {String? format}) async {
    saveHistory(value, format: format);
    HapticFeedback.mediumImpact();
    final url = Uri.parse(value);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> manualOpenLink(bool isUrl, String value,
      {String? format}) async {
    saveHistory(value, format: format);
    HapticFeedback.mediumImpact();
    if (!mounted) return;
    await showScanResultSheet(
      context: context,
      value: value,
      isUrl: isUrl,
      format: format,
      onClose: () => setState(() => isScanned = false),
    );
  }

  void saveHistory(String value, {String? format}) {
    final box = Hive.box<ScanHistoryModel>('scan_history');
    final history = ScanHistoryModel(
      content: value,
      scannedAt: DateTime.now(),
      format: format,
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
            color: context.colors.glassBlur,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.colors.glassBorder),
          ),
          child: Icon(icon, size: 20, color: context.colors.textPrimary),
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
        width: 100, // Cố định chiều rộng để 3 nút cân đối hoàn hảo
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? color.withAlpha(30) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isActive ? Border.all(color: color.withAlpha(80)) : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
  final bool isDarkMode;
  final ValueChanged<bool> onAutoOpenLinkChanged;
  final ValueChanged<bool> onScanModeChanged;
  final ValueChanged<bool> onDarkModeChanged;
  final VoidCallback onHistoryTap;
  final VoidCallback onHelpTap;

  const _SettingsPanel({
    required this.isAutoOpenLink,
    required this.isScanMode,
    required this.isDarkMode,
    required this.onAutoOpenLinkChanged,
    required this.onScanModeChanged,
    required this.onDarkModeChanged,
    required this.onHistoryTap,
    required this.onHelpTap,
  });

  @override
  State<_SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<_SettingsPanel> {
  late bool _autoOpen;
  late bool _scanMode;
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _autoOpen = widget.isAutoOpenLink;
    _scanMode = widget.isScanMode;
    _isDarkMode = widget.isDarkMode;
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
                  gradient: context.colors.accentGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.tune_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(context.l10n.get('settings'),
                  style: AppTextStyles.titleMedium),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: context.colors.bgSurface,
                    shape: BoxShape.circle,
                    border: Border.all(color: context.colors.glassBorder),
                  ),
                  child: Icon(Icons.close,
                      size: 16, color: context.colors.textSecondary),
                ),
              ),
            ],
          ),
        ),
        Divider(color: context.colors.glassBorder, height: 1),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              // History
              _SettingsTile(
                icon: Icons.history_rounded,
                iconColor: context.colors.accentBlue,
                title: context.l10n.get('scan_history'),
                subtitle: context.l10n.get('scan_history_sub'),
                onTap: () {
                  Navigator.pop(context);
                  widget.onHistoryTap();
                },
                trailing: Icon(Icons.chevron_right,
                    color: context.colors.textMuted, size: 20),
              ),

              const SizedBox(height: 8),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Text(context.l10n.get('customization'),
                    style: AppTextStyles.labelSmall),
              ),

              // Auto open link
              _SettingsTile(
                icon: Icons.open_in_browser_rounded,
                iconColor: context.colors.accentCyan,
                title: context.l10n.get('auto_open_url'),
                subtitle: context.l10n.get('auto_open_url_sub'),
                trailing: Switch(
                  value: _autoOpen,
                  onChanged: (v) {
                    setState(() => _autoOpen = v);
                    widget.onAutoOpenLinkChanged(v);
                  },
                ),
              ),

              // Dark mode toggle
              _SettingsTile(
                icon: _isDarkMode
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                iconColor: _isDarkMode
                    ? context.colors.accentBlue
                    : context.colors.warning,
                title: context.l10n.get('theme'),
                subtitle: _isDarkMode
                    ? context.l10n.get('dark_mode')
                    : context.l10n.get('light_mode'),
                trailing: Switch(
                  value: _isDarkMode,
                  onChanged: (v) {
                    setState(() => _isDarkMode = v);
                    widget.onDarkModeChanged(v);
                  },
                ),
              ),

              // Scan frame toggle
              _SettingsTile(
                icon: Icons.crop_free_rounded,
                iconColor: context.colors.accentPurple,
                title: context.l10n.get('enable_scan_frame'),
                subtitle: context.l10n.get('enable_scan_frame_sub'),
                trailing: Switch(
                  value: _scanMode,
                  onChanged: (v) {
                    setState(() => _scanMode = v);
                    widget.onScanModeChanged(v);
                  },
                ),
              ),

              // Language toggle
              _SettingsTile(
                icon: Icons.language_rounded,
                iconColor: context.colors.accentBlue,
                title: context.l10n.get('language'),
                subtitle: localeNotifier.value.languageCode == 'vi'
                    ? 'Tiếng Việt'
                    : 'English',
                trailing: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: localeNotifier.value.languageCode,
                    dropdownColor: context.colors.bgSurface,
                    style: TextStyle(color: context.colors.textPrimary),
                    icon: Icon(Icons.arrow_drop_down,
                        color: context.colors.textMuted),
                    items: const [
                      DropdownMenuItem(value: 'vi', child: Text('VI')),
                      DropdownMenuItem(value: 'en', child: Text('EN')),
                    ],
                    onChanged: (String? newValue) async {
                      if (newValue != null) {
                        localeNotifier.value = Locale(newValue);
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('language_code', newValue);
                      }
                    },
                  ),
                ),
              ),

              Divider(
                  color: context.colors.glassBorder, height: 24, indent: 20),

              // Help
              _SettingsTile(
                icon: Icons.help_outline_rounded,
                iconColor: context.colors.textSecondary,
                title: context.l10n.get('help'),
                subtitle: context.l10n.get('help_sub'),
                onTap: () {
                  Navigator.pop(context);
                  widget.onHelpTap();
                },
                trailing: Icon(Icons.chevron_right,
                    color: context.colors.textMuted, size: 20),
              ),
            ],
          ),
        ),

        // Footer
        Container(
          padding: const EdgeInsets.all(20),
          child: const Text(
            'QR Scanner  •  v1.5.0',
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
