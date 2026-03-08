import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:mangaapp1/auth_service.dart';
import 'package:mangaapp1/edit_profile_page.dart';
import 'package:mangaapp1/privacy_policy_page.dart';
import 'package:mangaapp1/terms_of_service_page.dart';
import 'package:mangaapp1/theme_selection_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  final bool isDark;
  final VoidCallback toggleTheme;

  const SettingsPage({
    super.key,
    required this.isDark,
    required this.toggleTheme,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _loadOnlyOnWifi = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _loadOnlyOnWifi = prefs.getBool('loadOnlyOnWifi') ?? false;
    });
  }

  Future<void> _toggleLoadOnlyOnWifi(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _loadOnlyOnWifi = value;
    });
    await prefs.setBool('loadOnlyOnWifi', value);
  }

  void _clearCache(BuildContext context) {
    DefaultCacheManager().emptyCache();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã xóa bộ nhớ đệm hình ảnh!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  void _navigateTo(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
      ),
      body: ListView(
        children: [
          _buildSectionTitle(context, 'Giao diện'),
          SwitchListTile(
            title: const Text('Chế độ tối'),
            value: widget.isDark,
            onChanged: (value) => widget.toggleTheme(),
            secondary: Icon(
              widget.isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.color_lens_outlined),
            title: const Text('Màu chủ đề'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _navigateTo(const ThemeSelectionPage()),
          ),
          _buildSectionTitle(context, 'Dữ liệu & Lưu trữ'),
          ListTile(
            leading: const Icon(Icons.delete_sweep_outlined),
            title: const Text('Xóa bộ nhớ đệm hình ảnh'),
            onTap: () => _clearCache(context),
          ),
          SwitchListTile(
            title: const Text('Chỉ tải truyện qua Wi-Fi'),
            value: _loadOnlyOnWifi,
            onChanged: _toggleLoadOnlyOnWifi,
            secondary: const Icon(Icons.wifi_outlined),
          ),
          _buildSectionTitle(context, 'Tài khoản'),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Chỉnh sửa hồ sơ'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _navigateTo(const EditProfilePage()),
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red.shade400),
            title: Text('Đăng xuất', style: TextStyle(color: Colors.red.shade400)),
            onTap: () {
              AuthService().signOut();
              // Pop all the way back to the auth gate
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
          _buildSectionTitle(context, 'Về ứng dụng'),
          ListTile(
            leading: const Icon(Icons.shield_outlined),
            title: const Text('Chính sách bảo mật'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _navigateTo(const PrivacyPolicyPage()),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Điều khoản dịch vụ'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _navigateTo(const TermsOfServicePage()),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Phiên bản ứng dụng'),
            trailing: const Text('1.0.0', style: TextStyle(color: Colors.grey)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
