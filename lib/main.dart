import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:qr_code_app/models/scan_history_model.dart'
    show ScanHistoryModel, ScanHistoryModelAdapter;
import 'package:qr_code_app/screens/scan_qr_screen.dart';
import 'package:qr_code_app/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(ScanHistoryModelAdapter());

  await Hive.openBox<ScanHistoryModel>('scan_history');

  runApp(const MainApp());
}

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: 'QR Scanner',
          darkTheme: AppTheme.dark,
          theme: AppTheme.light,
          themeMode: currentMode,
          debugShowCheckedModeBanner: false,
          home: const ScanQrScreen(),
        );
      },
    );
  }
}
