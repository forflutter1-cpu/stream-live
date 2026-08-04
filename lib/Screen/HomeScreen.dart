import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flu_wake_lock/flu_wake_lock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iptv/Screen/SplashScreen.dart';
import 'package:iptv/Screen/Widget/appBarrWidget.dart';
import 'package:iptv/Screen/bn_screens/live_screen.dart';
import 'package:iptv/Screen/bn_screens/movie_screen.dart';
import 'package:iptv/Screen/bn_screens/series_screen.dart';
import 'package:iptv/api/api_controller/api_controller.dart';
import 'package:iptv/api/api_helper.dart';
import 'package:iptv/app_material/app_colors.dart';
import 'package:iptv/app_material/app_styles.dart';
import 'package:iptv/controller/download_getx_controller.dart';
// import 'package:iptv/controller/download_getx_controller.dart';
import 'package:iptv/controller/fb_notifications_controller.dart';
import 'package:iptv/controller/home_getx_controller.dart';
import 'package:iptv/database/database_helper.dart';
import 'package:iptv/model/contact_model.dart';
import 'package:iptv/shared_preferences/shared_pref_controller.dart';
import 'package:iptv/utils/app_helper.dart';
import 'package:permission_handler/permission_handler.dart';

ContactModel? contactModel;

class HomeScreen extends StatefulWidget {
  final bool forceUpdate;
  const HomeScreen({super.key, this.forceUpdate = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with ApiHelper, AppHelper, FBNotificationsController {
  HomeGetxController homeGetxController = Get.put(HomeGetxController());

  DownloadGetxController? downloadGetxController =
      kIsWeb ? null : Get.put(DownloadGetxController());
  TextEditingController searchController = TextEditingController();

  String errorText = '';
  bool isLoading = false;
  bool showDetails = false;
  bool showSearch = false;
  bool expandedVideo = false;
  bool isDialogOpen = false; // متغير لتتبع حالة الحوار المفتوح
  int selectedType = 0;
  bool isLiveFocused = false; // متغير لتتبع حالة الحوار المفتوح
  bool isMovieFocused = false; // متغير لتتبع حالة الحوار المفتوح
  bool isSeriesFocused = false; // متغير لتتبع حالة الحوار المفتوح

  // bool _isPlayerBusy = false;

  int? streamId;

  void permission() async {
    if (!await Permission.notification.isGranted) {
      await Permission.notification.request();
    }
  }

  void fcmToken() async {
    if (kIsWeb) return;
    // String? fcm =
    await FirebaseMessaging.instance.getToken();
  }

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      requestNotificationPermissions();
      initializeForegroundNotificationForAndroid();
      mangeNotificationAction();
      fcmToken();
      permission();
    }

    searchController = TextEditingController();
    if (SharedPrefController().deviceId == null) {
      SharedPrefController().updateDeviceId(deviceId: generateRandomString());
    }
    if (SharedPrefController().name.isEmpty) {
      SharedPrefController().clear();
      if (!kIsWeb) {
        DatabaseHelper.instance.clearDatabase();
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          Get.offAll(() => const SplashScreen());
          showMeesage(
            title: 'انتهت الجلسة',
            // subTitle: 'تم انتهاء الجلسة الخاصة بك',
            isError: true,
          );
        } catch (_) {}
      });

      return;
    }
    getContact();
    getProfile();
    getStreams();

    if (SharedPrefController().lastUrl != null) {
      // controller.setDataSource(
      //   '${SharedPrefController().lastUrl}$stringHeader',
      //   autoPlay: true,
      // );
      homeGetxController
          .changeSelectedStreamName(SharedPrefController().streamName!);
      homeGetxController.changeSelectedCategoryIndex(
          SharedPrefController().selectedCategoryIndex);
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    // controller.dispose();
    super.dispose();
  }

