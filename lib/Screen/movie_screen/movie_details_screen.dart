import 'dart:async';
import 'dart:io';
import 'package:flu_wake_lock/flu_wake_lock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iptv/Screen/SplashScreen.dart';
import 'package:iptv/Screen/movie_screen/widget/movie_details_widget.dart';
import 'package:iptv/Screen/movie_screen/widget/series_details_widget.dart';
import 'package:iptv/Screen/player_screen/player__local_screen.dart';
import 'package:iptv/Screen/player_screen/player_screen.dart';
import 'package:iptv/Widget/button_widget.dart';
import 'package:iptv/Widget/main_image_widget.dart';
import 'package:iptv/app_material/app_colors.dart';
import 'package:iptv/app_material/app_styles.dart';
import 'package:iptv/controller/download_getx_controller.dart';
import 'package:iptv/controller/home_getx_controller.dart';
import 'package:iptv/database/database_helper.dart';
import 'package:iptv/model/stream_model.dart';
import 'package:iptv/shared_preferences/shared_pref_controller.dart';
import 'package:iptv/utils/app_helper.dart';
import 'package:iptv/utils/stream_url_builder.dart';

class MovieDetailsScreen extends StatefulWidget {
  final StreamModel streamModel;
  final bool isMovie;
  const MovieDetailsScreen({
    super.key,
    required this.streamModel,
    required this.isMovie,
  });

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen>
    with AppHelper {
  HomeGetxController homeGetxController = Get.isRegistered<HomeGetxController>()
      ? Get.find<HomeGetxController>()
      : Get.put(HomeGetxController());
  DownloadGetxController? downloadGetxController = kIsWeb
      ? null
      : Get.isRegistered<DownloadGetxController>()
          ? Get.find<DownloadGetxController>()
          : Get.put(DownloadGetxController());
  FluWakeLock? fluWakeLock;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      fluWakeLock = FluWakeLock();
    }
    homeGetxController.getMovieDetails(
      id: widget.streamModel.streamId.toString(),
      isMovie: widget.isMovie,
    );
  }

  @override
  void dispose() {
    homeGetxController.movieDetails = null;
    homeGetxController.seriesDetails = null;
    homeGetxController.selectedSeriesSesonIndex.value = 0;
    homeGetxController.selectedSeriesEpisodesIndex.value = 0;
    // downloadGetxController.progres.value = 0;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    fluWakeLock?.enable();

    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 720;
    final poster = MainImageWidget(
      image: widget.streamModel.streamIcon,
      fit: BoxFit.cover,
      height: isWide ? double.infinity : 260,
      width: double.infinity,
      radius: isWide ? 0 : 8,
    );
    final details = widget.isMovie
        ? MovieDetailsWidget(
            name: widget.streamModel.name ?? 'Movie Name',
            image: widget.streamModel.streamIcon,
          )
        : SeriesDetailsWidget(
            name: widget.streamModel.name ?? 'Series Name',
            image: widget.streamModel.streamIcon,
            plot: widget.streamModel.plot,
            rating: widget.streamModel.rating,
            cast: widget.streamModel.cast,
            genre: widget.streamModel.genre,
            backdropPath: widget.streamModel.backdropPath,
          );

    return Scaffold(
      floatingActionButton: widget.isMovie
          ? Row(
              children: [
                const Expanded(flex: 3, child: SizedBox()),
                Expanded(
                  flex: 3,
                  child: ButtonWidget(
                    onPressed: () async {
                      if (SharedPrefController().name.isEmpty) {
                        SharedPrefController().clear();
                        if (!kIsWeb) {
                          DatabaseHelper.instance.clearDatabase();
                        }
                        Future.delayed(
                          const Duration(milliseconds: 1),
                          () {
                            Get.offAll(() => const SplashScreen());
                            showMeesage(
                              title: 'انتهت الجلسة',
                              // subTitle: 'تم انتهاء الجلسة الخاصة بك',
                              isError: true,
                            );
                          },
                        );
                        return;
                      }
                      final url = contentPlaybackUrl(
                        contentId: widget.streamModel.streamId,
                        type: widget.isMovie ? 'movie' : 'series',
                        extension: 'mp4',
                      );
                      // await Get.to(() => PlayerScreen(
                      await Get.to(() =>
                          // Platform.isAndroid
                          //     ? PlayerScreen(
                          //         videoUrl: url,
                          //         title: widget.streamModel.name ?? '')
                          //     :
                          PlayerScreen(
                            // VlcPlayerScreen(
                            videoUrl: url,
                            title: widget.streamModel.name ?? '',
                          ));

                      Future.delayed(
                        const Duration(seconds: 1),
                        () {
                          setState(() {});
                        },
                      );
                    },
                    height: 50,
                    width: Get.width * 0.65,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'تشغيل',
                          style: AppStyles().font16(
                              color: AppColors.whiteColor,
                              fontWeight: FontWeight.bold),
                        ),
                        buildWatchedProgressDivider(
                            widget.streamModel.streamId.toString()),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                if (!kIsWeb && SharedPrefController().download)
                  Expanded(
                    flex: 2,
                    child: Obx(() {
                      return ButtonWidget(
                        color: downloadGetxController!.isVideoDownloaded(
                                widget.streamModel.name ?? '')
                            ? AppColors.subPrimryColor
                            : AppColors.greenColor,
                        onPressed: (downloadGetxController!
                                        .isDownloading.value &&
                                    downloadGetxController!.name ==
                                        widget.streamModel.name) ||
                                (downloadGetxController!
                                    .isInQueue(widget.streamModel.name ?? ''))
                            ? null
                            : () {
                                if (downloadGetxController!
                                        .isDownloading.value &&
                                    downloadGetxController!.name ==
                                        widget.streamModel.name) {
                                  return; // إذا كان الفيديو قيد التنزيل، لا تفعل شيئًا
                                }

                                String videoTitle =
                                    widget.streamModel.name ?? '';

                                bool isDownloaded = downloadGetxController!
                                    .isVideoDownloaded(videoTitle);

                                if (isDownloaded) {
                                  Get.to(() => PlayerLocalScreen(
                                      title: widget.streamModel.name ?? '',
                                      videoUrl: File(
                                          '/storage/emulated/0/Download/Stream Live/${widget.streamModel.name}.mp4')));
                                } else {
                                  if (SharedPrefController().name.isEmpty) {
                                    SharedPrefController().clear();
                                    if (!kIsWeb) {
                                      DatabaseHelper.instance.clearDatabase();
                                    }
                                    Future.delayed(
                                        const Duration(milliseconds: 1), () {
                                      Get.offAll(() => const SplashScreen());
                                      showMeesage(
                                          title: 'انتهت الجلسة',
                                          // subTitle:
                                          //     'تم انتهاء الجلسة الخاصة بك',
                                          isError: true);
                                    });
                                    return;
                                  }

                                  final url = contentPlaybackUrl(
                                    contentId: widget.streamModel.streamId,
                                    type: widget.isMovie ? 'movie' : 'series',
                                    extension: 'mp4',
                                  );

                                  downloadGetxController!.addToDownloadQueue(
                                      url: url,
                                      isSeries: false,
                                      seriesName: '',
                                      name: videoTitle);
                                  setState(() {});
                                }
                              },
                        height: 50,
                        width: Get.width * 0.65,
                        child: Obx(() {
                          String videoTitle =
                              widget.streamModel.name ?? 'Movie Name';
                          bool isDownloading =
                              downloadGetxController!.isDownloading.value &&
                                  downloadGetxController!.name == videoTitle;

                          bool isInQueue =
                              downloadGetxController!.isInQueue(videoTitle);
                          bool isDownloaded = downloadGetxController!
                              .isVideoDownloaded(videoTitle);
                          int progress = isDownloading
                              ? downloadGetxController!.progres.value
                              : 0;

                          return Text(
                            isDownloading
                                ? '${progress.toStringAsFixed(0)} %'
                                : isInQueue
                                    ? 'انتظار التحميل'
                                    : isDownloaded
                                        ? 'مشاهدة'
                                        : 'تحميل',
                            style: AppStyles().font14(
                                color: isDownloading || isInQueue
                                    ? AppColors.blackColor
                                    : AppColors.whiteColor),
                          );
                        }),
                      );
                    }),
                  ),
                if (!kIsWeb)
                  Obx(() {
                    if ((downloadGetxController!.progres.value > 0 ||
                            downloadGetxController!.isDownloading.value) &&
                        downloadGetxController!.name ==
                            widget.streamModel.name) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              onPressed: () {
                                downloadGetxController!
                                    .togglePauseResumeDownload(
                                        downloadGetxController!
                                            .downloadingFileName.value);
                              },
                              icon:
                                  downloadGetxController!.isDownloadPaused.value
                                      ? const Icon(Icons.play_arrow)
                                      : const Icon(Icons.pause)),
                          IconButton(
                              onPressed: () {
                                downloadGetxController!.cancelDownload(
                                    downloadGetxController!
                                        .downloadingFileName.value);

                                setState(() {});
                              },
                              icon: const Icon(Icons.close)),
                        ],
                      );
                    } else {
                      return const SizedBox();
                    }
                  })
              ],
            )
          : null,
      body: SafeArea(
        child: isWide
            ? Row(
                children: [
                  SizedBox(
                    width: size.width.clamp(280, 420).toDouble(),
                    child: poster,
                  ),
                  Expanded(child: details),
                ],
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: poster,
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: size.height - 390,
                    ),
                    child: details,
                  ),
                ],
              ),
      ),
    );
  }

  // Get the last watched position (already exists, unchanged)
  Future<Map<String, int?>> _getLastWatchedPosition(String videoId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'watch_progress',
      where: 'content_id = ?',
      whereArgs: [videoId],
    );
    if (result.isNotEmpty) {
      return {
        'watched_duration': result.first['watched_duration'] as int?,
        'total_duration': result.first['total_duration'] as int?,
      };
    } else {
      return {'watched_duration': null, 'total_duration': null};
    }
  }

  Widget buildWatchedProgressDivider(String videoId) {
    return FutureBuilder<Map<String, int?>>(
      future: _getLastWatchedPosition(videoId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox();
        } else if (snapshot.hasData) {
          final watchedDuration = snapshot.data!['watched_duration'] ?? 0;
          final totalDuration = snapshot.data!['total_duration'] ?? 0;
          if (watchedDuration > 0 && totalDuration > 0) {
            final progress = watchedDuration / totalDuration;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey,
                  color: AppColors.subPrimryColor,
                  minHeight: 4,
                ),
              ),
            );
          }
        }
        return const SizedBox();
      },
    );
  }
}
