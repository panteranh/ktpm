import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SmartImage extends StatefulWidget {
  final String imageUrl;
  final BoxFit fit;

  const SmartImage({super.key, required this.imageUrl, this.fit = BoxFit.cover});

  @override
  State<SmartImage> createState() => _SmartImageState();
}

class _SmartImageState extends State<SmartImage> {
  Future<bool> _canLoadImage() async {
    final prefs = await SharedPreferences.getInstance();
    final loadOnlyOnWifi = prefs.getBool('loadOnlyOnWifi') ?? false;

    // If the setting is off, always allow loading
    if (!loadOnlyOnWifi) {
      return true;
    }

    // If the setting is on, check for Wi-Fi connection
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult.contains(ConnectivityResult.wifi);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _canLoadImage(),
      builder: (context, snapshot) {
        // While waiting for the check, show a loading indicator
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2.0));
        }

        // If there was an error during the check, show an error icon
        if (snapshot.hasError || snapshot.data == null) {
          return _buildErrorPlaceholder(Icons.error_outline, 'Lỗi kiểm tra mạng');
        }

        final canLoad = snapshot.data!;
        if (canLoad) {
          return Image.network(
            widget.imageUrl,
            fit: widget.fit,
            // Show a loading indicator while the image is downloading
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator(strokeWidth: 2.0));
            },
            // Show an icon if the image fails to load
            errorBuilder: (context, error, stackTrace) =>
                _buildErrorPlaceholder(Icons.broken_image_outlined, 'Lỗi tải ảnh'),
          );
        } else {
          // If loading is restricted, show a Wi-Fi off icon
          return _buildErrorPlaceholder(Icons.wifi_off_outlined, 'Chỉ tải qua Wi-Fi');
        }
      },
    );
  }

  Widget _buildErrorPlaceholder(IconData icon, String message) {
    return Container(
      color: Colors.grey.withOpacity(0.1),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.grey, size: 32),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
