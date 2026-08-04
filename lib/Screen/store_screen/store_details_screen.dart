import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iptv/Screen/player_screen/player__local_screen.dart';
import 'package:iptv/Screen/player_screen/player_screen.dart';
import 'package:iptv/Widget/button_widget.dart';
import 'package:iptv/app_material/app_colors.dart';
import 'package:iptv/app_material/app_styles.dart';
import 'package:iptv/controller/download_getx_controller.dart';
import 'package:iptv/controller/home_getx_controller.dart';
import 'package:iptv/model/courses_model.dart';
import 'dart:math' as math;

import 'package:iptv/utils/app_helper.dart';

class StoreDetailsScreen extends StatefulWidget {
  final String image;
  final Results result;
  const StoreDetailsScreen({
    super.key,
    required this.image,
    required this.result,
  });

  @override
  State<StoreDetailsScreen> createState() => _StoreDetailsScreenState();
}

class _StoreDetailsScreenState extends State<StoreDetailsScreen>
    with AppHelper {
  var selectedUnit = 0;
  var selectedCourse = 0;

  DownloadGetxController downloadGetxController =
      Get.put(DownloadGetxController());
  HomeGetxController homeGetxController = Get.put(HomeGetxController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
              flex: 2,
              child: Image.network(
                widget.image,
                fit: BoxFit.fill,
                height: Get.height,
              )),
          Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          widget.result.nameAr ?? '',
                          style: AppStyles().font20(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primryColor,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Column(
                          children: [
                            Column(
                              children: [
                                if (widget.result.units != null)
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'الوحدات : ',
                                            style: AppStyles().font16(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          SizedBox(
                                            height: 40,
                                            width: Get.width * 0.65,
                                            child: ListView.separated(
                                              scrollDirection: Axis.horizontal,
                                              itemCount:
                                                  widget.result.units?.length ??
                                                      0,
                                              separatorBuilder:
                                                  (context, index) {
                                                return const SizedBox(
                                                  width: 10,
                                                );
                                              },
                                              itemBuilder: (context, index) {
                                                return InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      selectedUnit = index;
                                                      selectedCourse = 0;
                                                    });
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10,
                                                        vertical: 8),
                                                    decoration: BoxDecoration(
                                                        color: selectedUnit ==
                                                                index
                                                            ? AppColors
                                                                .primryColor
                                                            : AppColors
                                                                .greysub4Color
                                                                .withValues(
                                                                    alpha: 0.6),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(100)),
                                                    child: Text(
                                                      widget
                                                              .result
                                                              .units![index]
                                                              .name ??
                                                          '',
                                                      style: AppStyles().font14(
                                                        color: selectedUnit ==
                                                                index
                                                            ? AppColors
                                                                .whiteColor
                                                            : AppColors
                                                                .blackColor,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Align(
                                  alignment: AlignmentDirectional.centerStart,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: List.generate(
                                        widget.result.units![selectedUnit]
                                                .classes?.length ??
                                            0, (index) {
                                      return Row(
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  selectedCourse = index;
                                                });
                                                Get.to(() => PlayerScreen(
                                                      title: widget
                                                              .result
                                                              .units![
                                                                  selectedUnit]
                                                              .classes![index]
                                                              .nameAr ??
                                                          '',
                                                      videoUrl: widget
                                                              .result
                                                              .units![
                                                                  selectedUnit]
                                                              .classes![index]
                                                              .downloadLink ??
                                                          '',
                                                    ));
                                              },
                                              child: Container(
                                                alignment: AlignmentDirectional
                                                    .centerStart,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20,
                                                        vertical: 10),
                                                margin:
                                                    const EdgeInsetsDirectional
                                                        .only(
                                                  start: 5,
                                                  top: 4,
                                                  bottom: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: selectedCourse == index
                                                      ? AppColors.primryColor
                                                      : AppColors.greysub4Color
                                                          .withValues(
                                                              alpha: 0.6),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                ),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        SizedBox(
                                                          width:
                                                              Get.width * 0.2,
                                                          child: Text(
                                                            widget
                                                                    .result
                                                                    .units![
                                                                        selectedUnit]
                                                                    .classes![
                                                                        index]
                                                                    .nameAr ??
                                                                '',
                                                            style: AppStyles()
                                                                .font14(
                                                              color: selectedCourse ==
                                                                      index
                                                                  ? AppColors
                                                                      .whiteColor
                                                                  : AppColors
                                                                      .blackColor,
                                                            ),
                                                          ),
                                                        ),
                                                        Transform(
                                                          alignment:
                                                              Alignment.center,
                                                          transform: Matrix4
                                                              .rotationY(math
                                                                  .pi), // تدور لليمين
                                                          child: Icon(
                                                            Icons.play_arrow,
                                                            color: selectedCourse == index
                                                                ? const Color.fromARGB(255, 2, 1, 1)
                                                                : AppColors
                                                                    .blackColor
                                                                    .withValues(
                                                                        alpha:
                                                                            0.6),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 15,
                                          ),
                                          const SizedBox(
                                            width: 15,
                                          ),
                                          // if (operatorModel?.type == 'private' ||
                                          //     (operatorModel?.type == 'operator' &&
                                          //         SharedPrefController().operator ==
                                          //             '1'))
                                          // if (Platform.isAndroid)
                                          Expanded(
                                            child: ButtonWidget(
                                              onPressed: (downloadGetxController
                                                              .isDownloading
                                                              .value &&
                                                          downloadGetxController
                                                                  .name ==
                                                              widget
                                                                  .result
                                                                  .units![
                                                                      selectedUnit]
                                                                  .classes![
                                                                      index]
                                                                  .nameAr) ||
                                                      (downloadGetxController
                                                          .isInQueue(widget
                                                                  .result
                                                                  .units![
                                                                      selectedUnit]
                                                                  .classes![
                                                                      index]
                                                                  .nameAr ??
                                                              ''))
                                                  ? null
                                                  : () {
                                                      if (downloadGetxController
                                                              .isDownloading
                                                              .value &&
                                                          downloadGetxController
                                                                  .name ==
                                                              widget
                                                                  .result
                                                                  .units![
                                                                      selectedUnit]
                                                                  .classes![
                                                                      index]
                                                                  .nameAr) {
                                                        return; // إذا كان الفيديو قيد التنزيل، لا تفعل شيئًا
                                                      }

                                                      String videoTitle = widget
                                                              .result
                                                              .units![
                                                                  selectedUnit]
                                                              .classes![index]
                                                              .nameAr ??
                                                          '';

                                                      bool isDownloaded =
                                                          downloadGetxController
                                                              .isVideoDownloaded(
                                                                  videoTitle);

                                                      if (isDownloaded) {
                                                        Get.to(() =>
                                                            PlayerLocalScreen(
                                                              title: videoTitle,
                                                              videoUrl: File(
                                                                  '/storage/emulated/0/Download/Stream Live/$videoTitle.mp4'),
                                                            ));
                                                      } else {
                                                        homeGetxController
                                                            .changeSelectedSeriesEpisodesIndex(
                                                                index);

                                                        String url = widget
                                                                .result
                                                                .units![
                                                                    selectedUnit]
                                                                .classes![index]
                                                                .downloadLink ??
                                                            '';

                                                        downloadGetxController
                                                            .addToDownloadQueue(
                                                                isStore: true,
                                                                url: url,
                                                                isSeries: false,
                                                                name:
                                                                    videoTitle);
                                                      }
                                                    },
                                              color: downloadGetxController
                                                      .isVideoDownloaded(widget
                                                              .result
                                                              .units![
                                                                  selectedUnit]
                                                              .classes![index]
                                                              .nameAr ??
                                                          '')
                                                  ? AppColors.subPrimryColor
                                                  : AppColors.greenColor,
                                              height: 40,
                                              width: 120,
                                              child: Obx(() {
                                                String videoTitle = widget
                                                        .result
                                                        .units![selectedUnit]
                                                        .classes![index]
                                                        .nameAr ??
                                                    '';

                                                bool isDownloading =
                                                    downloadGetxController
                                                            .isDownloading
                                                            .value &&
                                                        downloadGetxController
                                                                .name ==
                                                            videoTitle;

                                                bool isInQueue =
                                                    downloadGetxController
                                                        .isInQueue(videoTitle);
                                                bool isDownloaded =
                                                    downloadGetxController
                                                        .isVideoDownloaded(
                                                            videoTitle);
                                                int progress = isDownloading
                                                    ? downloadGetxController
                                                        .progres.value
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
                                                      color: isDownloading ||
                                                              isInQueue
                                                          ? AppColors.blackColor
                                                          : AppColors
                                                              .whiteColor),
                                                );
                                              }),
                                            ),
                                          ),

                                          Obx(() {
                                            if (downloadGetxController
                                                    .isDownloading.value &&
                                                downloadGetxController.name ==
                                                    widget
                                                        .result
                                                        .units![selectedUnit]
                                                        .classes![index]
                                                        .nameAr) {
                                              return Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    onPressed: () {
                                                      downloadGetxController
                                                          .togglePauseResumeDownload(
                                                              downloadGetxController
                                                                  .downloadingFileName
                                                                  .value);
                                                    },
                                                    icon: downloadGetxController
                                                            .isDownloadPaused
                                                            .value
                                                        ? const Icon(
                                                            Icons.play_arrow)
                                                        : const Icon(
                                                            Icons.pause),
                                                  ),
                                                  IconButton(
                                                    onPressed: () {
                                                      downloadGetxController
                                                          .cancelDownload(
                                                              downloadGetxController
                                                                  .downloadingFileName
                                                                  .value);
                                                    },
                                                    icon:
                                                        const Icon(Icons.close),
                                                  ),
                                                ],
                                              );
                                            } else {
                                              return const SizedBox();
                                            }
                                          }),

                                          // if (operatorModel?.type == 'private' ||
                                          //     (operatorModel?.type == 'operator' &&
                                          //         SharedPrefController().operator ==
                                          //             '1'))
                                          // if (Platform.isAndroid)
                                          //   Expanded(
                                          //     child: Obx(() {
                                          //       return ButtonWidget(
                                          //         onPressed:
                                          //             downloadGetxController.isVideoDownloaded(homeGetxController
                                          //                     .seriesDetails
                                          //                     ?.episodes
                                          //                     ?.countsBySeason
                                          //                     ?.entries
                                          //                     .elementAt(
                                          //                         homeGetxController
                                          //                             .selectedSeriesSesonIndex
                                          //                             .value)
                                          //                     .value
                                          //                     .elementAt(
                                          //                         index)
                                          //                     .title)
                                          //                 ? () {
                                          //                     Get.to(() => PlayerLocalScreen(
                                          //                         title: homeGetxController
                                          //                             .seriesDetails
                                          //                             ?.episodes
                                          //                             ?.countsBySeason
                                          //                             ?.entries
                                          //                             .elementAt(homeGetxController
                                          //                                 .selectedSeriesSesonIndex
                                          //                                 .value)
                                          //                             .value
                                          //                             .elementAt(
                                          //                                 index)
                                          //                             .title,
                                          //                         videoUrl: File(
                                          //                             '/storage/emulated/0/Download/Stream Live/${widget.name}/${homeGetxController.seriesDetails?.episodes?.countsBySeason?.entries.elementAt(homeGetxController.selectedSeriesSesonIndex.value).value.elementAt(index).title}.${homeGetxController.seriesDetails?.episodes?.countsBySeason?.entries.elementAt(homeGetxController.selectedSeriesSesonIndex.value).value.elementAt(index).containerExtension}')));
                                          //                   }
                                          //                 : downloadGetxController
                                          //                                 .progres
                                          //                                 .value >
                                          //                             0 ||
                                          //                         downloadGetxController
                                          //                             .isDownloading
                                          //                             .value
                                          //                     ? null
                                          //                     : !downloadGetxController.isVideoDownloaded(homeGetxController
                                          //                             .seriesDetails
                                          //                             ?.episodes
                                          //                             ?.countsBySeason
                                          //                             ?.entries
                                          //                             .elementAt(homeGetxController
                                          //                                 .selectedSeriesSesonIndex
                                          //                                 .value)
                                          //                             .value
                                          //                             .elementAt(
                                          //                                 index)
                                          //                             .title)
                                          //                         ? () {
                                          //                             if (SharedPrefController()
                                          //                                 .name
                                          //                                 .isEmpty) {
                                          //                               SharedPrefController()
                                          //                                   .clear();
                                          //                               DatabaseHelper
                                          //                                   .instance
                                          //                                   .clearDatabase();
                                          //                               Future
                                          //                                   .delayed(
                                          //                                 const Duration(milliseconds: 1),
                                          //                                 () {
                                          //                                   Get.offAll(() => const SplashScreen());
                                          //                                   showMeesage(
                                          //                                     title: 'انتهت الجلسة',
                                          //                                     subTitle: 'تم انتهاء الجلسة الخاصة بك',
                                          //                                     isError: true,
                                          //                                   );
                                          //                                 },
                                          //                               );
                                          //                               return;
                                          //                             }
                                          //                             // حفظ الحلقة المُختارة
                                          //                             homeGetxController
                                          //                                 .changeSelectedSeriesEpisodesIndex(index);
                                          //                             String
                                          //                                 url =
                                          //                                 '${ApiSettings.channelUrl.replaceAll('live', 'series').replaceAll('ThePassword', SharedPrefController().password).replaceAll('theName', SharedPrefController().name).replaceAll('dynamicBaseUrl', '${SharedPrefController().serverProtocol}://${SharedPrefController().url}:${SharedPrefController().serverProtocol == 'http' ? SharedPrefController().port : SharedPrefController().httpsPort}/')}${homeGetxController.seriesDetails?.episodes?.countsBySeason?.entries.elementAt(homeGetxController.selectedSeriesSesonIndex.value).value.elementAt(index).id}.${homeGetxController.seriesDetails?.episodes?.countsBySeason?.entries.elementAt(homeGetxController.selectedSeriesSesonIndex.value).value.elementAt(index).containerExtension}';

                                          //                             // بدء تحميل الحلقة
                                          //                             downloadGetxController
                                          //                                 .startDownload(
                                          //                               url:
                                          //                                   url,
                                          //                               isSeries:
                                          //                                   true,
                                          //                               seriesName:
                                          //                                   widget.name,
                                          //                               name: homeGetxController.seriesDetails?.episodes?.countsBySeason?.entries.elementAt(homeGetxController.selectedSeriesSesonIndex.value).value.elementAt(index).title ??
                                          //                                   'Series Name',
                                          //                             );
                                          //                           }
                                          //                         : () {
                                          //                             Get.to(() => PlayerLocalScreen(
                                          //                                 title:
                                          //                                     homeGetxController.seriesDetails?.episodes?.countsBySeason?.entries.elementAt(homeGetxController.selectedSeriesSesonIndex.value).value.elementAt(index).title,
                                          //                                 videoUrl: File('/storage/emulated/0/Download/Stream Live/${widget.name}/${homeGetxController.seriesDetails?.episodes?.countsBySeason?.entries.elementAt(homeGetxController.selectedSeriesSesonIndex.value).value.elementAt(index).title}.${homeGetxController.seriesDetails?.episodes?.countsBySeason?.entries.elementAt(homeGetxController.selectedSeriesSesonIndex.value).value.elementAt(index).containerExtension}')));
                                          //                           },
                                          //         color: !downloadGetxController
                                          //                 .isVideoDownloaded(homeGetxController
                                          //                     .seriesDetails
                                          //                     ?.episodes
                                          //                     ?.countsBySeason
                                          //                     ?.entries
                                          //                     .elementAt(
                                          //                         homeGetxController
                                          //                             .selectedSeriesSesonIndex
                                          //                             .value)
                                          //                     .value
                                          //                     .elementAt(
                                          //                         index)
                                          //                     .title)
                                          //             ? AppColors.greenColor
                                          //             : AppColors
                                          //                 .subPrimryColor,
                                          //         height: 40,
                                          //         width: 120,
                                          //         child: Obx(() {
                                          //           return Text(
                                          //             !downloadGetxController.isVideoDownloaded(homeGetxController
                                          //                     .seriesDetails
                                          //                     ?.episodes
                                          //                     ?.countsBySeason
                                          //                     ?.entries
                                          //                     .elementAt(
                                          //                         homeGetxController
                                          //                             .selectedSeriesSesonIndex
                                          //                             .value)
                                          //                     .value
                                          //                     .elementAt(
                                          //                         index)
                                          //                     .title)
                                          //                 ? (downloadGetxController.progres.value >
                                          //                                 0 ||
                                          //                             downloadGetxController
                                          //                                 .isDownloading
                                          //                                 .value) &&
                                          //                         downloadGetxController
                                          //                                 .name ==
                                          //                             homeGetxController
                                          //                                 .seriesDetails
                                          //                                 ?.episodes
                                          //                                 ?.countsBySeason
                                          //                                 ?.entries
                                          //                                 .elementAt(homeGetxController.selectedSeriesSesonIndex.value)
                                          //                                 .value
                                          //                                 .elementAt(index)
                                          //                                 .title
                                          //                     ? '${downloadGetxController.progres.value} %'
                                          //                     : 'تحميل'
                                          //                 : 'مشاهدة',
                                          //             style:
                                          //                 AppStyles().font14(
                                          //               color: AppColors
                                          //                   .whiteColor,
                                          //             ),
                                          //           );
                                          //         }),
                                          //       );
                                          //     }),
                                          //   ),

                                          // if ((downloadGetxController
                                          //                 .progres.value >
                                          //             0 ||
                                          //         downloadGetxController
                                          //             .isDownloading.value) &&
                                          //     downloadGetxController.name ==
                                          //         homeGetxController
                                          //             .seriesDetails
                                          //             ?.episodes
                                          //             ?.countsBySeason
                                          //             ?.entries
                                          //             .elementAt(
                                          //                 homeGetxController
                                          //                     .selectedSeriesSesonIndex
                                          //                     .value)
                                          //             .value
                                          //             .elementAt(index)
                                          //             .title)
                                          // Obx(() {
                                          //   return Row(
                                          //     mainAxisSize:
                                          //         MainAxisSize.min,
                                          //     children: [
                                          //       IconButton(
                                          //           onPressed: () {
                                          //             downloadGetxController
                                          //                 .togglePauseResumeDownload(
                                          //                     downloadGetxController
                                          //                         .downloadingFileName
                                          //                         .value);
                                          //           },
                                          //           icon: downloadGetxController
                                          //                   .isDownloadPaused
                                          //                   .value
                                          //               ? const Icon(Icons
                                          //                   .play_arrow)
                                          //               : const Icon(
                                          //                   Icons.pause)),
                                          //       IconButton(
                                          //           onPressed: () {},
                                          //           icon: const Icon(
                                          //               Icons.close)),
                                          //     ],
                                          //   );
                                          // })
                                        ],
                                      );
                                    }),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ]),
                ),
              ))
        ],
      ),
    );
  }
}
