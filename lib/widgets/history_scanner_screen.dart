import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:qr_code_app/config/format_time.dart';
import 'package:qr_code_app/models/scan_history_model.dart';

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
      body: ValueListenableBuilder(
          valueListenable: box.listenable(),
          builder: (context, value, child) {
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  title: Text('Lịch sử quét'),
                  pinned: false,
                  floating: true,
                  centerTitle: true,
                  expandedHeight: 50,
                  actions: [
                    InkWell(
                      onTap: () {
                        box.clear();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.cleaning_services),
                            Text(
                              "Dọn dẹp",
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
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
                            "Đã quét: ${FormatTime().coverTimeFromIso(items.scannedAt.toIso8601String())}"),
                        trailing: InkWell(
                          child: const Icon(
                            Icons.delete,
                            size: 35,
                          ),
                          onTap: () {
                            box.deleteAt(box.length - 1 - index);
                          },
                        ),
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: items.content));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Sao chép thành công")),
                          );
                        },
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
            );
          }),
    );
  }
}
