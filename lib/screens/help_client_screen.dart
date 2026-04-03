import 'package:flutter/material.dart';
import 'package:qr_code_app/theme/app_theme.dart';

class HelpClientScreen extends StatelessWidget {
  const HelpClientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        title: const Text('Hướng dẫn'),
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
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentPurple.withAlpha(80),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(Icons.qr_code_scanner,
                        color: Colors.white, size: 48),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'QR Scanner Pro',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Quét và tạo mã QR / Barcode dễ dàng',
                            style: TextStyle(
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
              _SectionTitle(title: 'Các tính năng chính'),
              const SizedBox(height: 12),

              _HelpCard(
                icon: Icons.flash_on_rounded,
                iconColor: AppColors.warning,
                title: 'Đèn Flash',
                description: 'Bật/tắt đèn flash của camera để quét trong bóng tối.',
              ),
              _HelpCard(
                icon: Icons.photo_library_rounded,
                iconColor: AppColors.accentBlue,
                title: 'Thư viện ảnh',
                description: 'Chọn ảnh từ gallery để quét mã QR hoặc Barcode.',
              ),
              _HelpCard(
                icon: Icons.cameraswitch_rounded,
                iconColor: AppColors.accentCyan,
                title: 'Chuyển camera',
                description: 'Chuyển đổi giữa camera trước và sau.',
              ),
              _HelpCard(
                icon: Icons.pinch_rounded,
                iconColor: AppColors.accentPurple,
                title: 'Pinch to Zoom',
                description: 'Dùng 2 ngón tay để phóng to hoặc thu nhỏ camera.',
              ),

              const SizedBox(height: 20),
              _SectionTitle(title: 'Cài đặt'),
              const SizedBox(height: 12),

              _HelpCard(
                icon: Icons.history_rounded,
                iconColor: AppColors.accentBlue,
                title: 'Lịch sử quét',
                description:
                    'Xem lại tất cả mã QR và Barcode đã quét. Nhấn để sao chép, vuốt sang trái để xóa.',
              ),
              _HelpCard(
                icon: Icons.open_in_browser_rounded,
                iconColor: AppColors.accentCyan,
                title: 'Tự động mở liên kết',
                description:
                    'Khi bật, app sẽ tự động mở trình duyệt nếu quét được URL (http/https).',
              ),
              _HelpCard(
                icon: Icons.crop_free_rounded,
                iconColor: AppColors.accentPurple,
                title: 'Bật khung quét',
                description:
                    'Khi bật, hiển thị khung hình vuông để căn mã QR vào vùng quét chính xác hơn.',
              ),

              const SizedBox(height: 20),
              _SectionTitle(title: 'Tạo mã'),
              const SizedBox(height: 12),

              _HelpCard(
                icon: Icons.add_box_outlined,
                iconColor: AppColors.accentPurple,
                title: 'Tạo QR / Barcode',
                description:
                    'Nhập URL, văn bản hoặc số rồi chọn loại mã. Hỗ trợ QR Code, Aztec, PDF417, EAN, Code128 và nhiều định dạng khác. Lưu ảnh về máy.',
              ),

              const SizedBox(height: 32),

              // Footer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bgCardSolid,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: const Column(
                  children: [
                    Text(
                      'Phát triển bởi',
                      style: AppTextStyles.labelSmall,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Thiện Nguyễn',
                      style: TextStyle(
                        color: AppColors.accentPurple,
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
            gradient: AppColors.accentGradient,
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
        color: AppColors.bgCardSolid,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder),
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
