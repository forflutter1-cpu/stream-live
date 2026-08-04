import 'package:flutter/material.dart';

class MainImageWidget extends StatelessWidget {
  final String? image;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final double radius;
  const MainImageWidget({
    super.key,
    required this.image,
    this.height,
    this.width,
    this.fit,
    this.radius = 0,
  });

  @override
  Widget build(BuildContext context) {
    final imageKey = ValueKey<String>(image ?? 'default_image_key');
    final imageUrl = (image ?? '').trim();
    final resolvedImageUrl = _resolveImageUrl(imageUrl);

    if (imageUrl.trim().isEmpty) {
      return ClipRRect(
        key: imageKey,
        borderRadius: BorderRadius.circular(radius),
        child: Image.asset(
          'images/new_logo.jpg',
          height: height,
          width: width,
          fit: fit,
        ),
      );
    }

    return ClipRRect(
      key: imageKey,
      borderRadius: BorderRadius.circular(radius),
      child: FadeInImage.assetNetwork(
        placeholder: 'images/new_logo.jpg',
        image: resolvedImageUrl,
        height: height,
        width: width,
        fit: fit,
        imageErrorBuilder:
            (BuildContext context, Object error, StackTrace? stackTrace) {
          return Image.asset(
            'images/new_logo.jpg',
            height: height,
            width: width,
            fit: fit,
          );
        },
      ),
    );
  }

  String _resolveImageUrl(String rawUrl) {
    if (rawUrl.isEmpty) return rawUrl;
    final normalizedUrl = rawUrl.startsWith('//') ? 'https:$rawUrl' : rawUrl;
    final uri = Uri.tryParse(normalizedUrl);
    if (uri == null || !uri.hasScheme) return normalizedUrl;
    if (uri.scheme != 'http' && uri.scheme != 'https') return normalizedUrl;
    if (uri.host == 'streams.alkmal.com' && uri.path == '/image-proxy') {
      return normalizedUrl;
    }
    return 'https://streams.alkmal.com/image-proxy?url=${Uri.encodeComponent(normalizedUrl)}';
  }
}
