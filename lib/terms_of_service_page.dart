import 'package:flutter/material.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Điều khoản dịch vụ'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Nội dung điều khoản dịch vụ sẽ được cập nhật tại đây. Cảm ơn bạn đã sử dụng ứng dụng của chúng tôi.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
