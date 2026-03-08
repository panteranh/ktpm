import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mangaapp1/manage_chapters_page.dart';
import 'package:mangaapp1/models/chapter.dart';
import 'package:mangaapp1/models/comic_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mangaapp1/models/comment.dart';
import 'package:mangaapp1/reader_page.dart';

class DetailPage extends StatefulWidget {
  final Comic comic;

  const DetailPage({super.key, required this.comic});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final _commentController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  bool _isAdmin() {
    return _auth.currentUser?.email == 'admin@coread.com';
  }

  Future<void> _toggleFavorite(bool isCurrentlyFavorite) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final favoriteRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(widget.comic.id);

    if (isCurrentlyFavorite) {
      await favoriteRef.delete();
    } else {
      await favoriteRef.set({'favoritedAt': Timestamp.now()});
    }
  }

  Future<void> _postComment() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final newComment = Comment(
      userId: user.uid,
      userName: user.displayName ?? 'Người dùng ẩn danh',
      userAvatar: user.photoURL,
      text: text,
      createdAt: Timestamp.now(),
    );

    await _firestore
        .collection('comics')
        .doc(widget.comic.id)
        .collection('comments')
        .add(newComment.toJson());

    _commentController.clear();
    FocusScope.of(context).unfocus(); // Dismiss keyboard
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tác giả: ${widget.comic.author}', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  _buildInfoRow(),
                  const SizedBox(height: 16),
                  Text('Mô tả', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(widget.comic.description, style: const TextStyle(fontSize: 16, height: 1.4)),
                  const SizedBox(height: 24),
                  Text('Danh sách chương', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const Divider(),
                ],
              ),
            ),
          ),
          _buildChapterList(),
           SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Bình luận', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            ),
          ),
          _buildCommentSection(),
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .collection('favorites')
          .doc(widget.comic.id)
          .snapshots(),
      builder: (context, snapshot) {
        final bool isFavorite = snapshot.hasData && snapshot.data!.exists;
        return SliverAppBar(
          expandedHeight: 250.0,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(widget.comic.title, style: const TextStyle(shadows: [Shadow(color: Colors.black, blurRadius: 4)])),
            background: Hero(
              tag: widget.comic.id ?? widget.comic.title,
              child: Image.network(
                widget.comic.cover,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.white,
              ),
              tooltip: 'Yêu thích',
              onPressed: () => _toggleFavorite(isFavorite),
            ),
            if (_isAdmin())
              IconButton(
                icon: const Icon(Icons.edit_note),
                tooltip: 'Quản lý Chapter',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ManageChaptersPage(comicId: widget.comic.id!),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }

   Widget _buildInfoRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatChip(Icons.label_outline, widget.comic.genre, Colors.blue),
        _buildStatChip(Icons.visibility_outlined, '${widget.comic.views} Lượt xem', Colors.orange),
        _buildStatChip(Icons.check_circle_outline, widget.comic.status, Colors.green),
      ],
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Chip(
      avatar: Icon(icon, color: color, size: 18),
      label: Text(label),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide.none,
    );
  }

  Widget _buildChapterList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
       stream: _firestore
            .collection('comics')
            .doc(widget.comic.id)
            .collection('chapters')
            .orderBy('chapterNumber', descending: true)
            .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
        if (snapshot.data!.docs.isEmpty) return const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(20.0), child: Text('Truyện này chưa có chương nào.'))));
        final chapters = snapshot.data!.docs.map((doc) => Chapter.fromSnapshot(doc)).toList();
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final chapter = chapters[index];
              return ListTile(
                title: Text('Chương ${chapter.chapterNumber}: ${chapter.title}'),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReaderPage(chapter: chapter, comicTitle: widget.comic.title))),
              );
            },
            childCount: chapters.length,
          ),
        );
      },
    );
  }

  Widget _buildCommentSection() {
     return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
       stream: _firestore
            .collection('comics')
            .doc(widget.comic.id)
            .collection('comments')
            .orderBy('createdAt', descending: true)
            .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
        if (snapshot.data!.docs.isEmpty) return const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(20.0), child: Text('Chưa có bình luận nào. Hãy là người đầu tiên!'))));
        final comments = snapshot.data!.docs.map((doc) => Comment.fromSnapshot(doc)).toList();
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildCommentItem(comments[index]),
            childCount: comments.length,
          ),
        );
      },
    );
  }

   Widget _buildCommentItem(Comment comment) {
    final bool hasAvatar = comment.userAvatar?.isNotEmpty ?? false;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: hasAvatar ? NetworkImage(comment.userAvatar!) : null,
            child: !hasAvatar ? const Icon(Icons.person) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(comment.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(comment.text),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: TextField(
          controller: _commentController,
          decoration: InputDecoration(
            hintText: 'Viết bình luận...',
            border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
            suffixIcon: IconButton(
              icon: const Icon(Icons.send), 
              onPressed: _postComment,
            ),
          ),
        ),
      ),
    );
  }
}
