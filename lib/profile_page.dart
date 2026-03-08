import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mangaapp1/admin_panel_page.dart';
import 'package:mangaapp1/auth_service.dart';
import 'package:mangaapp1/settings_page.dart';

class ProfilePage extends StatelessWidget {
  final bool isDark;
  final VoidCallback toggleTheme;

  const ProfilePage({Key? key, required this.isDark, required this.toggleTheme})
      : super(key: key);

  Widget _buildStatItem(BuildContext context, IconData icon, String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.deepPurple, size: 30),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final _authService = AuthService();
    final bool isAdmin = _authService.isAdmin();
    
    final photoUrl = user?.photoURL;
    final bool hasPhoto = photoUrl?.isNotEmpty ?? false;

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          // User Info Section
          Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.deepPurple.shade100,
                backgroundImage: hasPhoto ? NetworkImage(photoUrl!) : null,
                child: !hasPhoto
                    ? const Icon(Icons.person, size: 50, color: Colors.deepPurple)
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                user?.displayName ?? 'Người dùng CoRead',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    user?.email ?? 'email@example.com',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  if (isAdmin)
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Icon(Icons.shield, color: Colors.blue, size: 18),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Stats Section
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem(context, Icons.history_edu_outlined, 'Đã đọc', '125'),
                  _buildStatItem(context, Icons.favorite_border, 'Yêu thích', '48'),
                  _buildStatItem(context, Icons.download_done_outlined, 'Đã tải', '12'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Menu Section
          const Divider(indent: 16, endIndent: 16),
          // Conditional Admin Panel - Updated to use central logic
          if (isAdmin)
            ListTile(
              leading: const Icon(Icons.admin_panel_settings_outlined),
              title: const Text('Bảng điều khiển Admin'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                 Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminPanelPage()),
                );
              },
            ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Cài đặt'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(
                    isDark: isDark,
                    toggleTheme: toggleTheme,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Trợ giúp & Phản hồi'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          const Divider(indent: 16, endIndent: 16),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red.shade400),
            title: Text('Đăng xuất', style: TextStyle(color: Colors.red.shade400)),
            onTap: () {
              _authService.signOut();
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
