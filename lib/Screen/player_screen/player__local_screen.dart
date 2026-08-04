import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iptv/api/api_helper.dart';
import 'package:iptv/app_material/app_colors.dart';
import 'package:iptv/app_material/app_styles.dart';
import 'package:iptv/controller/home_getx_controller.dart';
import 'package:iptv/model/series_details_model.dart';
import 'package:iptv/utils/app_helper.dart';
import 'package:video_player/video_player.dart';

class PlayerLocalScreen extends StatefulWidget {
  final File videoUrl;
  final String title;
  final List<Counts>? episodes;

  const PlayerLocalScreen({
    super.key,
    required this.videoUrl,
    required this.title,
    this.episodes,
  });

  @override
  _PlayerLocalScreenState createState() => _PlayerLocalScreenState();
}

class _PlayerLocalScreenState extends State<PlayerLocalScreen>
    with ApiHelper, AppHelper {
  late VideoPlayerController _controller;
  bool _showControls = false;
  bool showEpisodes = false;
  bool showLoading = false;
  bool isBuffering = false;
  HomeGetxController homeGetxController = Get.find();
  Timer? _hideControlsTimer;
  Timer? _rewindTimer;
  bool onPreviousLongPressed = false;
  bool onNextLongPressed = false;
  bool showForwardAndBackward = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _controller.addListener(() {
          if (_controller.value.isBuffering) {
            setState(() {
              isBuffering = true;
            });
          } else {
            setState(() {
              isBuffering = false;
            });
          }
          if (_controller.value.position == _controller.value.duration) {
            setState(() {}); // Update the icon to replay when video ends
          }
        });
      }).catchError((error) {
        print("Error initializing video player: $error");
      });
  }

  @override
  void dispose() {
    _showControls = false;
    _controller.dispose();
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });

    _hideControlsTimer?.cancel();

    _hideControlsTimer = Timer(const Duration(seconds: 10), () {
      if (_showControls) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _togglePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      if (_controller.value.position == _controller.value.duration) {
        _controller.seekTo(Duration.zero);
      }
      _controller.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackColor,
      body: KeyboardListener(
        focusNode:
            FocusNode(), // A FocusNode is required to capture key events.
        onKeyEvent: (event) {
          _handleKeyEvent(event);
        },
        child: GestureDetector(
          onDoubleTap: () {
            setState(() {
              showEpisodes = !showEpisodes;
            });
          },
          onTap: _toggleControls,
          child: Center(
            child: _controller.value.isInitialized
                ? Stack(
                    children: [
                      Positioned.fill(
                        child: AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        ),
                      ),

                      // long click
                      Positioned(
                          left: 0,
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: Row(
                            children: [
                              GestureDetector(
                                  onLongPressStart: (details) =>
                                      onPreviousLongPressedStart(),
                                  onLongPressEnd: (details) =>
                                      onPreviousLongPressedEnd(),
                                  child: Container(
                                    width: Get.width * 0.5,
                                    height: Get.height,
                                    color: AppColors.redColor.withValues(alpha: 0.0),
                                    child: Center(
                                      child: Visibility(
                                          visible: onPreviousLongPressed,
                                          child: const Icon(
                                            Icons.fast_forward,
                                            color: AppColors.whiteColor,
                                            size: 55,
                                          )),
                                    ),
                                  )),
                              GestureDetector(
                                  onLongPressStart: (details) =>
                                      onNextLongPressedStart(),
                                  onLongPressEnd: (details) =>
                                      onNextLongPressedEnd(),
                                  child: Container(
                                    width: Get.width * 0.5,
                                    color:
                                        AppColors.greenColor.withValues(alpha: 0.0),
                                    child: Center(
                                      child: Visibility(
                                          visible: onNextLongPressed,
                                          child: const Icon(
                                            Icons.fast_rewind,
                                            color: AppColors.whiteColor,
                                            size: 55,
                                          )),
                                    ),
                                  )),
                            ],
                          )),

                      // if (showEpisodes)
                      //   Positioned(
                      //     right: 0,
                      //     top: 30,
                      //     bottom: 0,
                      //     // left: Get.width * 0.3,
                      //     child: SingleChildScrollView(
                      //       child: Column(
                      //         crossAxisAlignment: CrossAxisAlignment.start,
                      //         children: List.generate(
                      //             widget.episodes?.length ?? 0, (index) {
                      //           return InkWell(
                      //             onTap: homeGetxController
                      //                         .selectedSeriesEpisodesIndex
                      //                         .value !=
                      //                     index
                      //                 ? () {
                      //                     if (SharedPrefController()
                      //                         .name
                      //                         .isEmpty) {
                      //                       SharedPrefController().clear();
                      //                       DatabaseHelper.instance
                      //                           .clearDatabase();
                      //                       Future.delayed(
                      //                         const Duration(milliseconds: 1),
                      //                         () {
                      //                           Get.offAll(
                      //                               () => const LoginScreen());
                      //                           showMeesage(
                      //                             title: 'انتهت الجلسة',
                      //                             subTitle:
                      //                                 'تم انتهاء الجلسة الخاصة بك',
                      //                             isError: true,
                      //                           );
                      //                         },
                      //                       );

                      //                       return;
                      //                     }
                      //                     // homeGetxController
                      //                     //     .changeSelectedSeriesEpisodesIndex(
                      //                     //         index);
                      //                     // String url = widget.videoUrl.replaceAll(
                      //                     //     widget.videoUrl.split('/').last,
                      //                     //     '${widget.episodes?[index].id}.mp4');

                      //                     // '${ApiSettings.channelUrl.replaceAll('live', 'series').replaceAll('ThePassword', SharedPrefController().password).replaceAll('theName', SharedPrefController().name).replaceAll('dynamicBaseUrl', '${SharedPrefController().serverProtocol}://${SharedPrefController().url}:${SharedPrefController().serverProtocol == 'http' ? SharedPrefController().port : SharedPrefController().httpsPort}/')}${homeGetxController.seriesDetails?.episodes?.countsBySeason?.entries.elementAt(homeGetxController.selectedSeriesSesonIndex.value).value.elementAt(index).id}.mp4';
                      //                     // setState(() {
                      //                     //   _showControls = false;
                      //                     // });

                      //                     Navigator.pushReplacement(context,
                      //                         MaterialPageRoute(
                      //                       builder: (context) {
                      //                         return PlayerScreen(
                      //                           videoUrl: url,
                      //                           episodes: homeGetxController
                      //                               .seriesDetails
                      //                               ?.episodes
                      //                               ?.countsBySeason
                      //                               ?.entries
                      //                               .elementAt(homeGetxController
                      //                                   .selectedSeriesSesonIndex
                      //                                   .value)
                      //                               .value,
                      //                           title: widget.title,
                      //                           // 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4'
                      //                           // duration: parseDuration(homeGetxController
                      //                           //         .seriesDetails
                      //                           //         ?.episodes
                      //                           //         ?.countsBySeason
                      //                           //         ?.entries
                      //                           //         .elementAt(homeGetxController
                      //                           //             .selectedSeriesSesonIndex
                      //                           //             .value)
                      //                           //         .value
                      //                           //         .elementAt(index)
                      //                           //         .info!
                      //                           //         .duration ??
                      //                           //     '00:00:00'),
                      //                         );
                      //                       },
                      //                     ));
                      //                     // Get.off(() => PlayerScreen(
                      //                     //       videoUrl: url,
                      //                     //       episodes: homeGetxController
                      //                     //           .seriesDetails
                      //                     //           ?.episodes
                      //                     //           ?.countsBySeason
                      //                     //           ?.entries
                      //                     //           .elementAt(homeGetxController
                      //                     //               .selectedSeriesSesonIndex
                      //                     //               .value)
                      //                     //           .value,
                      //                     //       // 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4'
                      //                     //       // duration: parseDuration(homeGetxController
                      //                     //       //         .seriesDetails
                      //                     //       //         ?.episodes
                      //                     //       //         ?.countsBySeason
                      //                     //       //         ?.entries
                      //                     //       //         .elementAt(homeGetxController
                      //                     //       //             .selectedSeriesSesonIndex
                      //                     //       //             .value)
                      //                     //       //         .value
                      //                     //       //         .elementAt(index)
                      //                     //       //         .info!
                      //                     //       //         .duration ??
                      //                     //       //     '00:00:00'),
                      //                     //     ));
                      //                   }
                      //                 : null,
                      //             child: Container(
                      //               alignment: AlignmentDirectional.centerStart,
                      //               padding: const EdgeInsets.symmetric(
                      //                   horizontal: 20, vertical: 10),
                      //               margin: const EdgeInsetsDirectional.only(
                      //                 start: 5,
                      //                 top: 4,
                      //                 bottom: 4,
                      //               ),
                      //               decoration: BoxDecoration(
                      //                 color: homeGetxController
                      //                             .selectedSeriesEpisodesIndex
                      //                             .value ==
                      //                         index
                      //                     ? AppColors.primryColor
                      //                     : AppColors.greysub4Color
                      //                         .withValues(alpha: 0.6),
                      //                 borderRadius: BorderRadius.circular(100),
                      //               ),
                      //               child: Row(
                      //                 mainAxisAlignment:
                      //                     MainAxisAlignment.spaceBetween,
                      //                 children: [
                      //                   if (homeGetxController
                      //                               .seriesDetails
                      //                               ?.episodes
                      //                               ?.countsBySeason
                      //                               ?.entries
                      //                               .elementAt(homeGetxController
                      //                                   .selectedSeriesSesonIndex
                      //                                   .value)
                      //                               .value
                      //                               .elementAt(index)
                      //                               .info!
                      //                               .movieImage !=
                      //                           null &&
                      //                       homeGetxController
                      //                           .seriesDetails!
                      //                           .episodes!
                      //                           .countsBySeason!
                      //                           .entries
                      //                           .elementAt(homeGetxController
                      //                               .selectedSeriesSesonIndex
                      //                               .value)
                      //                           .value
                      //                           .elementAt(index)
                      //                           .info!
                      //                           .movieImage!
                      //                           .isNotEmpty)
                      //                     ClipRRect(
                      //                       borderRadius:
                      //                           BorderRadius.circular(8),
                      //                       child: Image.network(
                      //                         homeGetxController
                      //                             .seriesDetails!
                      //                             .episodes!
                      //                             .countsBySeason!
                      //                             .entries
                      //                             .elementAt(homeGetxController
                      //                                 .selectedSeriesSesonIndex
                      //                                 .value)
                      //                             .value
                      //                             .elementAt(index)
                      //                             .info!
                      //                             .movieImage!,
                      //                         height: 40,
                      //                         width: 50,
                      //                       ),
                      //                     ),
                      //                   const SizedBox(
                      //                     width: 10,
                      //                   ),
                      //                   SizedBox(
                      //                     width: Get.width * 0.2,
                      //                     child: Text(
                      //                       homeGetxController
                      //                               .seriesDetails
                      //                               ?.episodes
                      //                               ?.countsBySeason
                      //                               ?.entries
                      //                               .elementAt(homeGetxController
                      //                                   .selectedSeriesSesonIndex
                      //                                   .value)
                      //                               .value
                      //                               .elementAt(index)
                      //                               .title ??
                      //                           '',
                      //                       style: AppStyles().font14(
                      //                         color: homeGetxController
                      //                                     .selectedSeriesEpisodesIndex
                      //                                     .value ==
                      //                                 index
                      //                             ? AppColors.whiteColor
                      //                             : AppColors.blackColor,
                      //                       ),
                      //                     ),
                      //                   ),
                      //                   Transform(
                      //                     alignment: Alignment.center,
                      //                     transform: Matrix4.rotationY(
                      //                         math.pi), // تدور لليمين
                      //                     child: Icon(
                      //                       Icons.play_arrow,
                      //                       color: homeGetxController
                      //                                   .selectedSeriesEpisodesIndex
                      //                                   .value ==
                      //                               index
                      //                           ? AppColors.whiteColor
                      //                           : AppColors.blackColor
                      //                               .withValues(alpha: 0.6),
                      //                     ),
                      //                   )
                      //                 ],
                      //               ),
                      //             ),
                      //           );
                      //         }),
                      //       ),
                      //     ),
                      //   ),

                      if (_showControls)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: VideoControls(
                            controller: _controller,
                            onPlayPause: _togglePlayPause,
                            onMenuPressed:
                                // widget.episodes != null &&
                                //         widget.episodes!.isNotEmpty
                                //     ? () {
                                //         setState(() {
                                //           showEpisodes = !showEpisodes;
                                //           _showControls = false;
                                //         });
                                //       }
                                //     :
                                null,
                            onNextPressed:
                                //  widget.episodes != null &&
                                //         widget.episodes!.isNotEmpty
                                //     ? () async {
                                //         if (homeGetxController
                                //                 .selectedSeriesEpisodesIndex.value <
                                //             widget.episodes!.length - 1) {
                                //           if (SharedPrefController().name.isEmpty) {
                                //             SharedPrefController().clear();
                                //             DatabaseHelper.instance.clearDatabase();
                                //             Future.delayed(
                                //               const Duration(milliseconds: 1),
                                //               () {
                                //                 Get.offAll(
                                //                     () => const LoginScreen());
                                //                 showMeesage(
                                //                   title: 'انتهت الجلسة',
                                //                   subTitle:
                                //                       'تم انتهاء الجلسة الخاصة بك',
                                //                   isError: true,
                                //                 );
                                //               },
                                //             );

                                //             return;
                                //           }
                                //           setState(() {
                                //             _showControls = false;
                                //             showLoading = true;
                                //           });
                                //           int nextIndex = homeGetxController
                                //                   .selectedSeriesEpisodesIndex
                                //                   .value +
                                //               1;
                                //           homeGetxController
                                //               .changeSelectedSeriesEpisodesIndex(
                                //                   nextIndex);
                                //           String url = widget.videoUrl.replaceAll(
                                //               widget.videoUrl.split('/').last,
                                //               '${widget.episodes?[nextIndex].id}.mp4');

                                //           // '${ApiSettings.channelUrl.replaceAll('live', 'series').replaceAll('ThePassword', SharedPrefController().password).replaceAll('theName', SharedPrefController().name).replaceAll('dynamicBaseUrl', '${SharedPrefController().serverProtocol}://${SharedPrefController().url}:${SharedPrefController().serverProtocol == 'http' ? SharedPrefController().port : SharedPrefController().httpsPort}/')}${homeGetxController.seriesDetails?.episodes?.countsBySeason?.entries.elementAt(homeGetxController.selectedSeriesSesonIndex.value).value.elementAt(index).id}.mp4';
                                //           await Future.delayed(
                                //               const Duration(seconds: 3));
                                //           Navigator.pushReplacement(context,
                                //               MaterialPageRoute(
                                //             builder: (context) {
                                //               return PlayerScreen(
                                //                 videoUrl: url,
                                //                 episodes: homeGetxController
                                //                     .seriesDetails
                                //                     ?.episodes
                                //                     ?.countsBySeason
                                //                     ?.entries
                                //                     .elementAt(homeGetxController
                                //                         .selectedSeriesSesonIndex
                                //                         .value)
                                //                     .value,
                                //                 title: widget.title,

                                //                 // 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4'
                                //                 // duration: parseDuration(homeGetxController
                                //                 //         .seriesDetails
                                //                 //         ?.episodes
                                //                 //         ?.countsBySeason
                                //                 //         ?.entries
                                //                 //         .elementAt(homeGetxController
                                //                 //             .selectedSeriesSesonIndex
                                //                 //             .value)
                                //                 //         .value
                                //                 //         .elementAt(index)
                                //                 //         .info!
                                //                 //         .duration ??
                                //                 //     '00:00:00'),
                                //               );
                                //             },
                                //           ));
                                //           // Get.off(() => PlayerScreen(
                                //           //       videoUrl: url,
                                //           //       episodes: homeGetxController
                                //           //           .seriesDetails
                                //           //           ?.episodes
                                //           //           ?.countsBySeason
                                //           //           ?.entries
                                //           //           .elementAt(homeGetxController
                                //           //               .selectedSeriesSesonIndex
                                //           //               .value)
                                //           //           .value,
                                //           //       // 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4'
                                //           //       // duration: parseDuration(homeGetxController
                                //           //       //         .seriesDetails
                                //           //       //         ?.episodes
                                //           //       //         ?.countsBySeason
                                //           //       //         ?.entries
                                //           //       //         .elementAt(homeGetxController
                                //           //       //             .selectedSeriesSesonIndex
                                //           //       //             .value)
                                //           //       //         .value
                                //           //       //         .elementAt(index)
                                //           //       //         .info!
                                //           //       //         .duration ??
                                //           //       //     '00:00:00'),
                                //           //     ));
                                //         }
                                //       }
                                //     : null,
                                // onPreviousPressed: widget.episodes != null &&
                                //         widget.episodes!.isNotEmpty
                                //     ? () async {
                                //         if (homeGetxController
                                //                 .selectedSeriesEpisodesIndex.value >
                                //             0) {
                                //           if (SharedPrefController().name.isEmpty) {
                                //             SharedPrefController().clear();
                                //             DatabaseHelper.instance.clearDatabase();
                                //             Future.delayed(
                                //               const Duration(milliseconds: 1),
                                //               () {
                                //                 Get.offAll(
                                //                     () => const LoginScreen());
                                //                 showMeesage(
                                //                   title: 'انتهت الجلسة',
                                //                   subTitle:
                                //                       'تم انتهاء الجلسة الخاصة بك',
                                //                   isError: true,
                                //                 );
                                //               },
                                //             );

                                //             return;
                                //           }
                                //           setState(() {
                                //             _showControls = false;
                                //             showLoading = true;
                                //           });
                                //           int nextIndex = homeGetxController
                                //                   .selectedSeriesEpisodesIndex
                                //                   .value -
                                //               1;
                                //           homeGetxController
                                //               .changeSelectedSeriesEpisodesIndex(
                                //                   nextIndex);
                                //           String url = widget.videoUrl.replaceAll(
                                //               widget.videoUrl.split('/').last,
                                //               '${widget.episodes?[nextIndex].id}.mp4');

                                //           // '${ApiSettings.channelUrl.replaceAll('live', 'series').replaceAll('ThePassword', SharedPrefController().password).replaceAll('theName', SharedPrefController().name).replaceAll('dynamicBaseUrl', '${SharedPrefController().serverProtocol}://${SharedPrefController().url}:${SharedPrefController().serverProtocol == 'http' ? SharedPrefController().port : SharedPrefController().httpsPort}/')}${homeGetxController.seriesDetails?.episodes?.countsBySeason?.entries.elementAt(homeGetxController.selectedSeriesSesonIndex.value).value.elementAt(index).id}.mp4';
                                //           await Future.delayed(
                                //               const Duration(seconds: 3));
                                //           Navigator.pushReplacement(context,
                                //               MaterialPageRoute(
                                //             builder: (context) {
                                //               return PlayerScreen(
                                //                 videoUrl: url,
                                //                 episodes: homeGetxController
                                //                     .seriesDetails
                                //                     ?.episodes
                                //                     ?.countsBySeason
                                //                     ?.entries
                                //                     .elementAt(homeGetxController
                                //                         .selectedSeriesSesonIndex
                                //                         .value)
                                //                     .value,
                                //                 title: widget.title,
                                //                 // 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4'
                                //                 // duration: parseDuration(homeGetxController
                                //                 //         .seriesDetails
                                //                 //         ?.episodes
                                //                 //         ?.countsBySeason
                                //                 //         ?.entries
                                //                 //         .elementAt(homeGetxController
                                //                 //             .selectedSeriesSesonIndex
                                //                 //             .value)
                                //                 //         .value
                                //                 //         .elementAt(index)
                                //                 //         .info!
                                //                 //         .duration ??
                                //                 //     '00:00:00'),
                                //               );
                                //             },
                                //           ));
                                //           // Get.off(() => PlayerScreen(
                                //           //       videoUrl: url,
                                //           //       episodes: homeGetxController
                                //           //           .seriesDetails
                                //           //           ?.episodes
                                //           //           ?.countsBySeason
                                //           //           ?.entries
                                //           //           .elementAt(homeGetxController
                                //           //               .selectedSeriesSesonIndex
                                //           //               .value)
                                //           //           .value,
                                //           //       // 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4'
                                //           //       // duration: parseDuration(homeGetxController
                                //           //       //         .seriesDetails
                                //           //       //         ?.episodes
                                //           //       //         ?.countsBySeason
                                //           //       //         ?.entries
                                //           //       //         .elementAt(homeGetxController
                                //           //       //             .selectedSeriesSesonIndex
                                //           //       //             .value)
                                //           //       //         .value
                                //           //       //         .elementAt(index)
                                //           //       //         .info!
                                //           //       //         .duration ??
                                //           //       //     '00:00:00'),
                                //           //     ));
                                //         }
                                //       }
                                //     :
                                null,
                            onNext10Pressed: onNext10Pressed,
                            onPrevious10SecPressed: onPrevious10SecPressed,
                          ),
                        ),

                      // if (_showControls)
                      //   Positioned(
                      //     top: 30,
                      //     left: 0,
                      //     child: IconButton(
                      //         onPressed: () {
                      //           setState(() {
                      //             showEpisodes = !showEpisodes;
                      //           });
                      //         },
                      //         icon: const Icon(Icons.menu)),
                      //   ),
                      if (_showControls && showForwardAndBackward)
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                onLongPressStart: (details) =>
                                    onPreviousLongPressedStart(),
                                onLongPressEnd: (details) =>
                                    onPreviousLongPressedEnd(),
                                child: IconButton(
                                    onPressed: onPrevious10SecPressed,
                                    icon: const Icon(
                                      Icons.forward_10,
                                      color: AppColors.whiteColor,
                                      size: 55,
                                    )),
                              ),
                              IconButton(
                                iconSize: 64,
                                icon: Icon(
                                  _controller.value.isPlaying
                                      ? Icons.pause
                                      : _controller.value.position ==
                                              _controller.value.duration
                                          ? Icons.replay
                                          : Icons.play_arrow,
                                  color: Colors.white,
                                ),
                                onPressed: _togglePlayPause,
                              ),
                              GestureDetector(
                                onLongPressStart: (details) =>
                                    onNextLongPressedStart(),
                                onLongPressEnd: (details) =>
                                    onNextLongPressedEnd(),
                                child: IconButton(
                                    onPressed: onNext10Pressed,
                                    icon: const Icon(
                                      Icons.replay_10,
                                      color: AppColors.whiteColor,
                                      size: 55,
                                    )),
                              ),
                            ],
                          ),
                        ),

                      if (isBuffering)
                        const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.whiteColor,
                          ),
                        ),

                      if (showLoading)
                        const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.whiteColor,
                          ),
                        ),

                      if (_showControls)
                        Positioned(
                            left: 0,
                            right: 0,
                            top: 20,
                            child: Text(
                              widget.title,
                              textAlign: TextAlign.center,
                              style: AppStyles().font20(
                                color: AppColors.whiteColor,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                    ],
                  )
                : const CircularProgressIndicator(
                    color: AppColors.whiteColor,
                  ),
          ),
        ),
      ),
    );
  }

  void onPrevious10SecPressed() {
    _controller
        .seekTo(Duration(seconds: _controller.value.position.inSeconds - 10));
  }

  void onNext10Pressed() {
    _controller
        .seekTo(Duration(seconds: _controller.value.position.inSeconds + 10));
  }

  void _handleKeyEvent(KeyEvent event) {
    // نتأكد أن الحدث هو ضغط مفتاح وليس إفلاته
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.select) {
        // Handle OK button (Enter) press
        _togglePlayPause();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        // Handle up arrow press
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      // Handle down arrow press
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      // Handle left arrow press
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      // Handle right arrow press
    } else if (event.logicalKey == LogicalKeyboardKey.contextMenu) {}
  }

  void onPreviousLongPressedStart() {
    // عند بدء الضغط المطول
    setState(() {
      onPreviousLongPressed = true;
      _showControls = true;
      showForwardAndBackward = false;
    });
    _rewindTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _controller.seekTo(
        Duration(seconds: _controller.value.position.inSeconds - 2),
      );
    });
  }

  void onPreviousLongPressedEnd() {
    // عند إنهاء الضغط المطول
    setState(() {
      onPreviousLongPressed = false;
      _showControls = false;
      showForwardAndBackward = true;
    });
    if (_rewindTimer != null) {
      _rewindTimer!.cancel();
    }
  }

  void onNextLongPressedStart() {
    // عند بدء الضغط المطول للتقديم
    setState(() {
      onNextLongPressed = true;
      _showControls = true;
      showForwardAndBackward = false;
    });
    _rewindTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _controller.seekTo(
        Duration(seconds: _controller.value.position.inSeconds + 2),
      );
    });
  }

  void onNextLongPressedEnd() {
    // عند إنهاء الضغط المطول للتقديم
    setState(() {
      onNextLongPressed = false;
      _showControls = false;
      showForwardAndBackward = true;
    });
    if (_rewindTimer != null) {
      _rewindTimer!.cancel();
    }
  }
}

