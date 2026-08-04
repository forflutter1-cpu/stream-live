import 'dart:async';

import 'package:better_player_plus/better_player_plus.dart';
import 'package:flu_wake_lock/flu_wake_lock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iptv/Screen/SplashScreen.dart';
import 'package:iptv/Widget/main_image_widget.dart';
import 'package:iptv/Widget/web_hls_player.dart';
import 'package:iptv/api/api_helper.dart';
import 'package:iptv/app_material/app_colors.dart';
import 'package:iptv/app_material/app_styles.dart';
import 'package:iptv/controller/home_getx_controller.dart';
import 'package:iptv/database/database_helper.dart';
import 'package:iptv/shared_preferences/shared_pref_controller.dart';
import 'package:iptv/utils/app_helper.dart';
import 'package:iptv/utils/circal_animated.dart';
import 'package:iptv/utils/friendly_routes.dart';
import 'package:iptv/utils/stream_url_builder.dart';

class LiveScreen extends StatefulWidget {
  final String? url;
  final String? name;
  const LiveScreen({
    super.key,
    this.url,
    this.name,
  });

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> with AppHelper, ApiHelper {
  late final HomeGetxController homeGetxController;
  BetterPlayerController? _betterPlayerController;
  // late BetterPlayerConfiguration betterPlayerConfig;

  int _focusedIndex = 0;
  int _retryCount = 0;

  String _errorText = '';
  String _retryMessage = '';
  // bool _isLoading = false;
  bool _showMenu = true;
  bool _showFocusIndex = false;
  bool _isRetrying = false;
  bool _showPlayPauseArrow = false;
  Timer? _hideControlsTimer;
  final FluWakeLock fluWakeLock = FluWakeLock();
  String? _webStreamUrl;
  String? _webStreamName;

  Future<void> enableWakeLock() async {
    if (!kIsWeb) {
      await fluWakeLock.enable();
    }
  }

  @override
  void initState() {
    super.initState();
    homeGetxController = Get.isRegistered<HomeGetxController>()
        ? Get.find<HomeGetxController>()
        : Get.put(HomeGetxController());
    // fluWakeLock.enable();
    if (kIsWeb) {
      _webStreamUrl = widget.url ?? SharedPrefController().lastUrl;
      _webStreamName = widget.name ?? SharedPrefController().streamName;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _ensureWebListLoaded();
      });
      return;
    }
    if (widget.url != null || SharedPrefController().lastUrl != null) {
      BetterPlayerDataSource dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        widget.url ?? SharedPrefController().lastUrl ?? "",
        liveStream: true,
        notificationConfiguration: const BetterPlayerNotificationConfiguration(
          showNotification: true,
          title: "IPTV Stream",
          author: "Stream Live",
        ),
      );
      _betterPlayerController = BetterPlayerController(
        const BetterPlayerConfiguration(
          deviceOrientationsAfterFullScreen: [
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight
          ],
          deviceOrientationsOnFullScreen: [
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight
          ],
          aspectRatio: 16 / 9,
          autoPlay: true,
          looping: false,
          handleLifecycle: true,
          allowedScreenSleep: false,
          fullScreenByDefault: false,

          // autoDetectFullscreenDeviceOrientation: true,
          fit: BoxFit.contain,
        ),
        betterPlayerDataSource: dataSource,
      );
      _betterPlayerController?.addEventsListener((event) async {
        await enableWakeLock();
      });
    }
  }

  Future<void> _ensureWebListLoaded() async {
    if (!mounted) return;
    if (homeGetxController.categories.isEmpty) {
      await homeGetxController.getCategories(load: false);
    }
    if (homeGetxController.streams.isEmpty) {
      await homeGetxController.getStreams(load: false);
    }
    if (homeGetxController.streamsFilterd.isEmpty &&
        homeGetxController.categories.isNotEmpty) {
      homeGetxController.filterStreams(load: false);
    }
  }

  // void _initializeWakeLock() {
  //   if (!kIsWeb) {
  //     _fluWakeLock.enable();
  //   }
  // }

  // void _initializeBetterPlayer() {
  //   _betterPlayerConfig = BetterPlayerConfiguration(
  //     aspectRatio: 16 / 9,
  //     fit: BoxFit.fill,
  //     autoPlay: true,
  //     controlsConfiguration: BetterPlayerControlsConfiguration(
  //       showControls: false, // Hide default controls
  //       enableSkips: false,
  //       enablePlayPause: false,
  //     ),
  //   );
  //   _betterPlayerController = BetterPlayerController(_betterPlayerConfig);
  // }

  // void _setupBetterPlayerListeners() {
  //   _betterPlayerController.addEventsListener((event) {
  //     if (event.betterPlayerEventType == BetterPlayerEventType.exception) {
  //       _handlePlaybackError('An error occurred: $event');
  //     } else if (event.betterPlayerEventType ==
  //         BetterPlayerEventType.initialized) {
  //       if (_isLoading) {
  //         setState(() {
  //           _isLoading = false;
  //           _errorText = '';
  //           _retryCount = 0;
  //         });
  //       }
  //     } else if (event.betterPlayerEventType ==
  //         BetterPlayerEventType.bufferingStart) {
  //       if (!_isLoading) {
  //         setState(() {
  //           _isLoading = true;
  //           _errorText = '';
  //         });
  //       }
  //     } else if (event.betterPlayerEventType == BetterPlayerEventType.play) {
  //       if (_isLoading) {
  //         setState(() {
  //           _isLoading = false;
  //           _errorText = '';
  //           _retryCount = 0;
  //         });
  //       }
  //     } else if (event.betterPlayerEventType ==
  //         BetterPlayerEventType.finished) {
  //       _handlePlaybackError('Playback completed, retrying...');
  //     } else if (event.betterPlayerEventType ==
  //         BetterPlayerEventType.exception) {
  //       _handlePlaybackError('Playback failed, retrying in 5 seconds...');
  //     }
  //   });
  // }

  void _handlePlaybackError(String message) {
    if (_isRetrying) return;
    setState(() {
      // _isLoading = true;
      _errorText = message;
    });
    Future.delayed(const Duration(seconds: 5), () {
      _retryStream(
          SharedPrefController().lastUrl!, SharedPrefController().streamName!);
    });
  }

  // void loadInitialStream() {
  //   final String? initialUrl = widget.url ?? SharedPrefController().lastUrl;
  //   final String? initialName =
  //       widget.name ?? SharedPrefController().streamName;

  //   print('=============$initialUrl');

  //   if (initialUrl != null &&
  //       initialUrl.isNotEmpty &&
  //       initialName != null &&
  //       initialName.isNotEmpty) {
  //     _playStream(initialUrl, initialName);
  //   } else if (SharedPrefController().lastUrl != null &&
  //       SharedPrefController().streamName != null) {
  //     _playStream(
  //         SharedPrefController().lastUrl!, SharedPrefController().streamName!);
  //   }
  // }

  @override
  void dispose() {
    // restore system UI when leaving live screen
    if (!kIsWeb) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: [SystemUiOverlay.bottom]);
    }
    _betterPlayerController?.dispose();
    _hideControlsTimer?.cancel();
    if (!kIsWeb) {
      // fluWakeLock.disable();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    enableWakeLock();

    final screenWidth = MediaQuery.of(context).size.width;
    final webPlayerActive =
        kIsWeb && _webStreamUrl != null && _webStreamUrl!.isNotEmpty;

    return Scaffold(
      body: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: _handleKeyEvent,
        child: Stack(
          children: [
            InkWell(
              onTap: _toggleControlsVisibility,
              onDoubleTap: () {
                setState(() {
                  _showMenu = !_showMenu;
                });
              },
              child: Stack(
                children: [
                  webPlayerActive
                      ? WebHlsPlayer(
                          url: streamUrlWithDeviceId(_webStreamUrl!),
                          title: _webStreamName ?? 'Stream Live',
                        )
                      : _betterPlayerController != null
                          ? BetterPlayer(
                              controller: _betterPlayerController!,
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const AnimatedCircle(),
                                  const SizedBox(height: 10),
                                  Obx(
                                    () => Visibility(
                                      visible: homeGetxController
                                          .isLoadingStream.value,
                                      child: Text(
                                        'جاري جلب قائمة التشغيل ...',
                                        style: AppStyles().font16(
                                          color: AppColors.primryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                  if (_errorText.isNotEmpty)
                    Center(
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                            color: _retryMessage.isNotEmpty
                                ? AppColors.blacksub3Color
                                : null,
                            borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: Text(
                                _errorText,
                                style: AppStyles().font12(
                                  color: AppColors.whiteColor,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (_retryMessage.isNotEmpty)
                              Center(
                                child: Text(
                                  _retryMessage,
                                  style: AppStyles().font12(
                                    color: AppColors.whiteColor,
                                    // fontWeight: FontColors.w300,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 8),
                            if (_retryMessage.isNotEmpty)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton(
                                    onPressed: () async {
                                      setState(() {
                                        SharedPrefController()
                                            .updateLastUrl(lastUrl: '');
                                        _errorText = '';
                                        _retryMessage = '';
                                        _retryCount = 0;
                                      });
                                      if (homeGetxController
                                              .isLoadingMovieStream.value ||
                                          homeGetxController
                                              .isLoadingSeriesStream.value) {
                                        return;
                                      }
                                      homeGetxController.getCategories(
                                          clearData: true);
                                      await homeGetxController.getStreams(
                                          clearData: true);
                                    },
                                    child: Text(
                                      'تحديث القنوات',
                                      style: AppStyles().font12(
                                        color: AppColors.primryColor,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  TextButton(
                                    onPressed: () => contactDialog(),
                                    child: Text(
                                      'تواصل معنا للاشتراك',
                                      style: AppStyles().font12(
                                        color: AppColors.greenColor,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Visibility(
              visible: _showMenu,
              replacement: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: AppColors.whiteColor,
                  child: IconButton(
                    icon: Icon(
                      _showMenu ? Icons.close : Icons.list,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      setState(() {
                        _showMenu = !_showMenu;
                      });
                    },
                  ),
                ),
              ),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      height: Get.height,
                      width: (screenWidth * 0.25).clamp(220.0, 360.0),
                      decoration: BoxDecoration(
                        color: AppColors.primryColor.withAlpha(160),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: IconButton(
                                  onPressed: () {
                                    if (homeGetxController.categoryIndex.value >
                                        0) {
                                      homeGetxController.categoryIndex.value--;
                                    } else {
                                      homeGetxController.categoryIndex.value =
                                          homeGetxController.categories.length -
                                              1;
                                    }
                                    homeGetxController.filterStreams();
                                  },
                                  icon: const Icon(
                                    Icons.arrow_back_ios,
                                    color: AppColors.whiteColor,
                                    size: 15,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Obx(() {
                                    if (homeGetxController
                                        .isLoadingCategory.value) {
                                      return const Text('');
                                    } else if (homeGetxController
                                        .categories.isNotEmpty) {
                                      // show current category and allow picking
                                      return InkWell(
                                        onTap: () {
                                          Get.defaultDialog(
                                            title: 'التصنيفات',
                                            content: SizedBox(
                                              height: Get.height * 0.5,
                                              child: ListWheelScrollView(
                                                itemExtent: 35,
                                                children: List.generate(
                                                  homeGetxController
                                                      .categories.length,
                                                  (index) => InkWell(
                                                    onTap: () {
                                                      homeGetxController
                                                          .categoryIndex
                                                          .value = index;
                                                      homeGetxController
                                                          .filterStreams();
                                                      Get.back();
                                                    },
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              5),
                                                      child: Text(
                                                        homeGetxController
                                                                .categories[
                                                                    index]
                                                                .categoryName ??
                                                            '',
                                                        style: AppStyles().font16(
                                                            color: homeGetxController
                                                                        .categoryIndex
                                                                        .value ==
                                                                    index
                                                                ? AppColors
                                                                    .primryColor
                                                                : AppColors
                                                                    .blackColor),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          homeGetxController
                                                  .categories[homeGetxController
                                                      .categoryIndex.value]
                                                  .categoryName ??
                                              '',
                                          style: AppStyles().font12(
                                            color: AppColors.whiteColor,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                      );
                                    } else {
                                      return Text('',
                                          style: AppStyles().font12(
                                            color: AppColors.whiteColor,
                                            fontWeight: FontWeight.w300,
                                          ));
                                    }
                                  }),
                                ),
                              ),
                              Expanded(
                                child: IconButton(
                                  onPressed: () {
                                    if (homeGetxController.categoryIndex.value <
                                        homeGetxController.categories.length -
                                            1) {
                                      homeGetxController.categoryIndex.value++;
                                    } else {
                                      homeGetxController.categoryIndex.value =
                                          0;
                                    }
                                    homeGetxController.filterStreams();
                                  },
                                  icon: const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 15,
                                    color: AppColors.whiteColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          Expanded(
                            child: Obx(() {
                              if (homeGetxController.isLoadingStream.value) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.whiteColor,
                                  ),
                                );
                              } else if (homeGetxController
                                  .streamsFilterd.isNotEmpty) {
                                return ListView.separated(
                                  separatorBuilder: (context, index) {
                                    return const Divider();
                                  },
                                  shrinkWrap: true,
                                  itemCount:
                                      homeGetxController.streamsFilterd.length,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 3),
                                  itemBuilder: (context, index) {
                                    return Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: homeGetxController
                                                      .streamsFilterd[index]
                                                      .name !=
                                                  homeGetxController
                                                      .selectedStreamName.value
                                              ? 8
                                              : 3),
                                      decoration: BoxDecoration(
                                          color: homeGetxController
                                                      .streamsFilterd[index]
                                                      .name ==
                                                  homeGetxController
                                                      .selectedStreamName.value
                                              ? AppColors.primryColor
                                                  .withAlpha(150)
                                              : _showFocusIndex &&
                                                      _focusedIndex == index
                                                  ? AppColors.primryColor
                                                      .withAlpha(100)
                                                  : null,
                                          borderRadius:
                                              BorderRadius.circular(4)),
                                      child: InkWell(
                                        focusColor: AppColors.primryColor
                                            .withAlpha(100),
                                        onFocusChange: (value) {
                                          if (value) {
                                            setState(() {
                                              _focusedIndex = index;
                                            });
                                          }
                                        },
                                        onTap: () async {
                                          final stream = homeGetxController
                                              .streamsFilterd[index];
                                          if (kIsWeb &&
                                              stream.streamId != null) {
                                            Get.toNamed(liveRoute(stream),
                                                arguments: stream);
                                            return;
                                          }
                                          _isRetrying = false;
                                          setState(() {
                                            _errorText = '';
                                            _retryCount = 0;
                                            _retryMessage = '';
                                          });

                                          homeGetxController
                                              .changeSelectedStreamName(
                                                  homeGetxController
                                                          .streamsFilterd[index]
                                                          .name ??
                                                      '');
                                          final String url =
                                              _buildStreamUrl(index: index);
                                          _playStream(
                                              url,
                                              homeGetxController
                                                      .streamsFilterd[index]
                                                      .name ??
                                                  '');
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  (index + 1).toString(),
                                                  style: AppStyles().font12(
                                                    color: AppColors.whiteColor,
                                                    fontWeight: FontWeight.w300,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                _buildStreamIcon(
                                                    homeGetxController
                                                        .streamsFilterd[index]
                                                        .streamIcon),
                                              ],
                                            ),
                                            SizedBox(
                                              width: 100,
                                              child: Text(
                                                homeGetxController
                                                        .streamsFilterd[index]
                                                        .name ??
                                                    'Name',
                                                textAlign: TextAlign.end,
                                                style: AppStyles().font12(
                                                  color: AppColors.whiteColor,
                                                  fontWeight: homeGetxController
                                                              .selectedStreamName
                                                              .value ==
                                                          homeGetxController
                                                              .streamsFilterd[
                                                                  index]
                                                              .name
                                                      ? FontWeight.w400
                                                      : FontWeight.w300,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              } else {
                                return Expanded(
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text('لا يوجد قنوات',
                                            style: AppStyles().font12(
                                              color: AppColors.whiteColor,
                                              fontWeight: FontWeight.w300,
                                            )),
                                        const SizedBox(height: 10),
                                        TextButton(
                                          onPressed: () {
                                            homeGetxController.getCategories(
                                                clearData: true);
                                            homeGetxController.getStreams(
                                                clearData: true);
                                          },
                                          child: Text(
                                            'تحديث',
                                            style: AppStyles().font12(
                                              color: AppColors.whiteColor,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                            }),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundColor: AppColors.whiteColor,
                        child: IconButton(
                          icon: Icon(
                            _showMenu ? Icons.close : Icons.list,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            setState(() {
                              _showMenu = !_showMenu;
                            });
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            PositionedDirectional(
              top: 10,
              end: 10,
              child: SafeArea(
                child: CircleAvatar(
                  backgroundColor: AppColors.whiteColor.withAlpha(235),
                  child: IconButton(
                    tooltip: 'رجوع',
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Get.back();
                      } else {
                        Get.offAllNamed('/home');
                      }
                    },
                  ),
                ),
              ),
            ),

            // if (_showPlayPauseArrow)
            //   Center(
            //     child: IconButton(
            //       onPressed: _togglePlayPause,
            //       icon: Icon(
            //         _betterPlayerController.isPlaying() == true
            //             ? Icons.pause_circle_outline_outlined
            //             : Icons.play_circle_outline,
            //         color: AppColors.whiteColor,
            //         size: 100,
            //       ),
            //     ),
            //   ),
            // if (_showPlayPauseArrow)
            //   Align(
            //     alignment: AlignmentDirectional.topEnd,
            //     child: Padding(
            //       padding: const EdgeInsets.all(10.0),
            //       child: InkWell(
            //         onTap: () {
            //           _isRetrying = false;
            //           setState(() {
            //             _errorText = '';
            //             _retryCount = 0;
            //             _retryMessage = '';
            //           });
            //           _playStream(SharedPrefController().lastUrl!,
            //               SharedPrefController().streamName!);
            //         },
            //         child: Container(
            //           padding: const EdgeInsets.all(10.0),
            //           decoration: BoxDecoration(
            //             color: AppColors.whiteColor,
            //             borderRadius: BorderRadius.circular(50),
            //           ),
            //           child: const Row(
            //             mainAxisSize: MainAxisSize.min,
            //             children: [
            //               CircleAvatar(
            //                 radius: 5,
            //                 backgroundColor: AppColors.redColor,
            //               ),
            //               SizedBox(width: 5),
            //               Text('مباشر'),
            //             ],
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreamIcon(String? iconUrl) {
    return MainImageWidget(
      image: iconUrl,
      height: 40,
      width: 40,
      fit: BoxFit.fitWidth,
    );
  }

  String _buildStreamUrl({required int index}) {
    final stream = homeGetxController.streamsFilterd[index];
    return streamPlaybackUrl(stream, preferWebHls: kIsWeb);
  }

  void _playStream(String url, String name) async {
    if (SharedPrefController().name.isEmpty) {
      _handleSessionExpired();
      return;
    }

    _isRetrying = false;
    setState(() {
      // _isLoading = true;
      _errorText = '';
      _retryMessage = '';
    });

    try {
      if (kIsWeb) {
        SharedPrefController().updateLastUrl(lastUrl: url);
        SharedPrefController().updateStreamName(streamName: name);
        setState(() {
          _webStreamUrl = url;
          _webStreamName = name;
        });
        return;
      }
      await _betterPlayerController?.pause();

      final dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        streamUrlWithDeviceId(url),
        liveStream: true,
      );

      if (_betterPlayerController != null) {
        await _betterPlayerController?.setupDataSource(dataSource);
        await _betterPlayerController?.setVolume(1.0);
        await _betterPlayerController?.play();
      } else {
        BetterPlayerDataSource dataSource = BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          url,
          liveStream: true,
          notificationConfiguration:
              const BetterPlayerNotificationConfiguration(
            showNotification: true,
            title: "IPTV Stream",
            author: "Stream Live",
          ),
        );
        _betterPlayerController = BetterPlayerController(
          const BetterPlayerConfiguration(
            deviceOrientationsAfterFullScreen: [
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight
            ],
            deviceOrientationsOnFullScreen: [
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight
            ],
            aspectRatio: 16 / 9,
            autoPlay: true,
            looping: false,
            handleLifecycle: true,
            allowedScreenSleep: false,

            fullScreenByDefault: false,
            // autoDetectFullscreenDeviceOrientation: true,
            fit: BoxFit.contain,
          ),
          betterPlayerDataSource: dataSource,
        );
        _betterPlayerController?.addEventsListener((event) async {
          print(
              '========================================event 2 ${event.betterPlayerEventType}');
          await enableWakeLock();
        });
      }
      // Update shared preferences after successful attempt to play
      SharedPrefController().updateLastUrl(lastUrl: url);
      SharedPrefController().updateStreamName(streamName: name);
      SharedPrefController().updateSelectedCategoryIndex(
        selectedCategoryIndex: homeGetxController.categoryIndex.value,
      );
    } catch (e) {
      _handlePlaybackError('فشل التحميل، سيتم إعادة المحاولة خلال 5 ثوانٍ');
    } finally {
      setState(() {
        // _isLoading = false;
      });
    }
  }

  void _retryStream(String url, String name) async {
    if (_retryCount < 2) {
      _retryCount++;
      _isRetrying = true;
      setState(() {
        // _isLoading = true;
        _errorText = 'إعادة المحاولة رقم $_retryCount...';
      });
      await Future.delayed(const Duration(seconds: 1));
      _playStream(url, name);
    } else {
      _isRetrying = false;
      setState(() {
        _errorText = 'يجب عليك الاشتراك لمشاهدة هذه القناة';
        _retryMessage =
            'تأكد من اشتراكك أو جودة الاتصال بالإنترنت، أو تواصل معنا للاشتراك والدعم الفني.';
        // _isLoading = false;
      });
      await _betterPlayerController?.pause();
    }
  }

  void _handleSessionExpired() {
    SharedPrefController().clear();
    DatabaseHelper.instance.clearDatabase();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        Get.offAll(() => const SplashScreen());
        showMeesage(
          title: 'انتهت الجلسة',
          isError: true,
        );
      } catch (_) {}
    });

    _betterPlayerController?.pause();
  }

  void _toggleControlsVisibility() {
    setState(() {
      _showPlayPauseArrow = !_showPlayPauseArrow;
    });

    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 5), () {
      if (_showPlayPauseArrow) {
        setState(() {
          _showPlayPauseArrow = false;
        });
      }
    });
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.select) {
        setState(() {
          _showMenu = !_showMenu;
        });
        if (homeGetxController.streamsFilterd.isNotEmpty) {
          homeGetxController.changeSelectedStreamName(
              homeGetxController.streamsFilterd[_focusedIndex].name ?? '');
          final String url = _buildStreamUrl(index: _focusedIndex);
          _playStream(
              url, homeGetxController.streamsFilterd[_focusedIndex].name ?? '');
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        if (!_showFocusIndex) {
          setState(() {
            _showFocusIndex = true;
          });
        }
        if (!_showMenu && _focusedIndex > 0) {
          _focusedIndex--;
          homeGetxController.changeSelectedStreamName(
              homeGetxController.streamsFilterd[_focusedIndex].name ?? '');
          final String url = _buildStreamUrl(index: _focusedIndex);
          _playStream(
              url, homeGetxController.streamsFilterd[_focusedIndex].name ?? '');
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        if (!_showFocusIndex) {
          setState(() {
            _showFocusIndex = true;
          });
        }
        if (!_showMenu &&
            _focusedIndex < homeGetxController.streamsFilterd.length - 1) {
          _focusedIndex++;
          homeGetxController.changeSelectedStreamName(
              homeGetxController.streamsFilterd[_focusedIndex].name ?? '');
          final String url = _buildStreamUrl(index: _focusedIndex);
          _playStream(
              url, homeGetxController.streamsFilterd[_focusedIndex].name ?? '');
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        if (!_showMenu) {
          setState(() {
            _showMenu = true;
          });
        }
        if (homeGetxController.categoryIndex.value <
            homeGetxController.categories.length - 1) {
          homeGetxController.categoryIndex.value++;
        } else {
          homeGetxController.categoryIndex.value = 0;
        }
        homeGetxController.filterStreams();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        if (!_showMenu) {
          setState(() {
            _showMenu = true;
          });
        }
        if (homeGetxController.categoryIndex.value > 0) {
          homeGetxController.categoryIndex.value--;
        } else {
          homeGetxController.categoryIndex.value =
              homeGetxController.categories.length - 1;
        }
        homeGetxController.filterStreams();
      }
    }
  }
}
