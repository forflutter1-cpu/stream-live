import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iptv/Screen/movie_screen/movie_details_screen.dart';
import 'package:iptv/Screen/Widget/appBarrWidget.dart';
import 'package:iptv/Widget/main_image_widget.dart';
import 'package:iptv/api/api_controller/api_controller.dart';
import 'package:iptv/api/api_helper.dart';
import 'package:iptv/app_material/app_colors.dart';
import 'package:iptv/app_material/app_styles.dart';
import 'package:iptv/controller/home_getx_controller.dart';
import 'package:iptv/model/contact_model.dart';
import 'package:iptv/utils/app_helper.dart';
import 'package:iptv/utils/circal_animated.dart';
import 'package:iptv/utils/friendly_routes.dart';
import 'package:shimmer/shimmer.dart';

class MovieScreen extends StatefulWidget {
  const MovieScreen({super.key});

  @override
  State<MovieScreen> createState() => _MovieScreenState();
}

class _MovieScreenState extends State<MovieScreen> with ApiHelper, AppHelper {
  late final HomeGetxController homeGetxController;
  bool isFirst = true;

  ContactModel? contactModel;

  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    homeGetxController = Get.isRegistered<HomeGetxController>()
        ? Get.find<HomeGetxController>()
        : Get.put(HomeGetxController());
    scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureMovieDataLoaded();
    });
  }

  Future<void> _ensureMovieDataLoaded() async {
    if (homeGetxController.movieCategories.isEmpty &&
        !homeGetxController.isLoadingMovieCategory.value) {
      await homeGetxController.getMovieCategories();
    }
    if (homeGetxController.movieStreams.isEmpty &&
        !homeGetxController.isLoadingMovieStream.value) {
      await homeGetxController.getMovieStreams();
    }
    homeGetxController.filterMovieStreams();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBar_Widget(
        showBack: true,
        selectedType: 1,
      ), // drawer: Drawer(),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 45,
              child: Obx(() {
                if (homeGetxController.isLoadingMovieCategory.value) {
                  return Shimmer.fromColors(
                    baseColor: AppColors().baseColor,
                    highlightColor: AppColors().highlightColor,
                    child: ListView.separated(
                        padding: const EdgeInsets.only(
                            left: 5, right: 5, top: 10, bottom: 5),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 100,
                            padding: const EdgeInsets.symmetric(horizontal: 7),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: AppColors.greysub4Color
                                    .withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(12)),
                            child: Text(
                              '',
                              style: AppStyles()
                                  .font14(color: AppColors.blackColor),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return const SizedBox(
                            width: 5,
                          );
                        },
                        itemCount: 10),
                  );
                } else if (homeGetxController.movieCategories.isNotEmpty) {
                  return ListView.separated(
                      padding: const EdgeInsets.only(
                          left: 5, right: 5, top: 10, bottom: 5),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            if (scrollController.hasClients) {
                              scrollController.animateTo(
                                0,
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeIn,
                              );
                            }
                            homeGetxController
                                .changeSelectedMovieCategoryIndex(index);
                            homeGetxController.filterMovieStreams();
                          },
                          child: Obx(() {
                            return Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 7),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  gradient: homeGetxController
                                              .movieCategoryIndex.value ==
                                          index
                                      ? const LinearGradient(
                                          begin: Alignment.topRight,
                                          end: Alignment.topLeft,
                                          colors: [
                                            Colors.yellow,
                                            Colors.red,
                                          ],
                                        )
                                      : LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            AppColors.greysub4Color
                                                .withValues(alpha: 0.5),
                                            AppColors.greysub4Color
                                                .withValues(alpha: 0.5),
                                          ],
                                        ),
                                  // color: homeGetxController
                                  //             .movieCategoryIndex.value ==
                                  //         index
                                  //     ? AppColors.primryColor
                                  //     : AppColors.greysub4Color
                                  //         .withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(6)),
                              child: Text(
                                homeGetxController
                                        .movieCategories[index].categoryName ??
                                    '',
                                style: AppStyles().font14(
                                    color: homeGetxController
                                                .movieCategoryIndex.value ==
                                            index
                                        ? AppColors.whiteColor
                                        : AppColors.blackColor),
                              ),
                            );
                          }),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const SizedBox(
                          width: 5,
                        );
                      },
                      itemCount: homeGetxController.movieCategories.length);
                } else {
                  return const SizedBox();
                }
              }),
            ),
            const SizedBox(
              height: 5,
            ),
            Expanded(child: Obx(() {
              if (homeGetxController.movieStreams.isNotEmpty && isFirst) {
                homeGetxController.filterMovieStreams();
                isFirst = false;
              }
              if (homeGetxController.isLoadingMovieStream.value) {
                return const Center(
                  child: AnimatedCircle(),
                );
              } else if (homeGetxController.movieStreamsFilterd.isNotEmpty) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final maxExtent = width >= 1200
                        ? 190.0
                        : width >= 800
                            ? 170.0
                            : width >= 520
                                ? 150.0
                                : 135.0;
                    final posterHeight = width >= 800 ? 174.0 : 152.0;
                    final itemHeight = posterHeight + 62;
                    return GridView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: homeGetxController.movieStreamsFilterd.length,
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: maxExtent,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 8,
                        mainAxisExtent: itemHeight,
                      ),
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            final stream =
                                homeGetxController.movieStreamsFilterd[index];
                            if (kIsWeb && stream.streamId != null) {
                              Get.toNamed(movieRoute(stream),
                                  arguments: stream);
                              return;
                            }
                            Get.to(
                              () => MovieDetailsScreen(
                                streamModel: stream,
                                isMovie: true,
                              ),
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeIn,
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: AppColors.whiteColor,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: const [
                                  BoxShadow(
                                      blurRadius: 6,
                                      offset: Offset(0, 3),
                                      color: Colors.black12)
                                ]),
                            padding: const EdgeInsets.all(5),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 5),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                MainImageWidget(
                                  image: homeGetxController
                                      .movieStreamsFilterd[index].streamIcon,
                                  height: posterHeight,
                                  fit: BoxFit.fill,
                                  radius: 8,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5.0),
                                  child: Text(
                                    homeGetxController
                                            .movieStreamsFilterd[index].name ??
                                        '',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              } else {
                return const Center(
                  child: Text('لا يوجد افلام لهذا القسم'),
                );
              }
            }))
          ],
        ),
      ),
    );
  }

  void getContact() async {
    contactModel = await ApiController().getContact();
  }
}
