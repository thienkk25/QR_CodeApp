import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_app/theme/app_theme.dart';
import 'package:qr_code_app/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:share_plus/share_plus.dart';

/// Supported smart content types
enum ParsedContentType {
  url,
  wifi,
  contact,
  phone,
  sms,
  email,
  geo,
  text,
}

/// Structured parsed result
class ParsedResult {
  final ParsedContentType type;
  final String displayTitle;
  final String displaySubtitle;
  final IconData icon;
  final Map<String, String> data;

  ParsedResult({
    required this.type,
    required this.displayTitle,
    required this.displaySubtitle,
    required this.icon,
    required this.data,
  });
}

/// Parses the barcode string content into a structured format
ParsedResult parseBarcodeContent(String value) {
  final cleanValue = value.trim();
  final lowerValue = cleanValue.toLowerCase();

  // 1. Wi-Fi: WIFI:S:SSID;T:WPA;P:Password;;
  if (lowerValue.startsWith('wifi:')) {
    String ssid = '';
    String password = '';
    String security = 'WPA';

    final noPrefix = cleanValue.substring(5);
    final parts = noPrefix.split(';');
    for (var part in parts) {
      if (part.startsWith('S:')) ssid = part.substring(2);
      if (part.startsWith('P:')) password = part.substring(2);
      if (part.startsWith('T:')) security = part.substring(2);
    }
    return ParsedResult(
      type: ParsedContentType.wifi,
      displayTitle: ssid.isNotEmpty ? ssid : 'Wi-Fi Network',
      displaySubtitle: 'Mạng Wi-Fi ($security)',
      icon: Icons.wifi_rounded,
      data: {'ssid': ssid, 'password': password, 'security': security},
    );
  }

  // 2. Contact (vCard): BEGIN:VCARD
  if (lowerValue.contains('begin:vcard') || lowerValue.startsWith('mecard:')) {
    String name = '';
    String phone = '';
    String email = '';

    if (lowerValue.startsWith('mecard:')) {
      final parts = cleanValue.substring(7).split(';');
      for (var part in parts) {
        if (part.startsWith('N:')) name = part.substring(2);
        if (part.startsWith('TEL:')) phone = part.substring(4);
        if (part.startsWith('EMAIL:')) email = part.substring(6);
      }
    } else {
      final lines = cleanValue.split(RegExp(r'\r?\n'));
      for (var line in lines) {
        final upperLine = line.toUpperCase();
        if (upperLine.startsWith('FN:')) {
          name = line.substring(3);
        } else if (upperLine.startsWith('N:') && name.isEmpty) {
          final parts = line.substring(2).split(';');
          name = parts.where((p) => p.isNotEmpty).join(' ');
        } else if (upperLine.startsWith('TEL:') || upperLine.startsWith('TEL;')) {
          final idx = line.indexOf(':');
          if (idx != -1) phone = line.substring(idx + 1);
        } else if (upperLine.startsWith('EMAIL:') || upperLine.startsWith('EMAIL;')) {
          final idx = line.indexOf(':');
          if (idx != -1) email = line.substring(idx + 1);
        }
      }
    }

    return ParsedResult(
      type: ParsedContentType.contact,
      displayTitle: name.isNotEmpty ? name : 'Liên hệ',
      displaySubtitle: 'Thông tin danh bạ',
      icon: Icons.contact_phone_rounded,
      data: {'name': name, 'phone': phone, 'email': email},
    );
  }

  // 3. Geo/Map coordinates: geo:lat,lon
  if (lowerValue.startsWith('geo:')) {
    final geoData = cleanValue.substring(4);
    final queryParts = geoData.split('?');
    final coords = queryParts[0].split(',');
    String lat = coords.isNotEmpty ? coords[0] : '0';
    String lon = coords.length > 1 ? coords[1] : '0';

    return ParsedResult(
      type: ParsedContentType.geo,
      displayTitle: 'Tọa độ GPS',
      displaySubtitle: '$lat, $lon',
      icon: Icons.map_rounded,
      data: {'lat': lat, 'lon': lon},
    );
  }

  // 4. SMS: smsto:phone:message
  if (lowerValue.startsWith('smsto:') || lowerValue.startsWith('sms:')) {
    String phone = '';
    String body = '';
    if (lowerValue.startsWith('smsto:')) {
      final parts = cleanValue.substring(6).split(':');
      phone = parts.isNotEmpty ? parts[0] : '';
      body = parts.length > 1 ? parts.sublist(1).join(':') : '';
    } else {
      final parts = cleanValue.substring(4).split('?');
      phone = parts.isNotEmpty ? parts[0] : '';
      if (parts.length > 1 && parts[1].startsWith('body=')) {
        body = Uri.decodeComponent(parts[1].substring(5));
      }
    }
    return ParsedResult(
      type: ParsedContentType.sms,
      displayTitle: phone.isNotEmpty ? phone : 'Gửi SMS',
      displaySubtitle: 'Tin nhắn văn bản',
      icon: Icons.sms_rounded,
      data: {'phone': phone, 'body': body},
    );
  }

  // 5. Phone: tel:xxx or pure digits
  if (lowerValue.startsWith('tel:') || RegExp(r'^\+?[0-9\s\-]{7,15}$').hasMatch(cleanValue)) {
    final phone = lowerValue.startsWith('tel:') ? cleanValue.substring(4) : cleanValue;
    return ParsedResult(
      type: ParsedContentType.phone,
      displayTitle: phone,
      displaySubtitle: 'Số điện thoại',
      icon: Icons.phone_rounded,
      data: {'phone': phone},
    );
  }

  // 6. Email: mailto:xxx
  if (lowerValue.startsWith('mailto:') || RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(cleanValue)) {
    final email = lowerValue.startsWith('mailto:') ? cleanValue.substring(7).split('?')[0] : cleanValue;
    return ParsedResult(
      type: ParsedContentType.email,
      displayTitle: email,
      displaySubtitle: 'Địa chỉ Email',
      icon: Icons.email_rounded,
      data: {'email': email},
    );
  }

  // 7. URL Link
  final uri = Uri.tryParse(cleanValue);
  final isUrl = uri != null &&
      (uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https'));
  if (isUrl) {
    return ParsedResult(
      type: ParsedContentType.url,
      displayTitle: uri.host,
      displaySubtitle: 'Liên kết Website',
      icon: Icons.link_rounded,
      data: {'url': cleanValue},
    );
  }

  // 8. Plain Text fallback
  return ParsedResult(
    type: ParsedContentType.text,
    displayTitle: cleanValue.length > 30 ? '${cleanValue.substring(0, 30)}...' : cleanValue,
    displaySubtitle: 'Văn bản thường',
    icon: Icons.text_snippet_rounded,
    data: {'text': cleanValue},
  );
}

/// Custom bottom sheet that replaces AlertDialog for scan results.
/// Displays detailed smart content parser fields and custom actions.
Future<void> showScanResultSheet({
  required BuildContext context,
  required String value,
  required bool isUrl,
  String? format,
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
      format: format,
      onClose: onClose,
    ),
  );
}

