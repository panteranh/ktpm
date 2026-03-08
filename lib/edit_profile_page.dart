import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // TODO: In the future, load the current user's name from Firebase
    _nameController.text = "Người dùng CoRead"; // Placeholder
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    // TODO: In the future, save the new name to Firebase
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã cập nhật hồ sơ!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa hồ sơ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            onPressed: _saveProfile,
            tooltip: 'Lưu thay đổi',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.deepPurple,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {},
              child: const Text('Thay đổi ảnh đại diện'),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Tên hiển thị',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
            // You can add more fields here later, like a bio.
          ],
        ),
      ),
    );
  }
}
