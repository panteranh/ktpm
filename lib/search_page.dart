import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  // Dữ liệu mẫu cho tìm kiếm
  final List<Map<String, dynamic>> _allComics = [
    {'title': 'One Piece', 'chapter': 'Chapter 1095', 'rating': 4.9},
    {'title': 'Naruto', 'chapter': 'Chapter 700', 'rating': 4.8},
    {'title': 'Bleach', 'chapter': 'Chapter 686', 'rating': 4.7},
    {'title': 'Dragon Ball', 'chapter': 'Chapter 519', 'rating': 4.9},
    {'title': 'Attack on Titan', 'chapter': 'Chapter 139', 'rating': 4.8},
    {'title': 'My Hero Academia', 'chapter': 'Chapter 405', 'rating': 4.6},
    {'title': 'Demon Slayer', 'chapter': 'Chapter 205', 'rating': 4.7},
    {'title': 'Jujutsu Kaisen', 'chapter': 'Chapter 245', 'rating': 4.8},
  ];

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchResults = _allComics
          .where(
            (comic) =>
                comic['title'].toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tìm truyện',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              onChanged: _performSearch,
              decoration: InputDecoration(
                hintText: 'Nhập tên truyện...',
                prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // Search Results or Suggestions
          Expanded(
            child: _isSearching
                ? _searchResults.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Không tìm thấy truyện',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final comic = _searchResults[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: Container(
                                  width: 50,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.image,
                                    color: Colors.grey[400],
                                  ),
                                ),
                                title: Text(
                                  comic['title'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(comic['chapter']),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          size: 14,
                                          color: Colors.amber,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          comic['rating'].toString(),
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                                onTap: () {
                                  // Handle comic tap
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Đã chọn: ${comic['title']}',
                                      ),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Tìm kiếm phổ biến',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              [
                                'One Piece',
                                'Naruto',
                                'Dragon Ball',
                                'Attack on Titan',
                                'Demon Slayer',
                              ].map((tag) {
                                return Padding(
                                  padding: const EdgeInsets.only(left: 16),
                                  child: ActionChip(
                                    label: Text(tag),
                                    backgroundColor: Colors.deepPurple[50],
                                    labelStyle: const TextStyle(
                                      color: Colors.deepPurple,
                                    ),
                                    onPressed: () {
                                      _searchController.text = tag;
                                      _performSearch(tag);
                                    },
                                  ),
                                );
                              }).toList(),
                        ),
                        const SizedBox(height: 24),
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Thể loại phổ biến',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _buildCategoryTile('Hành động', Icons.flash_on),
                            _buildCategoryTile('Lãng mạn', Icons.favorite),
                            _buildCategoryTile(
                              'Hài hước',
                              Icons.sentiment_satisfied_alt,
                            ),
                            _buildCategoryTile('Phiêu lưu', Icons.explore),
                            _buildCategoryTile('Kinh dị', Icons.wb_twilight),
                          ],
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTile(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã chọn thể loại: $title'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
    );
  }
}