  void getProfile() async {
    await ApiController().checkProfile();
    if (SharedPrefController().name.isEmpty) {
      SharedPrefController().clear();
      if (!kIsWeb) {
        DatabaseHelper.instance.clearDatabase();
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          Get.offAll(() => const SplashScreen());
          showMeesage(
            title: 'انتهت الجلسة',
            // subTitle: 'تم انتهاء الجلسة الخاصة بك',
            isError: true,
          );
        } catch (_) {}
      });
    } else {
      if (SharedPrefController().status != 'Active') {
        contactDialog(
          // settings: contactModel!,
          actice: false,
        );
      }
    }
  }

  void getStreams() async {
    if (widget.forceUpdate) {
      forceUpdateDialog();
      await DatabaseHelper.instance.clearWatchProgress();
    }
    final dbHelper = DatabaseHelper.instance;
    final freeCat = await dbHelper.getCategory("free_channels");
    bool mustRefresh = (freeCat == null);

    // يجب الانتظار لاكتمال جلب الفئات أولاً قبل القنوات
    // لضمان وجود free_channels في قاعدة البيانات المحلية
    await homeGetxController.getCategories(
        clearData: widget.forceUpdate || mustRefresh);
    await homeGetxController.getStreams(
        clearData: widget.forceUpdate || mustRefresh);
    homeGetxController.getMovieCategories(clearData: widget.forceUpdate);
    await homeGetxController.getMovieStreams(clearData: widget.forceUpdate);
    homeGetxController.getSeriesCategories(clearData: widget.forceUpdate);
    await homeGetxController.getSeriesStreams(clearData: widget.forceUpdate);
  }

  final FluWakeLock fluWakeLock = FluWakeLock();

  void enableWakeLock() {
    if (!kIsWeb) {
      fluWakeLock.enable();
    }
  }

  @override
  Widget build(BuildContext context) {
    enableWakeLock();

    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.01;
    final tileWidth = screenWidth * 0.30;

    return Scaffold(
      appBar: const AppBar_Widget(
        showBack: false,
      ),
      body: SafeArea(
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() {
                return InkWell(
                  onTap: () async {
                    // Get.to(() => VideoPlayerPage());
                    await Get.toNamed('/live');
                    setState(() {});
                    enableWakeLock();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: double.infinity,
                      width: tileWidth,
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              Colors.blue,
                              Colors.green,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.blueGrey),
                      child: Stack(
                        children: [
                          Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.play_circle_outline,
                                  color: AppColors.whiteColor,
                                  size: 80,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  'بث مباشر',
                                  style: AppStyles().font16(
                                    color: AppColors.whiteColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional.bottomStart,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              width: double.infinity,
                              height: 50,
                              decoration: const BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10)),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${homeGetxController.streams.length} بث',
                                      maxLines: 1,
                                      style: AppStyles().font16(
                                        color: AppColors.whiteColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      if (homeGetxController
                                              .isLoadingMovieStream.value ||
                                          homeGetxController
                                              .isLoadingSeriesStream.value) {
                                        updateDialog();
                                        return;
                                      }
                                      homeGetxController.getCategories(
                                          clearData: true);
                                      homeGetxController.getStreams(
                                          clearData: true);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: Colors.white12)),
                                      child: Focus(
                                        onFocusChange: (hasFocus) {
                                          if (hasFocus) {
                                            // Change to the main color when focused
                                            setState(() {
                                              isLiveFocused = true;
                                            });
                                          } else {
                                            // Revert to the default color when not focused
                                            setState(() {
                                              isLiveFocused = false;
                                            });
                                          }
                                        },
                                        child: Row(
                                          children: [
                                            Text(
                                              homeGetxController
                                                      .isLoadingStream.value
                                                  // ? '${homeGetxController.streamPrcent.value} %'
                                                  ? 'جاري التحديث'
                                                  : 'تحديث ',
                                              style: AppStyles().font14(
                                                color: isLiveFocused
                                                    ? AppColors.primryColor
                                                    : AppColors.whiteColor,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            homeGetxController
                                                    .isLoadingStream.value
                                                ? const Padding(
                                                    padding:
                                                        EdgeInsets.all(3.0),
                                                    child: SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                                    Color>(
                                                                AppColors
                                                                    .whiteColor),
                                                      ),
                                                    ),
                                                  )
                                                : Icon(
                                                    Icons.update,
                                                    color: isLiveFocused
                                                        ? AppColors.primryColor
                                                        : AppColors.whiteColor,
                                                  ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }),
              Obx(() {
                return InkWell(
                  onTap: () async {
                    await Get.toNamed('/movies');
                    setState(() {});
                    enableWakeLock();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: double.infinity,
                      width: tileWidth,
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              Colors.yellow,
                              Colors.red,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.blueGrey),
                      child: Stack(
                        children: [
                          Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.movie_filter_outlined,
                                  color: AppColors.whiteColor,
                                  size: 80,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  'أفلام',
                                  style: AppStyles().font16(
                                    color: AppColors.whiteColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional.bottomStart,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              width: double.infinity,
                              height: 50,
                              decoration: const BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10)),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      ' ${homeGetxController.movieStreams.length} فلم ',
                                      maxLines: 1,
                                      style: AppStyles().font14(
                                        color: AppColors.whiteColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  // if (homeGetxController
                                  //     .isLoadingMovieStream.value)
                                  //   const CircularProgressIndicator(
                                  //     color: AppColors.whiteColor,
                                  //   )
                                  // else
                                  InkWell(
                                    onTap: () async {
                                      if (homeGetxController
                                              .isLoadingStream.value ||
                                          homeGetxController
                                              .isLoadingSeriesStream.value) {
                                        updateDialog();
                                        return;
                                      }
                                      await DatabaseHelper.instance
                                          .deleteWatchProgressByContentType(
                                              'movie'); // لحذف كل البيانات المتعلقة بالمسلسلات

                                      homeGetxController.getMovieCategories(
                                          clearData: true);
                                      homeGetxController.getMovieStreams(
                                          clearData: true);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: Colors.white12)),
                                      child: Focus(
                                        onFocusChange: (hasFocus) {
                                          if (hasFocus) {
                                            // Change to the main color when focused
                                            setState(() {
                                              isMovieFocused = true;
                                            });
                                          } else {
                                            // Revert to the default color when not focused
                                            setState(() {
                                              isMovieFocused = false;
                                            });
                                          }
                                        },
                                        child: Row(
                                          children: [
                                            Text(
                                              homeGetxController
                                                      .isLoadingMovieStream
                                                      .value
                                                  ? 'جاري التحديث'
                                                  : 'تحديث ',
                                              style: AppStyles().font14(
                                                color: isMovieFocused
                                                    ? AppColors.primryColor
                                                    : AppColors.whiteColor,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            homeGetxController
                                                    .isLoadingMovieStream.value
                                                ? const Padding(
                                                    padding:
                                                        EdgeInsets.all(3.0),
                                                    child: SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                                    Color>(
                                                                AppColors
                                                                    .whiteColor),
                                                      ),
                                                    ),
                                                  )
                                                : Icon(
                                                    Icons.update,
                                                    color: isMovieFocused
                                                        ? AppColors.primryColor
                                                        : AppColors.whiteColor,
                                                  ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }),
              Obx(() {
                return InkWell(
                  onTap: () async {
                    await Get.toNamed('/series');
                    setState(() {});
                    enableWakeLock();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: double.infinity,
                      width: tileWidth,
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              Colors.blue,
                              Colors.deepPurple,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.blueGrey),
                      child: Stack(
                        children: [
                          Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.live_tv_rounded,
                                  color: AppColors.whiteColor,
                                  size: 80,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  'مسلسلات',
                                  style: AppStyles().font16(
                                    color: AppColors.whiteColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional.bottomStart,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              width: double.infinity,
                              height: 50,
                              decoration: const BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10)),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${homeGetxController.seriesStreams.length} مسلسل ',
                                      maxLines: 1,
                                      style: AppStyles().font14(
                                        color: AppColors.whiteColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  // if (homeGetxController
                                  //     .isLoadingSeriesStream.value)
                                  //   const CircularProgressIndicator(
                                  //     color: AppColors.whiteColor,
                                  //   )
                                  // else
                                  InkWell(
                                    onTap: () async {
                                      if (homeGetxController
                                              .isLoadingMovieStream.value ||
                                          homeGetxController
                                              .isLoadingStream.value) {
                                        updateDialog();
                                        return;
                                      }
                                      await DatabaseHelper.instance
                                          .deleteWatchProgressByContentType(
                                              'series');
                                      homeGetxController.getSeriesCategories(
                                          clearData: true);
                                      homeGetxController.getSeriesStreams(
                                          clearData: true);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: Colors.white12)),
                                      child: Focus(
                                        onFocusChange: (hasFocus) {
                                          if (hasFocus) {
                                            // Change to the main color when focused
                                            setState(() {
                                              isSeriesFocused = true;
                                            });
                                          } else {
                                            // Revert to the default color when not focused
                                            setState(() {
                                              isSeriesFocused = false;
                                            });
                                          }
                                        },
                                        child: Row(
                                          children: [
                                            Text(
                                              homeGetxController
                                                      .isLoadingSeriesStream
                                                      .value
                                                  ? 'جاري التحديث'
                                                  : 'تحديث ',
                                              style: AppStyles().font14(
                                                color: isSeriesFocused
                                                    ? AppColors.primryColor
                                                    : AppColors.whiteColor,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            homeGetxController
                                                    .isLoadingSeriesStream.value
                                                ? const Padding(
                                                    padding:
                                                        EdgeInsets.all(3.0),
                                                    child: SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        valueColor:
                                                            AlwaysStoppedAnimation<
                                                                    Color>(
                                                                AppColors
                                                                    .whiteColor),
                                                      ),
                                                    ),
                                                  )
                                                : Icon(
                                                    Icons.update,
                                                    color: isSeriesFocused
                                                        ? AppColors.primryColor
                                                        : AppColors.whiteColor,
                                                  ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
      // body: selectedType == 0
      //     ? const LiveScreen()
      //     : selectedType == 1
      //         ? const MovieScreen()
      //         : const SeriesScreen()
    );
  }

  // body: FijkView(
  //   player: controller,
  // ),
  //  expandedVideo
  //     ? InkWell(
  //         onTap: () {
  //           setState(() {
  //             showDetails = !showDetails;
  //           });
  //           Future.delayed(
  //             const Duration(
  //               seconds: 2,
  //             ),
  //             () {
  //               if (controller.value.state != FijkState.paused) {
  //                 setState(() {
  //                   showDetails = false;
  //                 });
  //               }
  //             },
  //           );
  //         },
  //         child: Container(
  //           width: Get.width,
  //           color: AppColors.blackColor,
  //           child: Expanded(
  //             child: Stack(
  //               children: [
  //                 SizedBox(
  //                   width: Get.width,
  //                   child: FijkView(player: controller),
  //                 ),
  //                 isLoading
  //                     ? const Positioned(
  //                         left: 0,
  //                         right: 0,
  //                         bottom: 0,
  //                         top: 0,
  //                         child: Center(
  //                           child: CircularProgressIndicator(),
  //                         ),
  //                       )
  //                     : const SizedBox(),
  //                 showDetails
  //                     ? Positioned(
  //                         top: 0,
  //                         bottom: 0,
  //                         left: 0,
  //                         right: 0,
  //                         child: Container(
  //                           color: AppColors.blackColor.withValues(alpha: 0.5),
  //                           child: Column(
  //                             mainAxisAlignment: MainAxisAlignment.center,
  //                             children: [
  //                               const Spacer(),
  //                               IconButton(
  //                                   onPressed: () async {
  //                                     if (controller.value.state !=
  //                                         FijkState.paused) {
  //                                       controller.pause();
  //                                       setState(() {
  //                                         showDetails = true;
  //                                       });
  //                                     } else {
  //                                       setState(() {
  //                                         isLoading = true;
  //                                       });
  //                                       try {
  //                                         var response = await http.get(
  //                                             Uri.parse(
  //                                                 '${ApiSettings.channelUrl}$streamId.ts'));
  //                                         if (response.statusCode == 200) {
  //                                           controller.setDataSource(
  //                                             '${ApiSettings.channelUrl}$streamId.ts',
  //                                             autoPlay: true,
  //                                           );
  //                                         } else {
  //                                           setState(() {
  //                                             controller.dispose();
  //                                             isLoading = false;
  //                                             errorText =
  //                                                 'Unable to load the stream';
  //                                           });
  //                                         }
  //                                       } catch (e) {
  //                                         setState(() {
  //                                           controller.dispose();
  //                                           isLoading = false;
  //                                           errorText =
  //                                               'Unable to load the stream';
  //                                         });
  //                                       }
  //                                       setState(() {
  //                                         showDetails = false;
  //                                       });
  //                                     }
  //                                   },
  //                                   icon: controller.value.state !=
  //                                           FijkState.paused
  //                                       ? const Icon(
  //                                           Icons.pause,
  //                                           color: AppColors.whiteColor,
  //                                         )
  //                                       : const Icon(Icons.play_arrow,
  //                                           color: AppColors.whiteColor)),
  //                               const Spacer(),
  //                               Align(
  //                                 alignment: AlignmentDirectional.centerEnd,
  //                                 child: IconButton(
  //                                     onPressed: () {
  //                                       setState(() {
  //                                         expandedVideo = false;
  //                                       });
  //                                     },
  //                                     icon: const Icon(
  //                                       Icons.fullscreen_exit,
  //                                       color: AppColors.whiteColor,
  //                                     )),
  //                               )
  //                             ],
  //                           ),
  //                         ))
  //                     : const SizedBox(),
  //               ],
  //             ),
  //           ),
  //         ),
  //       )
  //     : Row(
  //         children: [
  //           Container(
  //             padding: const EdgeInsets.symmetric(horizontal: 10),
  //             margin: const EdgeInsets.all(10),
  //             height: Get.height,
  //             width: 250,
  //             decoration: const BoxDecoration(
  //               color: Colors.pink,
  //             ),
  //             child: Column(
  //               children: [
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     IconButton(
  //                         onPressed: () {
  //                           if (homeGetxController.categoryIndex.value >
  //                               0) {
  //                             homeGetxController.categoryIndex.value--;
  //                           } else {
  //                             homeGetxController.categoryIndex.value =
  //                                 homeGetxController.categories.length - 1;
  //                           }
  //                           homeGetxController.filterStreams();
  //                         },
  //                         icon: const Icon(
  //                           Icons.arrow_back_ios,
  //                           color: AppColors.whiteColor,
  //                           size: 15,
  //                         )),
  //                     Obx(() {
  //                       if (homeGetxController.isLoadingCategory.value) {
  //                         return const Text('');
  //                       } else if (homeGetxController
  //                           .categories.isNotEmpty) {
  //                         return Text(
  //                             homeGetxController
  //                                     .categories[homeGetxController
  //                                         .categoryIndex.value]
  //                                     .categoryName ??
  //                                 '',
  //                             style: AppStyles().font12(
  //                               color: AppColors.whiteColor,
  //                               fontWeight: FontWeight.w300,
  //                             ));
  //                       } else {
  //                         return Text('',
  //                             style: AppStyles().font12(
  //                               color: AppColors.whiteColor,
  //                               fontWeight: FontWeight.w300,
  //                             ));
  //                       }
  //                     }),
  //                     IconButton(
  //                         onPressed: () {
  //                           if (homeGetxController.categoryIndex.value <
  //                               homeGetxController.categories.length - 1) {
  //                             homeGetxController.categoryIndex.value++;
  //                           } else {
  //                             homeGetxController.categoryIndex.value = 0;
  //                           }
  //                           homeGetxController.filterStreams();
  //                         },
  //                         icon: const Icon(
  //                           Icons.arrow_forward_ios,
  //                           size: 15,
  //                           color: AppColors.whiteColor,
  //                         )),
  //                   ],
  //                 ),
  //                 const Divider(),
  //                 Expanded(child: Obx(() {
  //                   if (homeGetxController.isLoadingStream.value) {
  //                     return const Center(
  //                       child: CircularProgressIndicator(
  //                         color: AppColors.whiteColor,
  //                       ),
  //                     );
  //                   } else if (homeGetxController
  //                       .streamsFilterd.isNotEmpty) {
  //                     return ListView.separated(
  //                         separatorBuilder: (context, index) {
  //                           return const Divider();
  //                         },
  //                         shrinkWrap: true,
  //                         itemCount:
  //                             homeGetxController.streamsFilterd.length,
  //                         padding: const EdgeInsets.symmetric(vertical: 3),
  //                         itemBuilder: (context, index) {
  //                           return InkWell(
  //                             onTap: () async {
  //                               print(
  //                                   '================${ApiSettings.channelUrl}${homeGetxController.streamsFilterd[index].streamId}${homeGetxController.streamsFilterd[index].streamType == 'live' ? '.ts' : '.mp4'}');

  //                               streamId = homeGetxController
  //                                   .streamsFilterd[index].streamId;
  //                               setState(() {
  //                                 isLoading = true;
  //                                 errorText = '';
  //                               });
  //                               try {
  //                                 var response = await http.get(Uri.parse(
  //                                     '${ApiSettings.channelUrl}${homeGetxController.streamsFilterd[index].streamId}${homeGetxController.streamsFilterd[index].streamType == 'live' ? '.ts' : '.mp4'}'));

  //                                 if (response.statusCode == 200) {
  //                                   controller.setDataSource(
  //                                     '${ApiSettings.channelUrl}${homeGetxController.streamsFilterd[index].streamId}${homeGetxController.streamsFilterd[index].streamType == 'live' ? '.ts ' : '.mp4'}',
  //                                     autoPlay: true,
  //                                   );
  //                                 } else {
  //                                   setState(() {
  //                                     controller.dispose();
  //                                     isLoading = false;
  //                                     errorText =
  //                                         'Unable to load the stream';
  //                                   });
  //                                 }
  //                               } catch (e) {
  //                                 setState(() {
  //                                   controller.dispose();
  //                                   isLoading = false;
  //                                   errorText = 'Unable to load the stream';
  //                                 });
  //                               }
  //                             },
  //                             child: Row(
  //                               mainAxisAlignment:
  //                                   MainAxisAlignment.spaceBetween,
  //                               children: [
  //                                 Row(
  //                                   children: [
  //                                     Text((index + 1).toString(),
  //                                         style: AppStyles().font12(
  //                                           color: AppColors.whiteColor,
  //                                           fontWeight: FontWeight.w300,
  //                                         )),
  //                                     const SizedBox(
  //                                       width: 10,
  //                                     ),
  //                                     //صورة ابقناة
  //                                     // homeGetxController
  //                                     //                 .streamsFilterd[index]
  //                                     //                 .streamIcon !=
  //                                     //             null &&
  //                                     //         homeGetxController
  //                                     //             .streamsFilterd[index]
  //                                     //             .streamIcon!
  //                                     //             .isNotEmpty
  //                                     //     ? Image.network(
  //                                     //         homeGetxController
  //                                     //             .streamsFilterd[index]
  //                                     //             .streamIcon!,
  //                                     //         width: 40,
  //                                     //         height: 40,
  //                                     //       )
  //                                     //     :
  //                                     Image.asset(
  //                                       'images/new_logo.jpg',
  //                                       color: Colors.white,
  //                                       width: 40,
  //                                       height: 40,
  //                                     ),
  //                                   ],
  //                                 ),
  //                                 Row(
  //                                   mainAxisAlignment:
  //                                       MainAxisAlignment.spaceBetween,
  //                                   children: [
  //                                     SizedBox(
  //                                       width: 100,
  //                                       child: Text(
  //                                           homeGetxController
  //                                                   .streamsFilterd[index]
  //                                                   .name ??
  //                                               'Name',
  //                                           textAlign: TextAlign.end,
  //                                           style: AppStyles().font12(
  //                                             color: AppColors.whiteColor,
  //                                             fontWeight: FontWeight.w300,
  //                                           )),
  //                                     ),
  //                                   ],
  //                                 ),
  //                               ],
  //                             ),
  //                           );
  //                         });
  //                   } else {
  //                     return Expanded(
  //                       child: Center(
  //                         child: Text('No Data'.tr,
  //                             style: AppStyles().font12(
  //                               color: AppColors.whiteColor,
  //                               fontWeight: FontWeight.w300,
  //                             )),
  //                       ),
  //                     );
  //                   }
  //                 })),
  //               ],
  //             ),
  //           ),
  //           // controller.isPlayable()
  //           //     ? Padding(
  //           //         padding: const EdgeInsets.all(8.0),
  //           //         child: InkWell(
  //           //           onTap: () {
  //           //             setState(() {
  //           //               showDetails = !showDetails;
  //           //             });
  //           //             Future.delayed(
  //           //               const Duration(
  //           //                 seconds: 2,
  //           //               ),
  //           //               () {
  //           //                 if (controller.value.state !=
  //           //                     FijkState.paused) {
  //           //                   setState(() {
  //           //                     showDetails = false;
  //           //                   });
  //           //                 }
  //           //               },
  //           //             );
  //           //           },
  //           //           child: Container(
  //           //             color: AppColors.blackColor,
  //           //             child: Expanded(
  //           //               child: Stack(
  //           //                 children: [
  //           //                   AspectRatio(
  //           //                     aspectRatio: controller!.value.aspectRatio,
  //           //                     child: VideoPlayer(controller!),
  //           //                   ),
  //           //                   isLoading
  //           //                       ? const Positioned(
  //           //                           left: 0,
  //           //                           right: 0,
  //           //                           bottom: 0,
  //           //                           top: 0,
  //           //                           child: Center(
  //           //                             child: CircularProgressIndicator(),
  //           //                           ),
  //           //                         )
  //           //                       : const SizedBox(),
  //           //                   showDetails
  //           //                       ? Positioned(
  //           //                           top: 0,
  //           //                           bottom: 0,
  //           //                           left: 0,
  //           //                           right: 0,
  //           //                           child: Container(
  //           //                             color: AppColors.blackColor
  //           //                                 .withValues(alpha: 0.5),
  //           //                             child: Column(
  //           //                               mainAxisAlignment:
  //           //                                   MainAxisAlignment.center,
  //           //                               children: [
  //           //                                 const Spacer(),
  //           //                                 IconButton(
  //           //                                     onPressed: () async {
  //           //                                       if (controller!
  //           //                                           .value.isPlaying) {
  //           //                                         controller!.pause();
  //           //                                         setState(() {
  //           //                                           showDetails = true;
  //           //                                         });
  //           //                                       } else {
  //           //                                         setState(() {
  //           //                                           isLoading = true;
  //           //                                         });
  //           //                                         try {
  //           //                                           var response = await http
  //           //                                               .get(Uri.parse(
  //           //                                                   '${ApiSettings.channelUrl}$streamId.ts'));
  //           //                                           if (response
  //           //                                                   .statusCode ==
  //           //                                               200) {
  //           //                                             controller =
  //           //                                                 VideoPlayerController
  //           //                                                     .networkUrl(
  //           //                                               Uri.parse(
  //           //                                                   '${ApiSettings.channelUrl}$streamId.ts'),
  //           //                                             )..initialize()
  //           //                                                       .then(
  //           //                                                           (_) {
  //           //                                                     setState(
  //           //                                                         () {
  //           //                                                       isLoading =
  //           //                                                           false;
  //           //                                                       controller!
  //           //                                                           .play();
  //           //                                                     });
  //           //                                                   }).asStream();
  //           //                                           } else {
  //           //                                             setState(() {
  //           //                                               controller
  //           //                                                   ?.dispose();
  //           //                                               isLoading = false;
  //           //                                               errorText =
  //           //                                                   'Unable to load the stream';
  //           //                                             });
  //           //                                           }
  //           //                                         } catch (e) {
  //           //                                           setState(() {
  //           //                                             controller
  //           //                                                 ?.dispose();
  //           //                                             isLoading = false;
  //           //                                             errorText =
  //           //                                                 'Unable to load the stream';
  //           //                                           });
  //           //                                         }
  //           //                                         setState(() {
  //           //                                           showDetails = false;
  //           //                                         });
  //           //                                       }
  //           //                                     },
  //           //                                     icon: controller!
  //           //                                             .value.isPlaying
  //           //                                         ? const Icon(
  //           //                                             Icons.pause,
  //           //                                             color: AppColors
  //           //                                                 .whiteColor,
  //           //                                           )
  //           //                                         : const Icon(
  //           //                                             Icons.play_arrow,
  //           //                                             color: AppColors
  //           //                                                 .whiteColor)),
  //           //                                 const Spacer(),
  //           //                                 Align(
  //           //                                   alignment:
  //           //                                       AlignmentDirectional
  //           //                                           .centerEnd,
  //           //                                   child: IconButton(
  //           //                                       onPressed: () {
  //           //                                         setState(() {
  //           //                                           expandedVideo = true;
  //           //                                         });
  //           //                                       },
  //           //                                       icon: const Icon(
  //           //                                         Icons.fullscreen,
  //           //                                         color: AppColors
  //           //                                             .whiteColor,
  //           //                                       )),
  //           //                                 )
  //           //                               ],
  //           //                             ),
  //           //                           ))
  //           //                       : const SizedBox(),
  //           //                 ],
  //           //               ),
  //           //             ),
  //           //           ),
  //           //         ),
  //           //       )
  //               // : Expanded(
  //               //     child: Stack(
  //               //       children: [
  //               //         Center(
  //               //           child: Text(
  //               //             errorText,
  //               //           ),
  //               //         ),
  //               //         isLoading
  //               //             ? const Center(
  //               //                 child: CircularProgressIndicator(),
  //               //               )
  //               //             : const SizedBox(),
  //               //       ],
  //               //     ),
  //               //   ),
  //           // Expanded(
  //           //     child: AspectRatio(
  //           //   aspectRatio: _videoPlayerController.value.aspectRatio,
  //           //   child: VideoPlayer(_videoPlayerController),
  //           // )),
  //           // Expanded(
  //           //   child: Padding(
  //           //     padding: const EdgeInsets.all(8.0),
  //           //     child: FutureBuilder(
  //           //       future: _initializeVideoPlayerFuture,
  //           //       builder: (context, snapshot) {
  //           //         if (snapshot.connectionState == ConnectionState.done) {
  //           //           return AspectRatio(
  //           //             aspectRatio: _videoPlayerController.value.aspectRatio,
  //           //             child: VideoPlayer(_videoPlayerController),
  //           //           );
  //           //         } else {
  //           //           return const Center(
  //           //             child: CircularProgressIndicator(),
  //           //           );
  //           //         }
  //           //       },
  //           //     ),
  //           //   ),
  //           // ),
  //           // showSearch
  //           //     ? Expanded(
  //           //         child: Obx(() {
  //           //           return ListView.separated(
  //           //               separatorBuilder: (context, index) {
  //           //                 return const Divider();
  //           //               },
  //           //               shrinkWrap: true,
  //           //               itemCount:
  //           //                   homeGetxController.searchFilterd.length,
  //           //               padding: const EdgeInsets.symmetric(vertical: 3),
  //           //               itemBuilder: (context, index) {
  //           //                 return InkWell(
  //           //                   onTap: () async {
  //           //                     streamId = homeGetxController
  //           //                         .searchFilterd[index].streamId;
  //           //                     setState(() {
  //           //                       isLoading = true;
  //           //                       errorText = '';
  //           //                       showSearch = false;
  //           //                       searchController.clear();
  //           //                       homeGetxController.searchStreams(
  //           //                           search: '');
  //           //                     });
  //           //                     try {
  //           //                       var response = await http.get(Uri.parse(
  //           //                           '${ApiSettings.channelUrl}${homeGetxController.searchFilterd[index].streamId}${homeGetxController.searchFilterd[index].streamType == 'live' ? '.ts' : '.mp4'}'));
  //           //                       if (response.statusCode == 200) {
  //           //                         controller =
  //           //                             VideoPlayerController.networkUrl(
  //           //                           Uri.parse(
  //           //                               '${ApiSettings.channelUrl}${homeGetxController.searchFilterd[index].streamId}'),
  //           //                         )..initialize().then((_) {
  //           //                                 setState(() {
  //           //                                   isLoading = false;
  //           //                                   controller!.play();
  //           //                                 });
  //           //                               });
  //           //                       } else {
  //           //                         setState(() {
  //           //                           controller?.dispose();
  //           //                           isLoading = false;
  //           //                           errorText =
  //           //                               'Unable to load the stream';
  //           //                         });
  //           //                       }
  //           //                     } catch (e) {
  //           //                       setState(() {
  //           //                         controller?.dispose();
  //           //                         isLoading = false;
  //           //                         errorText = 'Unable to load the stream';
  //           //                       });
  //           //                     }
  //           //                   },
  //           //                   child: Row(
  //           //                     mainAxisAlignment: MainAxisAlignment.center,
  //           //                     children: [
  //           //                       Row(
  //           //                         children: [
  //           //                           Text((index + 1).toString(),
  //           //                               style: AppStyles().font12(
  //           //                                 color: AppColors.whiteColor,
  //           //                                 fontWeight: FontWeight.w300,
  //           //                               )),
  //           //                           const SizedBox(
  //           //                             width: 10,
  //           //                           ),
  //           //                           //صورة ابقناة
  //           //                           // homeGetxController
  //           //                           //             .searchFilterd[index]
  //           //                           //             .streamIcon !=
  //           //                           //         null
  //           //                           //     ? Image.network(
  //           //                           //         homeGetxController
  //           //                           //             .searchFilterd[index]
  //           //                           //             .streamIcon!,
  //           //                           //         width: 40,
  //           //                           //         height: 40,
  //           //                           //       )
  //           //                           //     :
  //           //                           Image.asset(
  //           //                             'images/new_logo.jpg',
  //           //                             color: Colors.white,
  //           //                             width: 40,
  //           //                             height: 40,
  //           //                           ),
  //           //                         ],
  //           //                       ),
  //           //                       Row(
  //           //                         mainAxisAlignment:
  //           //                             MainAxisAlignment.start,
  //           //                         children: [
  //           //                           SizedBox(
  //           //                             width: 100,
  //           //                             child: Text(
  //           //                                 homeGetxController
  //           //                                         .searchFilterd[index]
  //           //                                         .name ??
  //           //                                     'Name',
  //           //                                 textAlign: TextAlign.end,
  //           //                                 style: AppStyles().font12(
  //           //                                   color: AppColors.blackColor,
  //           //                                   fontWeight: FontWeight.w300,
  //           //                                 )),
  //           //                           ),
  //           //                         ],
  //           //                       ),
  //           //                     ],
  //           //                   ),
  //           //                 );
  //           //               });
  //           //         }),
  //           //       )
  //           //     : const SizedBox()
  //         ],
  //       ),
  // ));

  void getContact() async {
    contactModel = await ApiController().getContact();
  }
}
// }
