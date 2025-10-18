import 'package:flutter/material.dart';

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
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    animation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.linear,
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
        height: 4,
        decoration: BoxDecoration(
          color: Colors.white70,
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: .6),
              blurRadius: 20,
              spreadRadius: 5,
              offset: Offset(0, 0),
            ),
          ],
        ),
      ),
    );
  }
}
