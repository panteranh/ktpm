import 'package:flutter/material.dart';
import 'package:mangaapp1/models/chapter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageChaptersPage extends StatefulWidget {
  final String comicId;

  const ManageChaptersPage({super.key, required this.comicId});

  @override
  State<ManageChaptersPage> createState() => _ManageChaptersPageState();
}

class _ManageChaptersPageState extends State<ManageChaptersPage> {
  final _titleController = TextEditingController();
  final _chapterNumberController = TextEditingController();
  final _pagesController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _chapterNumberController.dispose();
    _pagesController.dispose();
    super.dispose();
  }

  Future<void> _addOrUpdateChapter({Chapter? chapter}) async {
    // If updating, pre-fill the text fields
    if (chapter != null) {
      _titleController.text = chapter.title;
      _chapterNumberController.text = chapter.chapterNumber.toString();
      _pagesController.text = chapter.pages.join('\n');
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(chapter == null ? 'Thêm chương mới' : 'Cập nhật chương'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _chapterNumberController,
                decoration: const InputDecoration(labelText: 'Số chương'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Tiêu đề chương'),
              ),
              TextField(
                controller: _pagesController,
                decoration: const InputDecoration(labelText: 'Các trang (mỗi URL một dòng)'),
                maxLines: 5,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newChapter = Chapter(
                chapterNumber: int.parse(_chapterNumberController.text),
                title: _titleController.text,
                pages: _pagesController.text.split('\n').where((s) => s.isNotEmpty).toList(),
                createdAt: Timestamp.now(),
              );
              
              if (chapter == null) {
                // Add new chapter
                await FirebaseFirestore.instance
                    .collection('comics')
                    .doc(widget.comicId)
                    .collection('chapters')
                    .add(newChapter.toJson());
              } else {
                // Update existing chapter
                await FirebaseFirestore.instance
                    .collection('comics')
                    .doc(widget.comicId)
                    .collection('chapters')
                    .doc(chapter.id)
                    .update(newChapter.toJson());
              }

              // Clear fields and close dialog
              _titleController.clear();
              _chapterNumberController.clear();
              _pagesController.clear();
              Navigator.pop(context);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
     // Clear text fields when dialog is closed, regardless of save or cancel
    _titleController.clear();
    _chapterNumberController.clear();
    _pagesController.clear();
  }

  Future<void> _deleteChapter(String chapterId) async {
     await FirebaseFirestore.instance
        .collection('comics')
        .doc(widget.comicId)
        .collection('chapters')
        .doc(chapterId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý chương'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('comics')
            .doc(widget.comicId)
            .collection('chapters')
            .orderBy('chapterNumber', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Chưa có chương nào.'));
          }

          final chapters = snapshot.data!.docs.map((doc) => Chapter.fromSnapshot(doc)).toList();

          return ListView.builder(
            itemCount: chapters.length,
            itemBuilder: (context, index) {
              final chapter = chapters[index];
              return ListTile(
                title: Text('Chương ${chapter.chapterNumber}: ${chapter.title}'),
                subtitle: Text('${chapter.pages.length} trang'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                      onPressed: () => _addOrUpdateChapter(chapter: chapter),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _deleteChapter(chapter.id!),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrUpdateChapter(),
        tooltip: 'Thêm chương mới',
        child: const Icon(Icons.add),
      ),
    );
  }
}
