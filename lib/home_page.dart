import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mangaapp1/models/comic_model.dart';
import 'package:mangaapp1/detail_page.dart';
import 'package:mangaapp1/smart_image.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HomeContent(onRefresh: () async {});
  }
}

class HomeContent extends StatelessWidget {
  final VoidCallback? onRefresh;

  const HomeContent({Key? key, this.onRefresh}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;

    return RefreshIndicator(
      onRefresh: () async {
        onRefresh?.call();
        await Future.delayed(const Duration(seconds: 1));
      },
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: firestore.collection('comics').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          final allComics = snapshot.data!.docs.map((doc) => Comic.fromSnapshot(doc)).toList();
          
          // Giả sử truyện Hot là những truyện có views cao hoặc chỉ lấy 5 truyện đầu
          final hotComics = List<Comic>.from(allComics)..sort((a, b) => b.views.compareTo(a.views));
          final recentComics = allComics;

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner Section
                _buildBanner(),

                // Truyện Hot Section
                _buildSectionHeader('Truyện Hot 🔥'),
                SizedBox(
                  height: 260,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: hotComics.length > 5 ? 5 : hotComics.length,
                    itemBuilder: (context, index) {
                      return _buildHotComicCard(context, hotComics[index]);
                    },
                  ),
                ),

                // Truyện Mới Cập Nhật Section
                _buildSectionHeader('Mới cập nhật'),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: recentComics.length > 10 ? 10 : recentComics.length,
                  itemBuilder: (context, index) {
                    return _buildRecentComicListItem(context, recentComics[index]);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      height: 180,
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade400, Colors.purple.shade300],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.deepPurple.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.auto_stories, size: 50, color: Colors.white),
            SizedBox(height: 10),
            Text(
              'Chào mừng đến với CoRead',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              'Thế giới truyện tranh trong tầm tay',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          TextButton(onPressed: () {}, child: const Text('Xem thêm')),
        ],
      ),
    );
  }

  Widget _buildHotComicCard(BuildContext context, Comic comic) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => DetailPage(comic: comic)));
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Hero(
                tag: 'hot_${comic.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SmartImage(imageUrl: comic.cover, fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              comic.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              children: [
                const Icon(Icons.star, size: 14, color: Colors.amber),
                const SizedBox(width: 4),
                Text(comic.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const Spacer(),
                const Icon(Icons.remove_red_eye_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 2),
                Text('${comic.views}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentComicListItem(BuildContext context, Comic comic) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.grey.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => DetailPage(comic: comic)));
        },
        leading: SizedBox(
          width: 60,
          height: 80,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SmartImage(imageUrl: comic.cover, fit: BoxFit.cover),
          ),
        ),
        title: Text(comic.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(comic.author, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.deepPurple.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text(comic.status, style: const TextStyle(fontSize: 10, color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.label_outline, size: 12, color: Colors.grey),
                const SizedBox(width: 2),
                Expanded(child: Text(comic.genre, style: const TextStyle(fontSize: 11, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text('Chưa có truyện nào được đăng tải', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}
