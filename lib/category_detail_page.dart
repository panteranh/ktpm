import 'package:flutter/material.dart';

class CategoryDetailPage extends StatefulWidget {
  final String categoryName;
  final Color categoryColor;

  const CategoryDetailPage({
    super.key,
    required this.categoryName,
    required this.categoryColor,
  });

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  String _selectedSort = 'Phổ biến';

  final List<String> _sortOptions = [
    'Phổ biến',
    'Mới nhất',
    'Đánh giá cao',
    'Lượt xem',
  ];

  // Dữ liệu mẫu truyện theo thể loại
  List<Map<String, dynamic>> get _comics => [
    {
      'title': 'Truyện ${widget.categoryName} 1',
      'chapter': 'Chapter 150',
      'rating': 4.8,
      'views': '1.2M',
      'status': 'Đang cập nhật',
    },
    {
      'title': 'Truyện ${widget.categoryName} 2',
      'chapter': 'Chapter 89',
      'rating': 4.6,
      'views': '850K',
      'status': 'Đang cập nhật',
    },
    {
      'title': 'Truyện ${widget.categoryName} 3',
      'chapter': 'Chapter 200',
      'rating': 4.9,
      'views': '2.1M',
      'status': 'Hoàn thành',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.categoryName,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _selectedSort = value;
              });
            },
            itemBuilder: (context) => _sortOptions.map((option) {
              return PopupMenuItem<String>(
                value: option,
                child: Row(
                  children: [
                    if (_selectedSort == option)
                      Icon(Icons.check, color: widget.categoryColor, size: 20)
                    else
                      const SizedBox(width: 20),
                    const SizedBox(width: 8),
                    Text(option),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.categoryColor.withOpacity(0.1),
                  Colors.transparent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                Text(
                  '${_comics.length} truyện',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sắp xếp theo: $_selectedSort',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // Comics list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _comics.length,
              itemBuilder: (context, index) {
                final comic = _comics[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: InkWell(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          // Thumbnail
                          Container(
                            width: 70,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.image,
                              size: 40,
                              color: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  comic['title'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  comic['chapter'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Colors.amber[700],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      comic['rating'].toString(),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Icon(
                                      Icons.remove_red_eye,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      comic['views'],
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
