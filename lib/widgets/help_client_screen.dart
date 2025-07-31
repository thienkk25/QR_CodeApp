import 'package:flutter/material.dart';

class HelpClientScreen extends StatelessWidget {
  const HelpClientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hướng dẫn"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            ListTile(
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.flash_on,
                    color: Colors.orange,
                  ),
                  Text("/"),
                  Icon(Icons.flash_off),
                ],
              ),
              title: Text("Bật/Tắt đèn camera"),
            ),
            ListTile(
              leading: Icon(Icons.photo),
              title: Text("Truy cập vào thư viện ảnh"),
            ),
            ListTile(
              leading: Icon(Icons.cameraswitch),
              title: Text("Chuyển đổi camera trước hoặc sau"),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Cài đặt"),
                  ListTile(
                    leading: Icon(Icons.history),
                    title: Text("Lịch sử đã từng quét QR hoặc Barcode"),
                  ),
                  ListTile(
                    leading: Icon(Icons.link),
                    title: Text("Tự động mở trình duyệt nếu là link"),
                    subtitle: Text("Ví dụ: http:// , https://"),
                  ),
                  ListTile(
                    leading: Icon(Icons.qr_code),
                    title: Text("Bật/Tắt khung quét"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SizedBox(
          height: 30,
          child: Center(
              child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(
              "Thiện Ngyễn",
              style: TextStyle(fontSize: 10),
            ),
          ))),
    );
  }
}
