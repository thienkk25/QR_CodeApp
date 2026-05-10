import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:qr_code_app/models/scan_history_model.dart'
    show ScanHistoryModel, ScanHistoryModelAdapter;
import 'package:qr_code_app/screens/scan_qr_screen.dart';
import 'package:qr_code_app/theme/app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:qr_code_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(ScanHistoryModelAdapter());

  await Hive.openBox<ScanHistoryModel>('scan_history');

  final prefs = await SharedPreferences.getInstance();
  final savedLang = prefs.getString('language_code') ?? 'vi';
  localeNotifier.value = Locale(savedLang);

  runApp(const MainApp());
}

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);
final ValueNotifier<Locale> localeNotifier = ValueNotifier(const Locale('vi'));

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: localeNotifier,
      builder: (context, currentLocale, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: themeNotifier,
          builder: (context, currentMode, child) {
            return MaterialApp(
              title: 'QR Scanner',
              locale: currentLocale,
              supportedLocales: const [Locale('vi'), Locale('en')],
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              darkTheme: AppTheme.dark,
              theme: AppTheme.light,
              themeMode: currentMode,
              debugShowCheckedModeBanner: false,
              home: const ScanQrScreen(),
            );
          },
        );
      },
    );
  }
}
