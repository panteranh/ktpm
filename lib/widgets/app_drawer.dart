import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mangaapp1/auth_service.dart';
import 'package:mangaapp1/category_page.dart';
import 'package:mangaapp1/search_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final photoUrl = user?.photoURL;
    final bool hasPhoto = photoUrl?.isNotEmpty ?? false;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.deepPurple.shade300],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            accountName: Text(
              user?.displayName ?? 'Người dùng CoRead',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: Text(user?.email ?? 'email@example.com'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: hasPhoto ? NetworkImage(photoUrl!) : null,
              child: !hasPhoto
                  ? const Icon(Icons.person, size: 40, color: Colors.deepPurple)
                  : null,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.search, color: Colors.deepPurple),
            title: const Text('Tìm truyện'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.category_outlined, color: Colors.deepPurple),
            title: const Text('Thể loại'),
            onTap: () {
               Navigator.pop(context);
               Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.download_outlined, color: Colors.deepPurple),
            title: const Text('Đã tải'),
            onTap: () => Navigator.pop(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Đăng xuất'),
            onTap: () => AuthService().signOut(),
          ),
        ],
      ),
    );
  }
}
