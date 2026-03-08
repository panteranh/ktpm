import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mangaapp1/detail_page.dart';
import 'package:mangaapp1/models/comic_model.dart';
import 'package:mangaapp1/smart_image.dart';

class FavoriteContent extends StatefulWidget {
  const FavoriteContent({super.key});

  @override
  State<FavoriteContent> createState() => _FavoriteContentState();
}

class _FavoriteContentState extends State<FavoriteContent> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<void> _removeFromFavorites(String comicId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(comicId)
        .delete();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xóa khỏi yêu thích'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return const Center(child: Text('Vui lòng đăng nhập để xem truyện yêu thích.'));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Truyện yêu thích')),
      body: StreamBuilder<QuerySnapshot>(
        // Listen to the user's favorites collection
        stream: _firestore.collection('users').doc(user.uid).collection('favorites').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          // Get the list of favorite comic IDs
          final favoriteComicIds = snapshot.data!.docs.map((doc) => doc.id).toList();

          // Now, fetch the actual comic data using the IDs
          return StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('comics').where(FieldPath.documentId, whereIn: favoriteComicIds).snapshots(),
            builder: (context, comicSnapshot) {
              if (comicSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!comicSnapshot.hasData || comicSnapshot.data!.docs.isEmpty) {
                return _buildEmptyState(); // In case comics were deleted
              }

              final favoriteComics = comicSnapshot.data!.docs
                  .map((doc) => Comic.fromSnapshot(doc as DocumentSnapshot<Map<String, dynamic>>))
                  .toList();

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: favoriteComics.length,
                itemBuilder: (context, index) {
                  return _buildFavoriteCard(favoriteComics[index]);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFavoriteCard(Comic comic) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DetailPage(comic: comic)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 70,
                height: 100,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SmartImage(imageUrl: comic.cover, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comic.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      comic.author,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber[700]),
                        const SizedBox(width: 4),
                        Text(
                          comic.rating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: comic.status == 'Completed' ? Colors.green[50] : Colors.blue[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        comic.status,
                        style: TextStyle(
                          fontSize: 11,
                          color: comic.status == 'Completed' ? Colors.green[700] : Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red),
                tooltip: 'Xóa khỏi Yêu thích',
                onPressed: () => _removeFromFavorites(comic.id!),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Chưa có truyện yêu thích',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Hãy nhấn vào biểu tượng trái tim ở trang chi tiết truyện để thêm vào đây!',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
