import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:qr_code_app/scan_history_model.dart'
    show ScanHistoryModel, ScanHistoryModelAdapter;
import 'package:qr_code_app/scan_qr_screen.dart';

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
    return MaterialApp(debugShowCheckedModeBanner: false, home: ScanQrScreen());
  }
}
