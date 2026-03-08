import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mangaapp1/add_comic_page.dart';
import 'package:mangaapp1/models/comic_model.dart';
import 'package:mangaapp1/smart_image.dart';

class ManageComicsPage extends StatelessWidget {
  const ManageComicsPage({super.key});

  Future<void> _deleteComic(BuildContext context, Comic comic) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa truyện "${comic.title}" không? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance.collection('comics').doc(comic.id).delete();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã xóa truyện thành công')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi khi xóa: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Truyện tranh'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddComicPage()),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('comics').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Chưa có truyện nào trong cơ sở dữ liệu.'));
          }

          final comics = snapshot.data!.docs.map((doc) => Comic.fromSnapshot(doc)).toList();

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: comics.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final comic = comics[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: SizedBox(
                  width: 50,
                  height: 70,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SmartImage(imageUrl: comic.cover, fit: BoxFit.cover),
                  ),
                ),
                title: Text(comic.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Tác giả: ${comic.author}\nThể loại: ${comic.genre}', style: const TextStyle(fontSize: 12)),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                      onPressed: () {
                        // Pass comic to AddComicPage for editing (we'll update AddComicPage next)
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AddComicPage(comic: comic)),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _deleteComic(context, comic),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
