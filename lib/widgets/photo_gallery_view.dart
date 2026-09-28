import 'package:flutter/material.dart';

class PhotoGalleryView extends StatelessWidget {
  final List<String> imageUrls; // can be updated to handle List<int> ids if needed, assuming network URLs for now

  const PhotoGalleryView({super.key, required this.imageUrls});

  static const Color primaryYellow = Color(0xFFEDC93A);
  static const Color darkBrown = Color(0xFF452B14);

  void _openFullScreen(BuildContext context, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenGallery(imageUrls: imageUrls, initialIndex: initialIndex),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) {
      return const Center(
        child: Text('No photos available', style: TextStyle(color: darkBrown, fontSize: 16)),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('PHOTO GALLERY', style: TextStyle(color: primaryYellow, fontWeight: FontWeight.bold)),
        backgroundColor: darkBrown,
        iconTheme: const IconThemeData(color: primaryYellow),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: imageUrls.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _openFullScreen(context, index),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrls[index],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class FullScreenGallery extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const FullScreenGallery({super.key, required this.imageUrls, required this.initialIndex});

  @override
  State<FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<FullScreenGallery> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.imageUrls.length,
        itemBuilder: (context, index) {
          return InteractiveViewer(
            child: Image.network(
              widget.imageUrls[index],
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(Icons.broken_image, color: Colors.white, size: 50),
              ),
            ),
          );
        },
      ),
    );
  }
}
