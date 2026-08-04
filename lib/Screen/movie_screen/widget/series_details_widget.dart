import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iptv/Screen/SplashScreen.dart';
import 'package:iptv/Screen/player_screen/player__local_screen.dart';
import 'package:iptv/Screen/player_screen/player_screen.dart';
import 'package:iptv/Widget/button_widget.dart';
import 'package:iptv/Widget/main_image_widget.dart';
import 'package:iptv/app_material/app_colors.dart';
import 'package:iptv/app_material/app_styles.dart';
import 'package:iptv/controller/download_getx_controller.dart';
import 'package:iptv/controller/home_getx_controller.dart';
import 'package:iptv/database/database_helper.dart';
import 'package:iptv/model/series_details_model.dart';
import 'package:iptv/shared_preferences/shared_pref_controller.dart';
import 'package:iptv/utils/app_helper.dart';
import 'package:iptv/utils/stream_url_builder.dart';
import 'package:shimmer/shimmer.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math' as math;

class SeriesDetailsWidget extends StatefulWidget {
  final String name;
  final String? image;
  final String? plot;
  final String? rating;
  final String? cast;
  final String? genre;
  final String? backdropPath;
  const SeriesDetailsWidget({
    super.key,
    required this.name,
    this.image,
    this.plot,
    this.rating,
    this.cast,
    this.genre,
    this.backdropPath,
  });

  @override
  State<SeriesDetailsWidget> createState() => _SeriesDetailsWidgetState();
}

