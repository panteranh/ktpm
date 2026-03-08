import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mangaapp1/add_comic_page.dart';
import 'package:mangaapp1/auth_service.dart';
import 'package:mangaapp1/models/comic_model.dart';
import 'package:mangaapp1/detail_page.dart';
import 'package:mangaapp1/smart_image.dart';

class LibraryContent extends StatefulWidget {
  const LibraryContent({Key? key}) : super(key: key);

  @override
  State<LibraryContent> createState() => _LibraryContentState();
}

class _LibraryContentState extends State<LibraryContent> {
  final _authService = AuthService();

  void _navigateToAddComic() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddComicPage()),
    );
    if (result == true) {
      // StreamBuilder handles refresh
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = _authService.isAdmin();

    return Scaffold(
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('comics').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Đã có lỗi xảy ra: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState(isAdmin);
          }

          final comics = snapshot.data!.docs.map((doc) => Comic.fromSnapshot(doc)).toList();

          return _buildComicsGrid(comics);
        },
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: _navigateToAddComic,
              child: const Icon(Icons.add),
              tooltip: 'Thêm truyện mới',
            )
          : null,
    );
  }

  Widget _buildEmptyState(bool isAdmin) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_stories_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'Thư viện trống',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (isAdmin)
              Text(
                'Nhấn nút "+" để bắt đầu thêm truyện vào thư viện.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildComicsGrid(List<Comic> comics) {
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.6,
      ),
      itemCount: comics.length,
      itemBuilder: (context, index) {
        final comic = comics[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailPage(comic: comic),
              ),
            );
          },
          child: Card(
            elevation: 2,
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Hero(
                    tag: comic.id ?? comic.title,
                    child: SmartImage(imageUrl: comic.cover, fit: BoxFit.cover),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    comic.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
