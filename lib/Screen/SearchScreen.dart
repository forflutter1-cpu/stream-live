import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:iptv/Screen/Widget/appBarrWidget.dart';
import 'package:iptv/Screen/bn_screens/live_screen.dart';
import 'package:iptv/Screen/movie_screen/movie_details_screen.dart';
import 'package:iptv/Widget/main_image_widget.dart';
import 'package:iptv/Widget/textFiled_widget.dart';
import 'package:iptv/app_material/app_colors.dart';
import 'package:iptv/app_material/app_styles.dart';
import 'package:iptv/controller/home_getx_controller.dart';
import 'package:iptv/model/stream_model.dart';
import 'package:iptv/utils/friendly_routes.dart';
import 'package:iptv/utils/stream_url_builder.dart';

class SearchScreen extends StatefulWidget {
  final int selectedType;
  const SearchScreen({super.key, this.selectedType = 0});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final HomeGetxController homeGetxController = Get.find();
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  int selectedType = 0;

  @override
  void initState() {
    super.initState();
    selectedType = widget.selectedType;

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 100) {
        homeGetxController.loadNextPage();
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    searchController.dispose();
    homeGetxController.searchFilterd.clear();
    super.dispose();
  }

  void _triggerSearch() {
    FocusScope.of(context).unfocus();
    homeGetxController.searchStreams(
      search: searchController.text,
      selectedType: selectedType,
    );
  }

  Widget _buildFilterButton(String label, int type) {
    final bool isSelected = selectedType == type;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            selectedType = type;
          });
          if (searchController.text.isNotEmpty) _triggerSearch();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primryColor
                : AppColors.greysub4Color.withAlpha(160),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: AppStyles().font14(
              color: isSelected ? AppColors.whiteColor : AppColors.blackColor,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBar_Widget(),
      body: ListView(
        controller: scrollController,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            child: SizedBox(
              height: 42,
              child: Row(
                children: [
                  _buildFilterButton('بث مباشر', 0),
                  const SizedBox(width: 15),
                  _buildFilterButton('أفلام', 1),
                  const SizedBox(width: 15),
                  _buildFilterButton('مسلسلات', 2),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 10),
            child: TextFiled_Widget(
              controller: searchController,
              textInputType: TextInputType.text,
              textInputAction: TextInputAction.search,
              hintText: 'بحث',
              onEditingComplete: _triggerSearch,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: Obx(() {
                final items = homeGetxController.searchFilterd;
                final isLoading = homeGetxController.isLoadingFilter.value;

                if (isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // ✅ عرض عناصر عشوائية قبل البحث
                if (searchController.text.isEmpty) {
                  List<StreamModel> defaultItems = [];
                  if (selectedType == 0) {
                    defaultItems = homeGetxController.streams.take(6).toList();
                  } else if (selectedType == 1) {
                    defaultItems =
                        homeGetxController.movieStreams.take(6).toList();
                  } else {
                    defaultItems = homeGetxController.seriesStreams
                        .take(6)
                        .map((e) => StreamModel(
                              added: e.added,
                              categoryId: e.categoryId,
                              name: e.name,
                              num: e.num,
                              epgChannelId: e.epgChannelId,
                              streamIcon: e.streamIcon,
                              streamId: e.streamId is int
                                  ? e.streamId
                                  : int.tryParse(e.streamId?.toString() ?? ''),
                              streamType: e.streamType,
                              plot: e.plot,
                              cast: e.cast,
                              director: e.director,
                              genre: e.genre,
                              releaseDate: e.releaseDate,
                              rating: e.rating,
                              backdropPath: e.backdropPath,
                              youtubeTrailer: e.youtubeTrailer,
                              episodeRunTime: e.episodeRunTime,
                            ))
                        .toList();
                  }

                  return _buildResultGrid(defaultItems);
                }

                // ✅ البحث تم، لكن لا توجد نتائج
                if (items.isEmpty) {
                  List<StreamModel> suggestions = [];
                  if (selectedType == 0) {
                    suggestions = homeGetxController.streams.take(3).toList();
                  } else if (selectedType == 1) {
                    suggestions =
                        homeGetxController.movieStreams.take(3).toList();
                  } else {
                    suggestions = homeGetxController.seriesStreams
                        .take(3)
                        .map((e) => StreamModel(
                              added: e.added,
                              categoryId: e.categoryId,
                              name: e.name,
                              num: e.num,
                              epgChannelId: e.epgChannelId,
                              streamIcon: e.streamIcon,
                              streamId: e.streamId is int
                                  ? e.streamId
                                  : int.tryParse(e.streamId?.toString() ?? ''),
                              streamType: e.streamType,
                              plot: e.plot,
                              cast: e.cast,
                              director: e.director,
                              genre: e.genre,
                              releaseDate: e.releaseDate,
                              rating: e.rating,
                              backdropPath: e.backdropPath,
                              youtubeTrailer: e.youtubeTrailer,
                              episodeRunTime: e.episodeRunTime,
                            ))
                        .toList();
                  }

                  return Column(
                    children: [
                      SvgPicture.asset('images/empty.svg', height: 60),
                      const SizedBox(height: 10),
                      Text(
                        'لا توجد نتائج',
                        style: AppStyles().font14(
                          fontWeight: FontWeight.w300,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'اقتراحات:',
                        style: AppStyles().font14(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primryColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildResultGrid(suggestions),
                    ],
                  );
                }

                // ✅ عرض النتائج الفعلية من البحث
                return _buildResultGrid(items);
              })),
        ],
      ),
    );
  }

  Widget _buildResultGrid(List<StreamModel> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: (1 / .4),
        mainAxisExtent: 150,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return InkWell(
          onTap: () {
            if (selectedType != 0) {
              if (kIsWeb && item.streamId != null) {
                Get.toNamed(
                  selectedType == 1
                      ? movieRoute(item)
                      : seriesRouteFromStream(item),
                  arguments: item,
                );
                return;
              }
              Get.to(() => MovieDetailsScreen(
                    streamModel: item,
                    isMovie: selectedType == 1,
                  ));
            } else {
              homeGetxController.changeSelectedStreamName(item.name ?? '');
              homeGetxController.changeSelectedCategoryIndex(
                homeGetxController.categories.indexWhere(
                  (cat) => cat.categoryId == item.categoryId,
                ),
              );

              if (kIsWeb && item.streamId != null) {
                Get.toNamed(liveRoute(item), arguments: item);
                return;
              }

              final url = streamPlaybackUrl(item);

              Get.to(() => LiveScreen(
                    url: url,
                    name: item.name,
                  ));
            }
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                )
              ],
            ),
            child: Row(
              children: [
                MainImageWidget(
                  image: item.streamIcon,
                  height: 80,
                  width: 60,
                  fit: BoxFit.cover,
                  radius: 8,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.name ?? '',
                        overflow: TextOverflow.ellipsis,
                        style: AppStyles().font14(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primryColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'القسم: ${homeGetxController.getCategoryName(categoryId: item.categoryId ?? '', selectedType: selectedType)}',
                        style: AppStyles().font12(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
