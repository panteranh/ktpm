import 'package:flutter/material.dart';
import 'category_detail_page.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  final List<Map<String, dynamic>> categories = const [
    {
      'name': 'Hành động',
      'icon': Icons.flash_on,
      'color': Colors.red,
      'count': 1234,
    },
    {
      'name': 'Lãng mạn',
      'icon': Icons.favorite,
      'color': Colors.pink,
      'count': 987,
    },
    {
      'name': 'Hài hước',
      'icon': Icons.sentiment_satisfied_alt,
      'color': Colors.orange,
      'count': 756,
    },
    {
      'name': 'Phiêu lưu',
      'icon': Icons.explore,
      'color': Colors.blue,
      'count': 891,
    },
    {
      'name': 'Kinh dị',
      'icon': Icons.wb_twilight,
      'color': Colors.purple,
      'count': 543,
    },
    {
      'name': 'Trinh thám',
      'icon': Icons.search,
      'color': Colors.brown,
      'count': 432,
    },
    {
      'name': 'Học đường',
      'icon': Icons.school,
      'color': Colors.green,
      'count': 678,
    },
    {
      'name': 'Siêu nhiên',
      'icon': Icons.auto_awesome,
      'color': Colors.indigo,
      'count': 567,
    },
    {
      'name': 'Thể thao',
      'icon': Icons.sports_soccer,
      'color': Colors.teal,
      'count': 345,
    },
    {
      'name': 'Isekai',
      'icon': Icons.public,
      'color': Colors.deepOrange,
      'count': 789,
    },
    {
      'name': 'Drama',
      'icon': Icons.theater_comedy,
      'color': Colors.amber,
      'count': 456,
    },
    {
      'name': 'Fantasy',
      'icon': Icons.auto_stories,
      'color': Colors.cyan,
      'count': 890,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thể loại truyện',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return _buildCategoryCard(context, category);
        },
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    Map<String, dynamic> category,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryDetailPage(
              categoryName: category['name'],
              categoryColor: category['color'],
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [category['color'].withOpacity(0.7), category['color']],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: category['color'].withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(category['icon'], size: 48, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              category['name'],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${category['count']} truyện',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
