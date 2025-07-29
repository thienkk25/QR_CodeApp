import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:qr_code_app/format_time.dart';
import 'package:qr_code_app/scan_history_model.dart';

class HistoryScannerScreen extends StatefulWidget {
  const HistoryScannerScreen({super.key});

  @override
  State<HistoryScannerScreen> createState() => _HistoryScannerScreenState();
}

class _HistoryScannerScreenState extends State<HistoryScannerScreen> {
  final box = Hive.box<ScanHistoryModel>('scan_history');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text('Lịch sử quét'),
            pinned: false,
            floating: true,
            centerTitle: true,
            expandedHeight: 50,
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final items = box.getAt(box.length - 1 - index);
              return Container(
                decoration: const BoxDecoration(
                  border: BorderDirectional(top: BorderSide(width: 1)),
                ),
                padding: const EdgeInsets.all(5),
                margin: const EdgeInsets.only(bottom: 5),
                child: ListTile(
                  title: Text(items!.content),
                  subtitle: Text(
                      "Thời gian quét: ${FormatTime().coverTimeFromIso(items.scannedAt.toIso8601String())}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        child: const Icon(Icons.copy),
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: items.content));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Sao chép thành công")),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        child: const Icon(Icons.delete),
                        onTap: () {
                          setState(() {
                            box.deleteAt(index);
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            }, childCount: box.length),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Text(
                  'Hết!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
