import 'package:flutter/material.dart';

class WebHlsPlayer extends StatelessWidget {
  final String url;
  final String title;

  const WebHlsPlayer({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
