import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Main & Settings
      'gallery': 'Gallery',
      'scan_code': 'Scan',
      'history': 'History',
      'create_code': 'Create',
      'help': 'Help',
      'settings': 'Settings',
      'theme': 'Theme',
      'auto_open_url': 'Auto open link',
      'vibrate_on_scan': 'Vibrate on scan',
      'starting': 'Starting...',
      'camera_permission_required': 'Camera permission required',
      'grant_permission': 'Grant Permission',
      'language': 'Language',
      'cannot_access_camera': 'Cannot access camera',
      'camera_restricted': 'Camera access is restricted by parental controls or device policy.',
      'invalid_image_format': 'Invalid image format',
      'please_try_again': 'Please try again',
      'close': 'Close',
      'customization': 'Customization',
      'auto_open_url_sub': 'Open browser when scanning URL',
      'scan_history_sub': 'Review scanned codes',
      'dark_mode': 'Dark mode',
      'light_mode': 'Light mode',
      'enable_scan_frame_sub': 'Show QR scanner frame',
      'help_sub': 'App user guide',
      'camera_permission_desc': 'Need Camera permission to scan code',
      'on': 'ON',
      'off': 'OFF',
      
      // History
      'scan_history': 'Scan History',
      'delete_all': 'Delete All',
      'no_history': 'No scan history yet',
      'deleted_successfully': 'Deleted successfully',
      'copied': 'Copied!',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'confirm_delete_all': 'Are you sure you want to delete all history?',
      'confirm_delete_all_title': 'Delete all history?',
      'confirm_delete_all_desc': 'This action cannot be undone.',
      'delete_all_confirm': 'Delete All',
      'no_history_desc': 'Scan a QR Code or Barcode to start',
      'open': 'Open',
      'tap_to_copy': 'Tap to copy',

      // Create
      'create_qr_barcode': 'Create QR / Barcode',
      'enter_content': 'Enter content...',
      'select_type': 'Select type:',
      'generate': 'Generate',
      'save_image': 'Save image',
      'share': 'Share',
      'saved_to_gallery': 'Saved to gallery',
      'save_failed': 'Failed to save',
      'desktop_not_found': 'Desktop directory not found.',
      'widget_not_found': 'Widget not found.',
      'cannot_convert_png': 'Cannot convert to PNG.',
      'platform_not_supported': 'Platform not supported for saving images.',
      'saved_to': 'Saved to: ',
      'error_prefix': 'Error: ',
      'content_label': 'Content',
      'enter_content_hint': 'Enter URL, text, phone number...',
      'code_type_label': 'Code type',
      'preview_label': 'Preview',
      'enter_content_to_create': 'Enter content to create code',
      'color_customization': 'QR / Barcode Color',
      'foreground_color': 'Code Color (Foreground)',
      'background_color': 'Background Color (Background)',

      // Help
      'main_features': 'Main Features',
      'flashlight': 'Flashlight',
      'flashlight_desc': 'Turn on/off camera flashlight to scan in the dark.',
      'photo_library': 'Photo library',
      'photo_library_desc': 'Choose an image from the gallery to scan a QR code or Barcode.',
      'switch_camera': 'Switch camera',
      'switch_camera_desc': 'Switch between front and back camera.',
      'pinch_zoom': 'Pinch to Zoom',
      'pinch_zoom_desc': 'Use 2 fingers to zoom the camera in or out.',
      'scan_history_desc': 'Review all scanned QR and Barcodes. Tap to copy, swipe left to delete.',
      'auto_open_url_desc': 'When enabled, the app automatically opens the browser if a URL is scanned.',
      'theme_desc': 'Flexibly switch between Light and Dark mode depending on preference and environment.',
      'language_desc': 'Switch the application language between English and Vietnamese.',
      'enable_scan_frame': 'Enable scan frame',
      'enable_scan_frame_desc': 'When enabled, shows a square frame to align the QR code for more accurate scanning.',
      'create_qr_barcode_desc': 'Enter URL, text, or numbers then select the code type. Supports QR Code, Aztec, PDF417, EAN, Code128, and more. Save images to device.',
      'developed_by': 'Developed by',
      'app_desc': 'Easily scan and generate QR / Barcode',

      // Scan overlay / result
      'move_qr_to_center': 'Move QR code into the center of the frame',
      'scan_successful': 'Scan successful',
      'url_link': 'URL Link',
      'text': 'Text',
      'copy': 'Copy',
      'copied_to_clipboard': 'Copied to clipboard!',
      'open_link': 'Open link',
      'initializing_scanner': 'Initializing scanner...',
      'point_camera_at_qr_barcode': 'Point camera at QR / Barcode',
      'connect_wifi': 'Connect to Wi-Fi',
      'wifi_password': 'Password: ',
      'wifi_connected': 'Connected successfully!',
      'wifi_connect_failed': 'Connection failed',
      'show_password': 'Show',
      'hide_password': 'Hide',
      'call': 'Call',
      'send_sms': 'Send SMS',
      'send_email': 'Send Email',
      'open_maps': 'Open Maps',
      'share_code': 'Share',
    },
    'vi': {
      // Main & Settings
      'gallery': 'Thư viện',
      'scan_code': 'Quét mã',
      'history': 'Lịch sử',
      'create_code': 'Tạo mã',
      'help': 'Hướng dẫn',
      'settings': 'Cài đặt',
      'theme': 'Giao diện',
      'auto_open_url': 'Tự động mở liên kết',
      'vibrate_on_scan': 'Rung khi quét',
      'starting': 'Đang khởi động...',
      'camera_permission_required': 'Cần quyền camera',
      'grant_permission': 'Cấp quyền',
      'language': 'Ngôn ngữ',
      'cannot_access_camera': 'Không thể truy cập camera',
      'camera_restricted': 'Quyền camera đã bị hệ thống hạn chế kiểm soát cha mẹ hoặc thiết bị không cho phép.',
      'invalid_image_format': 'Ảnh không đúng định dạng',
      'please_try_again': 'Vui lòng thử lại',
      'close': 'Đóng',
      'customization': 'Tuỳ chỉnh',
      'auto_open_url_sub': 'Mở trình duyệt khi quét URL',
      'scan_history_sub': 'Xem lại các mã đã quét',
      'dark_mode': 'Chế độ tối',
      'light_mode': 'Chế độ sáng',
      'enable_scan_frame_sub': 'Hiển thị khung QR scanner',
      'help_sub': 'Hướng dẫn sử dụng ứng dụng',
      'camera_permission_desc': 'Cần quyền Camera để quét mã',
      'on': 'Đèn bật',
      'off': 'Đèn tắt',

      // History
      'scan_history': 'Lịch sử quét',
      'delete_all': 'Xóa tất cả',
      'no_history': 'Chưa có lịch sử quét',
      'deleted_successfully': 'Xóa thành công',
      'copied': 'Đã sao chép!',
      'cancel': 'Hủy',
      'delete': 'Xóa',
      'confirm_delete_all': 'Bạn có chắc muốn xóa tất cả lịch sử không?',
      'confirm_delete_all_title': 'Xóa tất cả lịch sử?',
      'confirm_delete_all_desc': 'Hành động này không thể hoàn tác.',
      'delete_all_confirm': 'Xóa hết',
      'no_history_desc': 'Quét mã QR hoặc Barcode để bắt đầu',
      'open': 'Mở',
      'tap_to_copy': 'Nhấn để sao chép',

      // Create
      'create_qr_barcode': 'Tạo mã QR / Barcode',
      'enter_content': 'Nhập nội dung...',
      'select_type': 'Chọn loại mã:',
      'generate': 'Tạo mã',
      'save_image': 'Lưu ảnh',
      'share': 'Chia sẻ',
      'saved_to_gallery': 'Đã lưu vào thư viện',
      'save_failed': 'Lưu thất bại',
      'desktop_not_found': 'Không tìm thấy thư mục Desktop.',
      'widget_not_found': 'Không tìm thấy widget.',
      'cannot_convert_png': 'Không thể chuyển thành PNG.',
      'platform_not_supported': 'Nền tảng chưa hỗ trợ lưu ảnh.',
      'saved_to': 'Đã lưu: ',
      'error_prefix': 'Lỗi: ',
      'content_label': 'Nội dung',
      'enter_content_hint': 'Nhập URL, văn bản, số điện thoại...',
      'code_type_label': 'Loại mã',
      'preview_label': 'Xem trước',
      'enter_content_to_create': 'Nhập nội dung để tạo mã',
      'color_customization': 'Màu sắc mã QR/Barcode',
      'foreground_color': 'Màu mã (Foreground)',
      'background_color': 'Màu nền (Background)',

      // Help
      'main_features': 'Các tính năng chính',
      'flashlight': 'Đèn Flash',
      'flashlight_desc': 'Bật/tắt đèn flash của camera để quét trong bóng tối.',
      'photo_library': 'Thư viện ảnh',
      'photo_library_desc': 'Chọn ảnh từ gallery để quét mã QR hoặc Barcode.',
      'switch_camera': 'Chuyển camera',
      'switch_camera_desc': 'Chuyển đổi giữa camera trước và sau.',
      'pinch_zoom': 'Pinch to Zoom',
      'pinch_zoom_desc': 'Dùng 2 ngón tay để phóng to hoặc thu nhỏ camera.',
      'scan_history_desc': 'Xem lại tất cả mã QR và Barcode đã quét. Nhấn để sao chép, vuốt sang trái để xóa.',
      'auto_open_url_desc': 'Khi bật, app sẽ tự động mở trình duyệt nếu quét được URL (http/https).',
      'theme_desc': 'Chuyển đổi linh hoạt giữa chế độ Sáng và Tối tùy theo sở thích và môi trường.',
      'language_desc': 'Chuyển đổi ngôn ngữ của ứng dụng giữa Tiếng Việt và Tiếng Anh.',
      'enable_scan_frame': 'Bật khung quét',
      'enable_scan_frame_desc': 'Khi bật, hiển thị khung hình vuông để căn mã QR vào vùng quét chính xác hơn.',
      'create_qr_barcode_desc': 'Nhập URL, văn bản hoặc số rồi chọn loại mã. Hỗ trợ QR Code, Aztec, PDF417, EAN, Code128 và nhiều định dạng khác. Lưu ảnh về máy.',
      'developed_by': 'Phát triển bởi',
      'app_desc': 'Quét và tạo mã QR / Barcode dễ dàng',

      // Scan overlay / result
      'move_qr_to_center': 'Di chuyển mã QR vào giữa khung hình',
      'scan_successful': 'Đã quét thành công',
      'url_link': 'Đường dẫn URL',
      'text': 'Văn bản',
      'copy': 'Sao chép',
      'copied_to_clipboard': 'Đã sao chép vào clipboard!',
      'open_link': 'Mở liên kết',
      'initializing_scanner': 'Đang khởi tạo máy quét...',
      'point_camera_at_qr_barcode': 'Hướng camera vào mã QR / Barcode',
      'connect_wifi': 'Kết nối Wi-Fi',
      'wifi_password': 'Mật khẩu: ',
      'wifi_connected': 'Đã kết nối thành công!',
      'wifi_connect_failed': 'Kết nối Wi-Fi thất bại',
      'show_password': 'Hiện',
      'hide_password': 'Ẩn',
      'call': 'Gọi điện',
      'send_sms': 'Gửi tin nhắn',
      'send_email': 'Gửi Email',
      'open_maps': 'Mở bản đồ',
      'share_code': 'Chia sẻ',
    },
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'vi'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