class _SeriesDetailsWidgetState extends State<SeriesDetailsWidget>
    with AppHelper {
  String _safeText(dynamic value, [String fallback = '']) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  bool _hasText(dynamic value) => _safeText(value).isNotEmpty;

  List<Seasons> _displaySeasons(SeriesDetailsModel? details) {
    final seasons = details?.seasons
            ?.where((season) => season.seasonNumber != null)
            .toList() ??
        <Seasons>[];
    if (seasons.isNotEmpty) {
      seasons
          .sort((a, b) => (a.seasonNumber ?? 0).compareTo(b.seasonNumber ?? 0));
      return seasons;
    }

    final countsBySeason = details?.episodes?.countsBySeason;
    if (countsBySeason == null || countsBySeason.isEmpty) {
      return <Seasons>[];
    }

    final generated = countsBySeason.entries.map((entry) {
      final seasonNumber = int.tryParse(entry.key) ?? 0;
      final firstEpisodeInfo =
          entry.value.isNotEmpty ? entry.value.first.info : null;
      return Seasons(
        seasonNumber: seasonNumber,
        episodeCount: entry.value.length,
        name: 'الموسم $seasonNumber',
        overview: firstEpisodeInfo?.plot,
        cover: firstEpisodeInfo?.movieImage,
      );
    }).toList();
    generated
        .sort((a, b) => (a.seasonNumber ?? 0).compareTo(b.seasonNumber ?? 0));
    return generated;
  }

  String _seasonTitle(Seasons season, int index) {
    final name = _safeText(season.name);
    if (name.isNotEmpty && !name.toLowerCase().startsWith('season')) {
      return name;
    }
    return 'الموسم ${season.seasonNumber ?? index + 1}';
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: AppStyles().font16(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _infoText(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(title),
          Text(
            value,
            textAlign: TextAlign.start,
            style: AppStyles().font14(color: AppColors.blacksub4Color),
          ),
        ],
      ),
    );
  }

  Widget _metaPill({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.whiteColor.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.greysub3Color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.primryColor),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: AppStyles().font12(fontWeight: FontWeight.bold),
          ),
          Flexible(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: AppStyles().font12(color: AppColors.blacksub4Color),
            ),
          ),
        ],
      ),
    );
  }

  Future<String> getLocalFilePath(String videoTitle, String extension) async {
    Directory? appDir = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    if (appDir == null) return '';
    String appFolder = '${appDir.path}/Stream Live/${widget.name}/';
    return '$appFolder$videoTitle.$extension';
  }

  @override
  Widget build(BuildContext context) {
    HomeGetxController homeGetxController = Get.find();
    DownloadGetxController? downloadGetxController = kIsWeb
        ? null
        : Get.isRegistered<DownloadGetxController>()
            ? Get.find<DownloadGetxController>()
            : Get.put(DownloadGetxController());
    final downloadController = downloadGetxController;

    return Stack(
      children: [
        Obx(() {
          if (homeGetxController.isLoadingMovieDetials.value) {
            return const SizedBox();
          } else if (homeGetxController.seriesDetails != null) {
            final seriesInfo = homeGetxController.seriesDetails?.info;
            final backdropPath = seriesInfo?.backdropPath;
            final cover = seriesInfo?.cover;
            return backdropPath != null && backdropPath.isNotEmpty
                ? Opacity(
                    opacity: 0.3,
                    child: MainImageWidget(
                      image: _safeText(backdropPath.first),
                      fit: BoxFit.fill,
                      height: Get.height,
                    ),
                  )
                : _hasText(cover) || _hasText(widget.image)
                    ? Opacity(
                        opacity: 0.3,
                        child: MainImageWidget(
                          image: _hasText(cover)
                              ? _safeText(cover)
                              : _safeText(widget.image),
                          fit: BoxFit.fill,
                          height: Get.height,
                          width: Get.width,
                        ),
                      )
                    : const SizedBox();
          } else {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 56),
                child: Text(
                  'تعذر تحميل تفاصيل المسلسل حالياً',
                  textAlign: TextAlign.center,
                  style: AppStyles().font16(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primryColor,
                  ),
                ),
              ),
            );
          }
        }),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text(
                  widget.name,
                  style: AppStyles().font20(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primryColor,
                  ),
                ),
                const SizedBox(height: 10),
                Obx(() {
                  if (homeGetxController.isLoadingMovieDetials.value) {
                    return Shimmer.fromColors(
                      baseColor: AppColors().baseColor,
                      highlightColor: AppColors().highlightColor,
                      child: Column(
                        children: List.generate(5, (index) {
                          return const SizedBox(
                            height: 35,
                            child: Divider(
                              thickness: 20,
                              endIndent: 20,
                            ),
                          );
                        }),
                      ),
                    );
                  } else if (homeGetxController.seriesDetails != null) {
                    final seriesInfo = homeGetxController.seriesDetails?.info;
                    final displaySeasons =
                        _displaySeasons(homeGetxController.seriesDetails);
                    final hasEpisodes = homeGetxController.seriesDetails
                            ?.episodes?.countsBySeason?.isNotEmpty ==
                        true;
                    final seasonEntries = homeGetxController
                            .seriesDetails?.episodes?.countsBySeason?.entries
                            .toList() ??
                        [];
                    seasonEntries.sort((a, b) {
                      final aNumber = int.tryParse(a.key) ?? 0;
                      final bNumber = int.tryParse(b.key) ?? 0;
                      return aNumber.compareTo(bNumber);
                    });
                    final int selectedSeasonIndex = seasonEntries.isEmpty
                        ? 0
                        : homeGetxController.selectedSeriesSesonIndex.value
                            .clamp(0, seasonEntries.length - 1)
                            .toInt();
                    final List<Counts> currentEpisodes = seasonEntries.isEmpty
                        ? <Counts>[]
                        : seasonEntries[selectedSeasonIndex].value;
                    if (homeGetxController.selectedSeriesSesonIndex.value !=
                        selectedSeasonIndex) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        homeGetxController.changeSelectedSeriesSesonIndex(
                            selectedSeasonIndex);
                      });
                    }

                    final fallbackPlot = _safeText(widget.plot);
                    final fallbackRating = _safeText(widget.rating);
                    final fallbackCast = _safeText(widget.cast);
                    final fallbackGenre = _safeText(widget.genre);
                    final plot = _safeText(seriesInfo?.plot, fallbackPlot);
                    final rating = _safeText(
                      seriesInfo?.rating,
                      fallbackRating.isNotEmpty ? fallbackRating : 'غير متوفر',
                    );
                    final cast = _safeText(seriesInfo?.cast, fallbackCast);
                    final genre = _safeText(seriesInfo?.genre, fallbackGenre);
                    final hasFallbackInfo = fallbackPlot.isNotEmpty ||
                        fallbackRating.isNotEmpty ||
                        fallbackCast.isNotEmpty;

                    if (seriesInfo == null &&
                        !hasEpisodes &&
                        !hasFallbackInfo) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 56),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: AppColors.primryColor,
                                size: 42,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'تفاصيل المسلسل غير متوفرة حالياً',
                                textAlign: TextAlign.center,
                                style: AppStyles().font16(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'جرّب تحديث المكتبة أو اختيار مسلسل آخر.',
                                textAlign: TextAlign.center,
                                style: AppStyles().font12(
                                  color: AppColors.greysub3Color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _metaPill(
                              icon: Icons.star,
                              label: 'التقييم',
                              value: rating,
                            ),
                            if (genre.isNotEmpty)
                              _metaPill(
                                icon: Icons.category_outlined,
                                label: 'النوع',
                                value: genre,
                              ),
                            if (currentEpisodes.isNotEmpty)
                              _metaPill(
                                icon: Icons.video_library_outlined,
                                label: 'الحلقات',
                                value: currentEpisodes.length.toString(),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (plot.isNotEmpty)
                          _infoText('القصة', plot)
                        else
                          _infoText(
                            'القصة',
                            'لا يوجد وصف متوفر حالياً، ويمكنك مشاهدة الحلقات من القائمة بالأسفل.',
                          ),
                        if (cast.isNotEmpty) _infoText('الممثلون', cast),
                        if (displaySeasons.isNotEmpty) ...[
                          _sectionTitle('المواسم'),
                          SizedBox(
                            height: 42,
                            width: double.infinity,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: displaySeasons.length,
                              separatorBuilder: (context, index) {
                                return const SizedBox(width: 8);
                              },
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () {
                                    homeGetxController
                                        .changeSelectedSeriesSesonIndex(index);
                                    homeGetxController
                                        .changeSelectedSeriesEpisodesIndex(0);
                                  },
                                  child: Obx(() {
                                    final selected = homeGetxController
                                            .selectedSeriesSesonIndex.value ==
                                        index;
                                    return Container(
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? AppColors.primryColor
                                            : AppColors.whiteColor
                                                .withValues(alpha: 0.9),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: selected
                                              ? AppColors.primryColor
                                              : AppColors.greysub3Color,
                                        ),
                                      ),
                                      child: Text(
                                        _seasonTitle(
                                            displaySeasons[index], index),
                                        style: AppStyles().font14(
                                          color: selected
                                              ? AppColors.whiteColor
                                              : AppColors.blackColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  }),
                                );
                              },
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _sectionTitle('الحلقات')),
                            if (currentEpisodes.isNotEmpty)
                              Text(
                                '${currentEpisodes.length} حلقة',
                                style: AppStyles()
                                    .font12(color: AppColors.blacksub2Color),
                              ),
                          ],
                        ),
                        const Divider(),
                        const SizedBox(height: 8),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: currentEpisodes.isEmpty
                                ? [
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 32),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.video_library_outlined,
                                              color: AppColors.primryColor,
                                              size: 42,
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              'لا توجد حلقات لهذا الموسم حالياً',
                                              textAlign: TextAlign.center,
                                              style: AppStyles().font16(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ]
                                : List.generate(currentEpisodes.length,
                                    (index) {
                                    final episode = currentEpisodes[index];
                                    final episodeId =
                                        episode.id?.toString() ?? '';
                                    final videoTitle = (episode.title
                                                ?.toString()
                                                .trim()
                                                .isNotEmpty ??
                                            false)
                                        ? episode.title.toString()
                                        : 'الحلقة ${index + 1}';
                                    final containerExtension = (episode
                                                .containerExtension
                                                ?.toString()
                                                .trim()
                                                .isNotEmpty ??
                                            false)
                                        ? episode.containerExtension.toString()
                                        : 'mp4';

                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 5,
                                            child: InkWell(
                                              onTap: (kIsWeb ||
                                                      downloadController ==
                                                          null ||
                                                      !downloadController
                                                          .isVideoDownloaded(
                                                              videoTitle))
                                                  ? () async {
                                                      if (SharedPrefController()
                                                          .name
                                                          .isEmpty) {
                                                        SharedPrefController()
                                                            .clear();
                                                        if (!kIsWeb) {
                                                          DatabaseHelper
                                                              .instance
                                                              .clearDatabase();
                                                        }
                                                        Future.delayed(
                                                          const Duration(
                                                              milliseconds: 1),
                                                          () {
                                                            Get.offAll(() =>
                                                                const SplashScreen());
                                                            showMeesage(
                                                              title:
                                                                  'انتهت الجلسة',
                                                              // subTitle:
                                                              //     'تم انتهاء الجلسة الخاصة بك',
                                                              isError: true,
                                                            );
                                                          },
                                                        );
                                                        return;
                                                      }
                                                      homeGetxController
                                                          .changeSelectedSeriesEpisodesIndex(
                                                              index);
                                                      final url =
                                                          contentPlaybackUrl(
                                                        contentId: episodeId,
                                                        type: 'series',
                                                        extension:
                                                            containerExtension,
                                                      );
                                                      await Get.to(() =>
                                                          PlayerScreen(
                                                            // () => VlcPlayerScreen(
                                                            videoUrl: url,
                                                            episodes:
                                                                currentEpisodes,
                                                            title: videoTitle,
                                                          ));
                                                      setState(() {});
                                                    }
                                                  : () async {
                                                      String filePath =
                                                          await getLocalFilePath(
                                                              videoTitle,
                                                              containerExtension);
                                                      File videoFile =
                                                          File(filePath);
                                                      if (await videoFile
                                                          .exists()) {
                                                        Get.to(() =>
                                                            PlayerLocalScreen(
                                                              title: videoTitle,
                                                              videoUrl:
                                                                  videoFile,
                                                            ));
                                                      } else {
                                                        showMeesage(
                                                          title:
                                                              'الملف غير موجود محليًا',
                                                          // subTitle:
                                                          //     'الملف غير موجود محليًا',
                                                          isError: true,
                                                        );
                                                      }
                                                    },
                                              child: Container(
                                                alignment: AlignmentDirectional
                                                    .centerStart,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 12),
                                                decoration: BoxDecoration(
                                                  color: homeGetxController
                                                              .selectedSeriesEpisodesIndex
                                                              .value ==
                                                          index
                                                      ? AppColors.primryColor
                                                      : AppColors.whiteColor
                                                          .withValues(
                                                              alpha: 0.9),
                                                  border: Border.all(
                                                    color: homeGetxController
                                                                .selectedSeriesEpisodesIndex
                                                                .value ==
                                                            index
                                                        ? AppColors.primryColor
                                                        : AppColors
                                                            .greysub3Color,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        MainImageWidget(
                                                          radius: 8,
                                                          image: _safeText(
                                                              episode.info
                                                                  ?.movieImage),
                                                          height: 40,
                                                          width: 50,
                                                        ),
                                                        const SizedBox(
                                                            width: 10),
                                                        Expanded(
                                                          child: Text(
                                                            videoTitle,
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: AppStyles()
                                                                .font14(
                                                              color: homeGetxController
                                                                          .selectedSeriesEpisodesIndex
                                                                          .value ==
                                                                      index
                                                                  ? AppColors
                                                                      .whiteColor
                                                                  : AppColors
                                                                      .blackColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 8),
                                                        Transform(
                                                          alignment:
                                                              Alignment.center,
                                                          transform:
                                                              Matrix4.rotationY(
                                                                  math.pi),
                                                          child: Icon(
                                                            Icons.play_arrow,
                                                            color: homeGetxController
                                                                        .selectedSeriesEpisodesIndex
                                                                        .value ==
                                                                    index
                                                                ? AppColors
                                                                    .whiteColor
                                                                : AppColors
                                                                    .blackColor
                                                                    .withValues(
                                                                        alpha:
                                                                            0.6),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Text(
                                                      'الحلقة ${episode.episodeNum?.toString() ?? index + 1}',
                                                      style: AppStyles().font12(
                                                        color: homeGetxController
                                                                    .selectedSeriesEpisodesIndex
                                                                    .value ==
                                                                index
                                                            ? AppColors
                                                                .whiteColor
                                                                .withValues(
                                                                    alpha: 0.85)
                                                            : AppColors
                                                                .blacksub2Color,
                                                      ),
                                                    ),
                                                    buildWatchedProgressDivider(
                                                        episodeId),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 15),
                                          if (!kIsWeb &&
                                              SharedPrefController().download &&
                                              downloadController != null)
                                            Expanded(
                                              child: Obx(() {
                                                bool isDownloading =
                                                    downloadController
                                                            .isDownloading
                                                            .value &&
                                                        downloadController
                                                                .name ==
                                                            videoTitle;
                                                bool isInQueue =
                                                    downloadController
                                                        .isInQueue(videoTitle);
                                                bool isDownloaded =
                                                    downloadController
                                                        .isVideoDownloaded(
                                                            videoTitle);
                                                int progress = isDownloading
                                                    ? downloadController
                                                        .progres.value
                                                    : 0;

                                                return ButtonWidget(
                                                  onPressed: isDownloading ||
                                                          isInQueue
                                                      ? null
                                                      : () async {
                                                          if (isDownloaded) {
                                                            String filePath =
                                                                await getLocalFilePath(
                                                                    videoTitle,
                                                                    containerExtension);
                                                            File videoFile =
                                                                File(filePath);
                                                            if (await videoFile
                                                                .exists()) {
                                                              Get.to(() =>
                                                                  PlayerLocalScreen(
                                                                    title:
                                                                        videoTitle,
                                                                    videoUrl:
                                                                        videoFile,
                                                                  ));
                                                            } else {
                                                              showMeesage(
                                                                title:
                                                                    'الملف غير موجود محليًا',
                                                                // subTitle:
                                                                //     'الملف غير موجود محليًا',
                                                                isError: true,
                                                              );
                                                            }
                                                          } else {
                                                            if (SharedPrefController()
                                                                .name
                                                                .isEmpty) {
                                                              SharedPrefController()
                                                                  .clear();
                                                              if (!kIsWeb) {
                                                                DatabaseHelper
                                                                    .instance
                                                                    .clearDatabase();
                                                              }
                                                              Future.delayed(
                                                                  const Duration(
                                                                      milliseconds:
                                                                          1),
                                                                  () {
                                                                Get.offAll(() =>
                                                                    const SplashScreen());
                                                                showMeesage(
                                                                    title:
                                                                        'انتهت الجلسة',
                                                                    // subTitle:
                                                                    //     'تم انتهاء الجلسة الخاصة بك',
                                                                    isError:
                                                                        true);
                                                              });
                                                              return;
                                                            }

                                                            homeGetxController
                                                                .changeSelectedSeriesEpisodesIndex(
                                                                    index);

                                                            final url =
                                                                contentPlaybackUrl(
                                                              contentId:
                                                                  episodeId,
                                                              type: 'series',
                                                              extension:
                                                                  containerExtension,
                                                            );

                                                            downloadController
                                                                .addToDownloadQueue(
                                                              url: url,
                                                              isSeries: true,
                                                              seriesName:
                                                                  widget.name,
                                                              name: videoTitle,
                                                            );
                                                            // تحديث الواجهة فورًا
                                                            downloadController
                                                                .downloadingFileName
                                                                .value = videoTitle;
                                                            downloadController
                                                                .isDownloading
                                                                .value = true;
                                                            Future.delayed(
                                                                Duration.zero,
                                                                () {
                                                              downloadController
                                                                  .update();
                                                              setState(() {});
                                                            });
                                                          }
                                                        },
                                                  color: isDownloaded
                                                      ? AppColors.subPrimryColor
                                                      : AppColors.greenColor,
                                                  height: 40,
                                                  width: 120,
                                                  child: Text(
                                                    isDownloading
                                                        ? '${progress.toStringAsFixed(0)} %'
                                                        : isInQueue
                                                            ? 'انتظار التحميل'
                                                            : isDownloaded
                                                                ? 'مشاهدة'
                                                                : 'تحميل',
                                                    style: AppStyles().font14(
                                                        color: isDownloading ||
                                                                isInQueue
                                                            ? AppColors
                                                                .blackColor
                                                            : AppColors
                                                                .whiteColor),
                                                  ),
                                                );
                                              }),
                                            ),
                                          if (!kIsWeb &&
                                              downloadController != null)
                                            Obx(() {
                                              if (downloadController
                                                      .isDownloading.value &&
                                                  downloadController
                                                          .name ==
                                                      videoTitle) {
                                                return Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    IconButton(
                                                      onPressed: () {
                                                        downloadController
                                                            .togglePauseResumeDownload(
                                                                videoTitle);
                                                      },
                                                      icon: downloadController
                                                              .isDownloadPaused
                                                              .value
                                                          ? const Icon(
                                                              Icons.play_arrow)
                                                          : const Icon(
                                                              Icons.pause),
                                                    ),
                                                    IconButton(
                                                      onPressed: () {
                                                        downloadController
                                                            .cancelDownload(
                                                                videoTitle);
                                                      },
                                                      icon: const Icon(
                                                          Icons.close),
                                                    ),
                                                  ],
                                                );
                                              } else {
                                                return const SizedBox();
                                              }
                                            }),
                                        ],
                                      ),
                                    );
                                  }),
                          ),
                        )
                      ],
                    );
                  } else {
                    return const SizedBox();
                  }
                })
              ],
            ),
          ),
        ),
      ],
    );
  }

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

  int convertTimeToSeconds(String time) {
    List<String> timeParts = time.split(':');
    int hours = int.parse(timeParts[0]);
    int minutes = int.parse(timeParts[1]);
    int seconds = int.parse(timeParts[2]);
    return (hours * 3600) + (minutes * 60) + seconds;
  }

  Widget buildWatchedProgressDivider(String? videoId) {
    if (videoId == null) return const SizedBox();
    return FutureBuilder<Map<String, int?>>(
      future: _getLastWatchedPosition(videoId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: 0,
                minHeight: 3,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.subPrimryColor),
              ),
            ],
          );
        }

        if (snapshot.hasData) {
          int watchedPosition = snapshot.data?['watched_duration'] ?? 0;
          int totalDuration = snapshot.data?['total_duration'] ?? 0;
          double watchedPercentage =
              totalDuration > 0 ? watchedPosition / totalDuration : 0;
          watchedPercentage = watchedPercentage.clamp(0.0, 1.0);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: watchedPercentage,
                minHeight: 3,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.subPrimryColor),
              ),
            ],
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