class _ScanResultSheet extends StatefulWidget {
  final String value;
  final bool isUrl;
  final String? format;
  final VoidCallback onClose;

  const _ScanResultSheet({
    required this.value,
    required this.isUrl,
    this.format,
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
  late ParsedResult _parsed;

  // Wi-Fi states
  bool _obscureWifiPassword = true;
  bool _isConnectingWifi = false;
  bool? _wifiConnectSuccess;

  @override
  void initState() {
    super.initState();
    _parsed = parseBarcodeContent(widget.value);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _copyToClipboard(String text, String messageKey) async {
    await Clipboard.setData(ClipboardData(text: text));
    setState(() => _copied = true);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: context.colors.success, size: 18),
            const SizedBox(width: 8),
            Text(context.l10n.get(messageKey)),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  // programmatically connect to wifi
  Future<void> _connectToWifi(String ssid, String password, String security) async {
    setState(() {
      _isConnectingWifi = true;
      _wifiConnectSuccess = null;
    });

    try {
      NetworkSecurity securityType = NetworkSecurity.NONE;
      if (security.toUpperCase() == 'WPA' || security.toUpperCase() == 'WPA2') {
        securityType = NetworkSecurity.WPA;
      } else if (security.toUpperCase() == 'WEP') {
        securityType = NetworkSecurity.WEP;
      }

      final result = await WiFiForIoTPlugin.connect(
        ssid,
        password: password,
        security: securityType,
        joinOnce: false,
      );

      setState(() {
        _isConnectingWifi = false;
        _wifiConnectSuccess = result;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                result ? Icons.check_circle_rounded : Icons.error_rounded,
                color: result ? context.colors.success : context.colors.error,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                result
                    ? context.l10n.get('wifi_connected')
                    : context.l10n.get('wifi_connect_failed'),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      setState(() {
        _isConnectingWifi = false;
        _wifiConnectSuccess = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_rounded, color: context.colors.error, size: 18),
              const SizedBox(width: 8),
              Text('${context.l10n.get('wifi_connect_failed')}: $e'),
            ],
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _launch(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _shareContent() async {
    await SharePlus.instance.share(
      ShareParams(
        text: widget.value,
        subject: 'Scanned via QR Scanner',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.colors.bgCardSolid,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: context.colors.glassBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: context.colors.accentPurple.withAlpha(40),
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
                      color: context.colors.textMuted,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Header with custom icon and formats
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: context.colors.accentGradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: context.colors.accentPurple.withAlpha(60),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: Icon(
                        _parsed.icon,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.get('scan_successful'),
                            style: AppTextStyles.titleMedium,
                          ),
                          Text(
                            widget.format != null
                                ? '${widget.format!.toUpperCase()} • ${_parsed.displaySubtitle}'
                                : _parsed.displaySubtitle,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: context.colors.accentPurple,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        widget.onClose();
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: context.colors.bgSurface,
                          shape: BoxShape.circle,
                          border: Border.all(color: context.colors.glassBorder),
                        ),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Content Panel (Smart Render)
                _buildContentPanel(context),

                const SizedBox(height: 18),

                // Action Buttons Row
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentPanel(BuildContext context) {
    switch (_parsed.type) {
      case ParsedContentType.wifi:
        final ssid = _parsed.data['ssid'] ?? '';
        final password = _parsed.data['password'] ?? '';
        final security = _parsed.data['security'] ?? '';
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.bgSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.colors.glassBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(context, Icons.wifi_tethering_rounded, 'SSID', ssid),
              const Divider(height: 20, color: Colors.white12),
              _buildInfoRow(
                context,
                Icons.security_rounded,
                'Security',
                security,
              ),
              if (password.isNotEmpty) ...[
                const Divider(height: 20, color: Colors.white12),
                Row(
                  children: [
                    Icon(Icons.lock_rounded, size: 18, color: context.colors.textSecondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Password', style: AppTextStyles.labelSmall),
                          const SizedBox(height: 2),
                          Text(
                            _obscureWifiPassword ? '••••••••' : password,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontFamily: _obscureWifiPassword ? null : 'monospace',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _obscureWifiPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                        size: 18,
                        color: context.colors.textSecondary,
                      ),
                      onPressed: () => setState(() => _obscureWifiPassword = !_obscureWifiPassword),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );

      case ParsedContentType.contact:
        final name = _parsed.data['name'] ?? '';
        final phone = _parsed.data['phone'] ?? '';
        final email = _parsed.data['email'] ?? '';
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.bgSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.colors.glassBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(context, Icons.person_rounded, 'Tên', name),
              if (phone.isNotEmpty) ...[
                const Divider(height: 20, color: Colors.white12),
                _buildInfoRow(context, Icons.phone_rounded, 'Điện thoại', phone),
              ],
              if (email.isNotEmpty) ...[
                const Divider(height: 20, color: Colors.white12),
                _buildInfoRow(context, Icons.email_rounded, 'Email', email),
              ],
            ],
          ),
        );

      case ParsedContentType.geo:
        final lat = _parsed.data['lat'] ?? '';
        final lon = _parsed.data['lon'] ?? '';
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.bgSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.colors.glassBorder),
          ),
          child: Row(
            children: [
              Icon(Icons.location_on_rounded, color: context.colors.error, size: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Vĩ độ (Latitude)', style: AppTextStyles.labelSmall),
                    Text(lat, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text('Kinh độ (Longitude)', style: AppTextStyles.labelSmall),
                    Text(lon, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        );

      case ParsedContentType.sms:
        final phone = _parsed.data['phone'] ?? '';
        final body = _parsed.data['body'] ?? '';
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.bgSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.colors.glassBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(context, Icons.phone_android_rounded, 'Đến số', phone),
              if (body.isNotEmpty) ...[
                const Divider(height: 20, color: Colors.white12),
                _buildInfoRow(context, Icons.chat_bubble_outline_rounded, 'Nội dung', body),
              ],
            ],
          ),
        );

      default:
        // Text, URL, Email, Phone
        return Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxHeight: 140),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.bgSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.colors.glassBorder),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: SelectionArea(
              child: Text(
                widget.value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontFamily: _parsed.type == ParsedContentType.url ? 'monospace' : null,
                  fontSize: 13.5,
                  height: 1.45,
                ),
              ),
            ),
          ),
        );
    }
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: context.colors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.labelSmall),
              const SizedBox(height: 2),
              Text(
                value.isNotEmpty ? value : '(Trống)',
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final List<Widget> buttons = [];

    // Copy / Share fallback buttons
    final Widget copyBtn = _ActionBtn(
      icon: _copied ? Icons.check_circle_rounded : Icons.copy_rounded,
      label: _copied ? context.l10n.get('copied') : context.l10n.get('copy'),
      onTap: () {
        if (_parsed.type == ParsedContentType.wifi) {
          final pass = _parsed.data['password'] ?? '';
          _copyToClipboard(pass, 'copied_to_clipboard');
        } else {
          _copyToClipboard(widget.value, 'copied_to_clipboard');
        }
      },
      color: _copied ? context.colors.success : context.colors.textSecondary,
      filled: false,
    );

    final Widget shareBtn = _ActionBtn(
      icon: Icons.share_rounded,
      label: context.l10n.get('share_code'),
      onTap: _shareContent,
      color: context.colors.textSecondary,
      filled: false,
    );

    switch (_parsed.type) {
      case ParsedContentType.wifi:
        final ssid = _parsed.data['ssid'] ?? '';
        final password = _parsed.data['password'] ?? '';
        final security = _parsed.data['security'] ?? '';

        buttons.add(
          Expanded(
            child: _ActionBtn(
              icon: _isConnectingWifi
                  ? Icons.hourglass_top_rounded
                  : _wifiConnectSuccess == true
                      ? Icons.wifi_protected_setup_rounded
                      : Icons.wifi_find_rounded,
              label: _isConnectingWifi
                  ? 'Đang kết nối...'
                  : _wifiConnectSuccess == true
                      ? 'Đã kết nối'
                      : context.l10n.get('connect_wifi'),
              onTap: _isConnectingWifi ? () {} : () => _connectToWifi(ssid, password, security),
              color: _wifiConnectSuccess == true ? context.colors.success : context.colors.accentBlue,
              filled: true,
            ),
          ),
        );
        buttons.add(const SizedBox(width: 10));
        buttons.add(Expanded(child: copyBtn));
        break;

      case ParsedContentType.contact:
        final phone = _parsed.data['phone'] ?? '';
        final email = _parsed.data['email'] ?? '';

        if (phone.isNotEmpty) {
          buttons.add(
            Expanded(
              child: _ActionBtn(
                icon: Icons.call_rounded,
                label: context.l10n.get('call'),
                onTap: () => _launch('tel:$phone'),
                color: context.colors.success,
                filled: true,
              ),
            ),
          );
        }
        if (email.isNotEmpty) {
          if (buttons.isNotEmpty) buttons.add(const SizedBox(width: 10));
          buttons.add(
            Expanded(
              child: _ActionBtn(
                icon: Icons.alternate_email_rounded,
                label: context.l10n.get('send_email'),
                onTap: () => _launch('mailto:$email'),
                color: context.colors.accentBlue,
                filled: true,
              ),
            ),
          );
        }
        if (buttons.isEmpty) {
          buttons.add(Expanded(child: copyBtn));
          buttons.add(const SizedBox(width: 10));
          buttons.add(Expanded(child: shareBtn));
        } else {
          // Add small secondary copy action
          buttons.add(const SizedBox(width: 10));
          buttons.add(
            GestureDetector(
              onTap: () => _copyToClipboard(widget.value, 'copied_to_clipboard'),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: context.colors.bgSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.colors.glassBorder),
                ),
                child: Icon(
                  _copied ? Icons.check_circle_rounded : Icons.copy_rounded,
                  color: _copied ? context.colors.success : context.colors.textSecondary,
                  size: 20,
                ),
              ),
            ),
          );
        }
        break;

      case ParsedContentType.geo:
        final lat = _parsed.data['lat'] ?? '';
        final lon = _parsed.data['lon'] ?? '';
        buttons.add(
          Expanded(
            child: _ActionBtn(
              icon: Icons.map_rounded,
              label: context.l10n.get('open_maps'),
              onTap: () => _launch('https://www.google.com/maps/search/?api=1&query=$lat,$lon'),
              color: context.colors.accentPurple,
              filled: true,
            ),
          ),
        );
        buttons.add(const SizedBox(width: 10));
        buttons.add(Expanded(child: copyBtn));
        break;

      case ParsedContentType.sms:
        final phone = _parsed.data['phone'] ?? '';
        final body = _parsed.data['body'] ?? '';
        buttons.add(
          Expanded(
            child: _ActionBtn(
              icon: Icons.sms_rounded,
              label: context.l10n.get('send_sms'),
              onTap: () => _launch('sms:$phone?body=${Uri.encodeComponent(body)}'),
              color: context.colors.accentCyan,
              filled: true,
            ),
          ),
        );
        buttons.add(const SizedBox(width: 10));
        buttons.add(Expanded(child: copyBtn));
        break;

      case ParsedContentType.phone:
        final phone = _parsed.data['phone'] ?? '';
        buttons.add(
          Expanded(
            child: _ActionBtn(
              icon: Icons.call_rounded,
              label: context.l10n.get('call'),
              onTap: () => _launch('tel:$phone'),
              color: context.colors.success,
              filled: true,
            ),
          ),
        );
        buttons.add(const SizedBox(width: 10));
        buttons.add(
          Expanded(
            child: _ActionBtn(
              icon: Icons.chat_bubble_outline_rounded,
              label: context.l10n.get('send_sms'),
              onTap: () => _launch('sms:$phone'),
              color: context.colors.accentCyan,
              filled: false,
            ),
          ),
        );
        break;

      case ParsedContentType.email:
        final email = _parsed.data['email'] ?? '';
        buttons.add(
          Expanded(
            child: _ActionBtn(
              icon: Icons.alternate_email_rounded,
              label: context.l10n.get('send_email'),
              onTap: () => _launch('mailto:$email'),
              color: context.colors.accentBlue,
              filled: true,
            ),
          ),
        );
        buttons.add(const SizedBox(width: 10));
        buttons.add(Expanded(child: copyBtn));
        break;

      case ParsedContentType.url:
        final url = _parsed.data['url'] ?? '';
        buttons.add(
          Expanded(
            child: _ActionBtn(
              icon: Icons.open_in_browser_rounded,
              label: context.l10n.get('open_link'),
              onTap: () => _launch(url),
              color: context.colors.accentPurple,
              filled: true,
            ),
          ),
        );
        buttons.add(const SizedBox(width: 10));
        buttons.add(Expanded(child: copyBtn));
        break;

      default:
        buttons.add(Expanded(child: copyBtn));
        buttons.add(const SizedBox(width: 10));
        buttons.add(Expanded(child: shareBtn));
    }

    return Row(children: buttons);
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
          color: filled ? color : context.colors.bgSurface,
          borderRadius: BorderRadius.circular(12),
          border: filled ? null : Border.all(color: context.colors.glassBorder),
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
            Icon(icon, size: 18, color: filled ? Colors.white : color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: filled ? Colors.white : color,
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
