import 'package:flutter/material.dart';
import 'package:mangaapp1/manage_comics_page.dart';
import 'package:mangaapp1/manage_users_page.dart';

class AdminPanelPage extends StatelessWidget {
  const AdminPanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hệ thống Quản trị',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: GridView.count(
          padding: const EdgeInsets.all(20),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildAdminCard(
              context,
              title: 'Người dùng',
              icon: Icons.people_alt_rounded,
              color: Colors.blue,
              subtitle: 'Quản lý thành viên',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ManageUsersPage()),
                );
              },
            ),
            _buildAdminCard(
              context,
              title: 'Truyện tranh',
              icon: Icons.menu_book_rounded,
              color: Colors.orange,
              subtitle: 'Thêm, sửa, xóa truyện',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ManageComicsPage()),
                );
              },
            ),
            _buildAdminCard(
              context,
              title: 'Thống kê',
              icon: Icons.analytics_rounded,
              color: Colors.green,
              subtitle: 'Lượt xem & Doanh thu',
              onTap: () {},
            ),
            _buildAdminCard(
              context,
              title: 'Bình luận',
              icon: Icons.comment_rounded,
              color: Colors.teal,
              subtitle: 'Kiểm duyệt nội dung',
              onTap: () {},
            ),
            _buildAdminCard(
              context,
              title: 'Thông báo',
              icon: Icons.notifications_active_rounded,
              color: Colors.redAccent,
              subtitle: 'Gửi tin nhắn hệ thống',
              onTap: () {},
            ),
            _buildAdminCard(
              context,
              title: 'Cài đặt hệ thống',
              icon: Icons.settings_applications_rounded,
              color: Colors.grey.shade700,
              subtitle: 'Cấu hình App',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shadowColor: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