class VideoControls extends StatefulWidget {
  final VideoPlayerController controller;
  final VoidCallback onPlayPause;
  final void Function()? onMenuPressed;
  final void Function()? onNextPressed;
  final void Function()? onPreviousPressed;
  final void Function()? onPrevious10SecPressed;
  final void Function()? onNext10Pressed;

  const VideoControls({
    super.key,
    required this.controller,
    required this.onPlayPause,
    this.onMenuPressed,
    this.onNextPressed,
    this.onPreviousPressed,
    this.onNext10Pressed,
    this.onPrevious10SecPressed,
  });

  @override
  _VideoControlsState createState() => _VideoControlsState();
}

class _VideoControlsState extends State<VideoControls> {
  late Duration _duration;
  late Duration _position;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _duration = widget.controller.value.duration;
    _position = widget.controller.value.position;

    widget.controller.addListener(videoListener);
  }

  void videoListener() {
    if (mounted && !_isDragging) {
      setState(() {
        _position = widget.controller.value.position;
        _duration = widget.controller.value.duration;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      color: Colors.black54,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: 20,
            child: Slider(
              value: _position.inSeconds.toDouble(),
              min: 0.0,
              max: _duration.inSeconds.toDouble(),
              onChanged: (value) {
                setState(() {
                  _isDragging = true;
                  _position = Duration(seconds: value.toInt());
                });
              },
              onChangeEnd: (value) {
                widget.controller.seekTo(Duration(seconds: value.toInt()));
                setState(() {
                  _isDragging = false;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(_formatDuration(_position),
                    style: const TextStyle(color: Colors.white)),
                Text(_formatDuration(_duration),
                    style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
          SizedBox(
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
                  child: IconButton(
                      onPressed: widget.onPreviousPressed,
                      icon: Icon(
                        Icons.skip_next,
                        color: widget.onPreviousPressed != null
                            ? AppColors.whiteColor
                            : AppColors.blacksub3Color,
                      )),
                ),
                // IconButton(
                //     onPressed: widget.onPrevious10SecPressed,
                //     icon: const Icon(
                //       Icons.forward_10,
                //       color: AppColors.whiteColor,
                //     )),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
                  child: IconButton(
                      onPressed: widget.onMenuPressed,
                      icon: Icon(Icons.menu,
                          color: widget.onMenuPressed != null
                              ? AppColors.whiteColor
                              : AppColors.blacksub3Color)),
                ),
                // IconButton(
                //     onPressed: widget.onNext10Pressed,
                //     icon: const Icon(Icons.replay_10,
                //         color: AppColors.whiteColor)),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
                  child: IconButton(
                      onPressed: widget.onNextPressed,
                      icon: Icon(Icons.skip_previous,
                          color: widget.onNextPressed != null
                              ? AppColors.whiteColor
                              : AppColors.blacksub3Color)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '${twoDigits(duration.inHours)}:$minutes:$seconds';
  }
}
