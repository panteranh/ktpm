import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mangaapp1/auth_gate.dart';
import 'package:mangaapp1/bookmark_page.dart'; // Will be FavoriteContent
import 'package:mangaapp1/home_page.dart'; // Will be HomeContent
import 'package:mangaapp1/library_content.dart';
import 'package:mangaapp1/profile_page.dart';
import 'package:mangaapp1/firebase_options.dart';
import 'package:mangaapp1/widgets/app_drawer.dart'; // Import the new drawer
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ComicApp());
}

class ComicApp extends StatefulWidget {
  const ComicApp({super.key});

  @override
  State<ComicApp> createState() => _ComicAppState();
}

class _ComicAppState extends State<ComicApp> {
  bool isDark = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        isDark = prefs.getBool('isDark') ?? false;
      });
    }
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDark = !isDark;
    });
    await prefs.setBool('isDark', isDark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CoRead',
      debugShowCheckedModeBanner: false,
      theme: isDark
          ? ThemeData.dark().copyWith(
              primaryColor: Colors.deepPurple,
              colorScheme: const ColorScheme.dark().copyWith(primary: Colors.deepPurple),
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                selectedItemColor: Colors.deepPurple,
                type: BottomNavigationBarType.fixed,
              ),
            )
          : ThemeData.light().copyWith(
              primaryColor: Colors.deepPurple,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.deepPurple,
                elevation: 0,
              ),
              colorScheme: const ColorScheme.light().copyWith(primary: Colors.deepPurple),
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                selectedItemColor: Colors.deepPurple,
                type: BottomNavigationBarType.fixed,
              ),
            ),
      home: AuthGate(isDark: isDark, toggleTheme: toggleTheme),
    );
  }
}

class MainScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback toggleTheme;

  const MainScreen({super.key, required this.isDark, required this.toggleTheme});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _buildPages();
  }

  @override
  void didUpdateWidget(covariant MainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDark != oldWidget.isDark) {
      setState(() {
        _buildPages();
      });
    }
  }

  void _buildPages() {
    _pages = [
      HomePage(), // This now contains HomeContent
      const FavoriteContent(), // bookmark_page is now FavoriteContent
      const LibraryContent(),
      ProfilePage(isDark: widget.isDark, toggleTheme: widget.toggleTheme),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_pages.isEmpty) {
      _buildPages();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('CoRead'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      drawer: const AppDrawer(), // Use the new AppDrawer
      body: IndexedStack( // Use IndexedStack to preserve state of each tab
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'Yêu thích',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books_outlined),
            activeIcon: Icon(Icons.library_books),
            label: 'Thư viện',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }
}
