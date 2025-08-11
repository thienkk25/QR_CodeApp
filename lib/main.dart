import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:qr_code_app/models/scan_history_model.dart'
    show ScanHistoryModel, ScanHistoryModelAdapter;
import 'package:qr_code_app/widgets/scan_qr_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(ScanHistoryModelAdapter());

  await Hive.openBox<ScanHistoryModel>('scan_history');

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Color(0xFF121212),
          secondaryHeaderColor: Colors.white54,
          primarySwatch: Colors.deepPurple,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1F1F1F),
            foregroundColor: Colors.white,
            elevation: 1,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: Colors.white),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.deepPurple,
          ),
        ),
        theme: ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: Colors.white,
          secondaryHeaderColor: Color(0xFF121212),
        ),
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: ScanQrScreen());
  }
}
