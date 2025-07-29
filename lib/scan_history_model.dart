import 'package:hive/hive.dart';
part 'scan_history_model.g.dart';

@HiveType(typeId: 0)
class ScanHistoryModel {
  @HiveField(0)
  final String content;
  @HiveField(1)
  final DateTime scannedAt;

  ScanHistoryModel({required this.content, required this.scannedAt});
}
