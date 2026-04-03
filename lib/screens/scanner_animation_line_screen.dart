import 'package:flutter/material.dart';
import 'package:qr_code_app/theme/app_theme.dart';

class ScannerAnimationLineScreen extends StatefulWidget {
  const ScannerAnimationLineScreen({super.key});

  @override
  State<ScannerAnimationLineScreen> createState() =>
      _ScannerAnimationLineScreenState();
}

class _ScannerAnimationLineScreenState extends State<ScannerAnimationLineScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    animation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Align(
          alignment: Alignment(0, animation.value * 2 - 1),
          child: child,
        );
      },
      child: Container(
        width: double.infinity,
        height: 3,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Colors.transparent,
              AppColors.accentBlue,
              AppColors.accentPurple,
              AppColors.accentBlue,
              Colors.transparent,
            ],
          ),
          borderRadius: BorderRadius.circular(2),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentPurple.withAlpha(200),
              blurRadius: 18,
              spreadRadius: 4,
            ),
            BoxShadow(
              color: AppColors.accentCyan.withAlpha(120),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}
