import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chính sách bảo mật'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Nội dung chính sách bảo mật sẽ được cập nhật ở đây. Chúng tôi cam kết bảo vệ thông tin cá nhân của bạn.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
