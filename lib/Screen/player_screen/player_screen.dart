import 'dart:async';

import 'package:flu_wake_lock/flu_wake_lock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iptv/Widget/web_hls_player.dart';
import 'package:iptv/api/api_helper.dart';
import 'package:iptv/Widget/main_image_widget.dart';
import 'package:iptv/app_material/app_colors.dart';
import 'package:iptv/app_material/app_styles.dart';
import 'package:iptv/database/database_helper.dart';
import 'package:iptv/model/series_details_model.dart';
import 'package:iptv/utils/app_helper.dart';

class PlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;
  // final String mainTitle;
  final List<Counts>? episodes;

  const PlayerScreen({
    super.key,
    required this.videoUrl,
    required this.title,
    // required this.mainTitle,
    this.episodes,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> with ApiHelper, AppHelper {
  String title = '';
  BetterPlayerController? _controller;
  bool _showEpisodes = false;
  late BetterPlayerDataSource dataSource;
  Timer? timer;
  final FluWakeLock fluWakeLock = FluWakeLock();

  Future<void> enableWakeLock() async {
    if (!kIsWeb) {
      await fluWakeLock.enable();
    }
  }

  // String? currentEpisodeId;

  @override
  void initState() {
    super.initState();
    // fluWakeLock.enable();
    title = widget.title;
    if (kIsWeb) {
      return;
    }
    dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.videoUrl,
      liveStream: false,
    );
    _controller = BetterPlayerController(
      const BetterPlayerConfiguration(
        deviceOrientationsAfterFullScreen: [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight
        ],
        deviceOrientationsOnFullScreen: [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight
        ],
        autoPlay: true,
        aspectRatio: 16 / 9,
        fit: BoxFit.contain,
        // allowedScreenSleep: false,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          enableSkips: true,
          enableQualities: true,
          enableSubtitles: false,
        ),
      ),
    );
    _controller?.addEventsListener((event) async {
      await enableWakeLock();
      if (event.betterPlayerEventType == BetterPlayerEventType.exception) {
        _handlePlayerError();
      }
    });
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        saveProgress();
      },
    );
    initializePlayer();
  }

  void initializePlayer() async {
    if (kIsWeb) return;
    String videoId = _extractVideoId(widget.videoUrl);
    int? lastPosition = await getLastWatchedPosition(videoId);

    await _controller?.setupDataSource(dataSource);

    if (lastPosition != null && lastPosition > 5) {
      // تأخير بسيط للتأكد من جاهزية الفيديو
      await Future.delayed(const Duration(milliseconds: 300));
      _controller?.seekTo(Duration(seconds: lastPosition));
    }

    _controller?.play();
    setState(() {});
  }

  Future<int?> getLastWatchedPosition(String videoId) async {
    if (kIsWeb) return null;
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'watch_progress',
      where: 'content_id = ?',
      whereArgs: [videoId],
    );

    if (result.isNotEmpty) {
      return result.first['watched_duration'] as int;
    } else {
      return null;
    }
  }

  void _playEpisode(String url, String newTitle) async {
    if (kIsWeb) return;
    setState(() {
      title = newTitle;
    });
    _controller?.pause();
    final dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      url,
      liveStream: false,
    );
    _controller?.addEventsListener((event) async {
      await enableWakeLock();
    });
    await _controller?.setupDataSource(dataSource);
    await _controller?.setVolume(1.0);
    await _controller?.play();
  }

  @override
  void dispose() {
    saveProgress();
    // fluWakeLock.disable();
    timer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  void _toggleEpisodes() {
    setState(() {
      _showEpisodes = !_showEpisodes;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        backgroundColor: AppColors.blackColor,
        body: Stack(
          children: [
            Positioned.fill(
              child: WebHlsPlayer(
                url: widget.videoUrl,
                title: title,
              ),
            ),
            PositionedDirectional(
              top: 24,
              start: 24,
              child: SafeArea(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.whiteColor.withAlpha(235),
                      child: IconButton(
                        tooltip: 'رجوع',
                        icon: const Icon(Icons.arrow_back,
                            color: AppColors.blackColor),
                        onPressed: () {
                          if (Navigator.of(context).canPop()) {
                            Get.back();
                          } else {
                            Get.offAllNamed('/home');
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.62,
                      ),
                      child: Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: AppStyles().font18(
                          color: AppColors.whiteColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onDoubleTap: _toggleEpisodes,
        child: Stack(
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: BetterPlayer(controller: _controller!),
              ),
            ),
            Positioned(
              top: 40,
              left: 16,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.whiteColor.withAlpha(235),
                    child: IconButton(
                      tooltip: 'رجوع',
                      icon: const Icon(Icons.arrow_back,
                          color: AppColors.blackColor),
                      onPressed: () {
                        if (Navigator.of(context).canPop()) {
                          Get.back();
                        } else {
                          Get.offAllNamed('/home');
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.58,
                    ),
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (widget.episodes != null && widget.episodes!.isNotEmpty)
              Positioned(
                top: 40,
                right: 16,
                child: IconButton(
                  icon: Icon(
                    _showEpisodes ? Icons.close : Icons.list,
                    color: Colors.white,
                  ),
                  onPressed: _toggleEpisodes,
                ),
              ),
            if (_showEpisodes &&
                widget.episodes != null &&
                widget.episodes!.isNotEmpty)
              Positioned(
                top: 25,
                bottom: 20,
                right: 10,
                child: Container(
                  width: 250,
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                  decoration: BoxDecoration(
                    color: AppColors.greysub4Color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      // زر الإغلاق
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: Text('الحلقات',
                                textAlign: TextAlign.center,
                                style: AppStyles().font20(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.blackColor,
                                )),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close,
                                color: AppColors.blackColor),
                            onPressed: _toggleEpisodes,
                          ),
                        ],
                      ),
                      // القائمة
                      Expanded(
                        child: ListView.builder(
                          itemCount: widget.episodes!.length,
                          itemBuilder: (context, index) {
                            final ep = widget.episodes![index];
                            final isCurrent = title == ep.title;

                            return Card(
                              color: isCurrent ? AppColors.primryColor : null,
                              child: ListTile(
                                leading: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: MainImageWidget(
                                    image: ep.info?.movieImage,
                                    radius: 5,
                                  ),
                                ),
                                title: Text(
                                  ep.title,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: isCurrent
                                        ? AppColors.whiteColor
                                        : AppColors.blackColor,
                                  ),
                                ),
                                onTap: () {
                                  String url = widget.videoUrl.replaceAll(
                                    widget.videoUrl.split('/').last,
                                    '${ep.id}.${ep.containerExtension}',
                                  );
                                  _playEpisode(url, ep.title);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  void saveProgress() async {
    if (kIsWeb || _controller?.videoPlayerController == null) return;
    final position = _controller?.videoPlayerController!.value.position;
    final duration = _controller?.videoPlayerController!.value.duration;

    if (duration != null) {
      final watchedSeconds = position!.inSeconds;
      final totalSeconds = duration.inSeconds;

      if (watchedSeconds > totalSeconds / 2 && totalSeconds > 0) {
        final videoContentId =
            _extractVideoId(_controller!.betterPlayerDataSource!.url);

        await DatabaseHelper.instance.saveProgress(
          videoContentId,
          widget.episodes != null ? 'series' : 'movie',
          null, // ممكن تمرر رقم الحلقة
          watchedSeconds,
          totalSeconds,
        );
      }
    }
  }

  String _extractVideoId(String url) {
    // التعبير العادي لاستخراج المعرف الذي يأتي قبل أي امتداد (مثل .mp4 أو .avi أو .mkv)
    final regex =
        RegExp(r'\/([^\/]+)\.[a-zA-Z0-9]+$'); // يبحث عن أي جزء قبل الامتداد
    final match = regex.firstMatch(url);

    if (match != null) {
      return match.group(1) ?? ""; // إرجاع المعرف
    } else {
      return ""; // في حال لم يتم العثور على المعرف
    }
  }

  void _handlePlayerError() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        Get.defaultDialog(
          title: "تنبيه",
          titleStyle: AppStyles().font18(
            fontWeight: FontWeight.bold,
            color: AppColors.redColor,
          ),
          content: const Text(
            "يجب عليك الاشتراك لمشاهدة هذا المحتوى.\nإذا كنت مشتركاً بالفعل واستمر الخطأ يرجى التواصل معنا.",
            textAlign: TextAlign.center,
          ),
          textConfirm: "تواصل معنا للاشتراك",
          textCancel: "إلغاء",
          confirmTextColor: Colors.white,
          buttonColor: AppColors.primryColor,
          onConfirm: () {
            try {
              Get.back(); // close dialog
              contactDialog();
            } catch (_) {}
          },
          onCancel: () {
            try {
              Get.back();
            } catch (_) {}
          },
        );
      } catch (_) {}
    });
  }
}
