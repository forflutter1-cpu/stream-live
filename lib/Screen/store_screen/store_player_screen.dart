import 'package:flutter/material.dart';
import 'package:iptv/app_material/app_colors.dart';
import 'package:video_player/video_player.dart';

class StorePlayerScreen extends StatefulWidget {
  final String videoUrl;
  const StorePlayerScreen({
    super.key,
    required this.videoUrl,
  });

  @override
  State<StorePlayerScreen> createState() => _StorePlayerScreenState();
}

class _StorePlayerScreenState extends State<StorePlayerScreen> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(
      widget.videoUrl,
    ))
      ..initialize().then((_) {
        setState(() {});

        _controller!.play();
        _controller!.addListener(() {});
      }).catchError((error) {
        print("Error initializing video player: $error");
      });
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackColor,
      body: Stack(
        children: [
          _controller != null && _controller!.value.isInitialized
              ? Positioned.fill(
                  child: AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  ),
                )
              : const Positioned.fill(
                  child: Center(
                  child: SizedBox(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator(
                      color: AppColors.whiteColor,
                    ),
                  ),
                )),
        ],
      ),
    );
  }
}
