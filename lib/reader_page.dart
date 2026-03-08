import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mangaapp1/models/chapter.dart';

class ReaderPage extends StatefulWidget {
  final Chapter chapter;
  final String comicTitle;

  const ReaderPage({super.key, required this.chapter, required this.comicTitle});

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    // Enter immersive mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    // Exit immersive mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            PageView.builder(
              itemCount: widget.chapter.pages.length,
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  minScale: 1.0,
                  maxScale: 4.0,
                  child: Center(
                    child: Image.network(
                      widget.chapter.pages[index],
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(child: Icon(Icons.error, color: Colors.white)),
                    ),
                  ),
                );
              },
            ),
            // Controls Overlay
            if (_showControls)
              _buildControlsOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildControlsOverlay() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Top Bar
        Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, left: 8, right: 8),
          color: Colors.black.withOpacity(0.5),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.comicTitle,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                       maxLines: 1,
                       overflow: TextOverflow.ellipsis,
                    ),
                     Text(
                      'Chương ${widget.chapter.chapterNumber}',
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
        ),
        // Bottom Bar (can be added later for sliders, etc.)
        Container(),
      ],
    );
  }
}
