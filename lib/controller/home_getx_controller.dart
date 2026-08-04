import 'package:get/get.dart';
import 'package:iptv/api/api_controller/api_controller.dart';
import 'package:iptv/database/database_helper.dart';
import 'package:iptv/model/category_model.dart';
import 'package:iptv/model/movie_derails_model.dart';
import 'package:iptv/model/series_details_model.dart';
import 'package:iptv/model/stream_model.dart';
import 'package:iptv/model/stream_series_model.dart';

class HomeGetxController extends GetxController {
  RxBool isLoadingCategory = false.obs;
  RxBool isLoadingStream = false.obs;
  RxBool isLoadingFilter = false.obs;
  RxBool isLoadingMovieCategory = false.obs;
  RxBool isLoadingMovieStream = false.obs;
  RxBool isLoadingMovieDetials = false.obs;
  RxBool isLoadingSeriesCategory = false.obs;
  RxBool isLoadingSeriesStream = false.obs;
  int _currentPage = 0;
  final int _pageSize = 10;
  List<StreamModel> allSearchResults = [];
  RxList<Seasons> seasons = <Seasons>[].obs;

  RxList<CategoryModel> categories = <CategoryModel>[].obs;
  RxList<StreamModel> streams = <StreamModel>[].obs;
  RxList<CategoryModel> movieCategories = <CategoryModel>[].obs;
  RxList<CategoryModel> seriesCategories = <CategoryModel>[].obs;
  RxList<StreamModel> movieStreams = <StreamModel>[].obs;
  RxList<StreamModel> movieStreamsFilterd = <StreamModel>[].obs;
  RxList<StreamSeriesModel> seriesStreamsFilterd = <StreamSeriesModel>[].obs;
  RxList<StreamModel> streamsFilterd = <StreamModel>[].obs;
  RxList<StreamModel> searchFilterd = <StreamModel>[].obs;
  RxList<StreamSeriesModel> seriesStreams = <StreamSeriesModel>[].obs;
  RxInt categoryIndex = 0.obs;
  RxInt movieCategoryIndex = 0.obs;
  RxInt seriesCategoryIndex = 0.obs;
  RxInt selectedSeriesSesonIndex = 0.obs;
  RxInt selectedSeriesEpisodesIndex = 0.obs;
  RxInt streamPrcent = 0.obs;
  RxInt movieStreamPrcent = 0.obs;
  RxInt seriesStreamPrcent = 0.obs;
  RxString selectedStreamName = ''.obs;

  MovieDetailsModel? movieDetails;
  SeriesDetailsModel? seriesDetails;

  Future<void> getCategories({bool load = true, bool clearData = false}) async {
    if (load) {
      isLoadingCategory.value = true;
    }

    final dbHelper = DatabaseHelper.instance;
    if (clearData) {
      await dbHelper.clearCategories();
    }
    List<CategoryModel> localCategories = await dbHelper.getAllCategories();
    if (localCategories.isNotEmpty) {
      categories.clear();
      categories.addAll(localCategories);
      _dedupeAndSortCategories(categories);
    } else {
      var newCategories = await ApiController().getCategories();
      categories.clear();
      categories.addAll(newCategories);
      _dedupeAndSortCategories(categories);
      for (var category in newCategories) {
        await dbHelper.insertCategory(category);
      }
    }

    if (load) {
      isLoadingCategory.value = false;
    }
  }

  void getSeasonsFromEpisodes() {
    seasons.clear();

    final countsBySeason = seriesDetails?.episodes?.countsBySeason;

    if (countsBySeason == null || countsBySeason.isEmpty) return;

    countsBySeason.forEach((seasonKey, episodeList) {
      final int seasonNumber = int.tryParse(seasonKey) ?? 0;
      final int episodeCount = episodeList.length;
      final firstEpisodeInfo =
          episodeList.isNotEmpty ? episodeList.first.info : null;

      seasons.add(Seasons(
        seasonNumber: seasonNumber,
        episodeCount: episodeCount,
        name: 'Season $seasonNumber',
        overview: firstEpisodeInfo?.plot,
        cover: firstEpisodeInfo?.movieImage,
      ));
    });

    seasons
        .sort((a, b) => (a.seasonNumber ?? 0).compareTo(b.seasonNumber ?? 0));
  }

  Future<void> getStreams({bool load = true, bool clearData = false}) async {
    if (load) {
      isLoadingStream.value = true;
    }

    final dbHelper = DatabaseHelper.instance;
    if (clearData) {
      await dbHelper.clearStreams();
    }
    List<StreamModel> localStreams = await dbHelper.getAllStreams();
    streams.clear();

    if (localStreams.isNotEmpty) {
      streams.addAll(localStreams);
    } else {
      var newStreams = await ApiController().getStreams(
        onProgress: (p0) {
          streamPrcent.value = (p0 * 100).toInt();
        },
      );
      streams.clear();
      streams.addAll(newStreams);
    }

    if (load) {
      isLoadingStream.value = false;
      streamPrcent.value = 0;
    }
  }

  Future<void> getMovieCategories(
      {bool load = true, bool clearData = false}) async {
    if (load) {
      isLoadingMovieCategory.value = true;
    }

    final dbHelper = DatabaseHelper.instance;
    if (clearData) {
      await dbHelper.clearMovieCategories();
    }
    List<CategoryModel> localMovieCategories =
        await dbHelper.getAllMovieCategories();
    if (localMovieCategories.isNotEmpty) {
      movieCategories.clear();
      movieCategories.addAll(localMovieCategories);
      _dedupeAndSortCategories(movieCategories);
    } else {
      var newMovieCategories = await ApiController().getMovieCategories();
      movieCategories.clear();
      movieCategories.addAll(newMovieCategories);
      _dedupeAndSortCategories(movieCategories);
      for (var category in newMovieCategories) {
        await dbHelper.insertMovieCategory(category);
      }
    }

    if (load) {
      isLoadingMovieCategory.value = false;
    }
  }

  Future<void> getMovieStreams(
      {bool load = true, bool clearData = false}) async {
    if (load) {
      isLoadingMovieStream.value = true;
    }

    final dbHelper = DatabaseHelper.instance;
    if (clearData) {
      await dbHelper.clearMovieStreams();
    }

    List<StreamModel> localMovieStreams = await dbHelper.getAllMovieStreams();

    movieStreams.clear();

    if (localMovieStreams.isNotEmpty) {
      movieStreams.clear();
      movieStreams.addAll(localMovieStreams);
    } else {
      var newMovieStreams = await ApiController().getMovieStreams(
        onProgress: (p0) {
          movieStreamPrcent.value = (p0 * 100).toInt();
        },
      );
      movieStreams.clear();
      movieStreams.addAll(newMovieStreams);
    }

    if (load) {
      isLoadingMovieStream.value = false;
      movieStreamPrcent.value = 0;
    }
  }

  void filterStreams({bool load = true}) {
    streamsFilterd.clear();
    if (streams.isEmpty || categories.isEmpty) {
      if (load) isLoadingStream.value = false;
      return;
    }

    if (categoryIndex.value < 0 || categoryIndex.value >= categories.length) {
      categoryIndex.value = 0;
    }

    void addStreamsForSelectedCategory() {
      final selectedCategoryId = categories[categoryIndex.value].categoryId;
      for (var stream in streams) {
        if (stream.categoryId == selectedCategoryId) {
          streamsFilterd.add(stream);
        }
      }
    }

    addStreamsForSelectedCategory();
    if (streamsFilterd.isEmpty) {
      for (var index = 0; index < categories.length; index++) {
        final categoryId = categories[index].categoryId;
        final hasStreams =
            streams.any((stream) => stream.categoryId == categoryId);
        if (hasStreams) {
          categoryIndex.value = index;
          addStreamsForSelectedCategory();
          break;
        }
      }
    }

    if (load) {
      isLoadingStream.value = false;
    }
  }

  void filterMovieStreams({bool load = true}) {
    if (load) {
      isLoadingMovieStream.value = false;
    }
    movieStreamsFilterd.clear();

    if (movieStreams.isEmpty) {
      return;
    }

    if (movieCategories.isEmpty) {
      movieStreamsFilterd.addAll(movieStreams);
      return;
    }

    if (movieCategoryIndex.value < 0 ||
        movieCategoryIndex.value >= movieCategories.length) {
      movieCategoryIndex.value = 0;
    }

    void addMoviesForSelectedCategory() {
      final selectedCategoryId =
          movieCategories[movieCategoryIndex.value].categoryId;
      movieStreamsFilterd.addAll(
        movieStreams.where((stream) => stream.categoryId == selectedCategoryId),
      );
    }

    addMoviesForSelectedCategory();
    if (movieStreamsFilterd.isEmpty) {
      for (var index = 0; index < movieCategories.length; index++) {
        final categoryId = movieCategories[index].categoryId;
        final hasMovies =
            movieStreams.any((stream) => stream.categoryId == categoryId);
        if (hasMovies) {
          movieCategoryIndex.value = index;
          addMoviesForSelectedCategory();
          break;
        }
      }
    }
  }

  void searchStreams({
    required String search,
    required int selectedType,
    bool load = true,
  }) async {
    if (load) isLoadingFilter.value = true;

    await Future.delayed(const Duration(milliseconds: 300)); // يشبه debounce

    allSearchResults.clear();
    searchFilterd.clear();
    _currentPage = 0;

    List<StreamModel> source = [];

    if (selectedType == 0) {
      source = streams;
    } else if (selectedType == 1) {
      source = movieStreams;
    } else {
      for (var stream in seriesStreams) {
        if (stream.name!.toLowerCase().contains(search.toLowerCase())) {
          allSearchResults.add(StreamModel(
            added: stream.added,
            categoryId: stream.categoryId,
            name: stream.name,
            num: stream.num,
            epgChannelId: stream.epgChannelId,
            streamIcon: stream.streamIcon,
            streamId: stream.streamId is int
                ? stream.streamId
                : int.tryParse(stream.streamId?.toString() ?? ''),
            streamType: stream.streamType,
            plot: stream.plot,
            cast: stream.cast,
            director: stream.director,
            genre: stream.genre,
            releaseDate: stream.releaseDate,
            rating: stream.rating,
            backdropPath: stream.backdropPath,
            youtubeTrailer: stream.youtubeTrailer,
            episodeRunTime: stream.episodeRunTime,
          ));
        }
      }
    }

    if (selectedType != 2) {
      for (var stream in source) {
        if (stream.name!.toLowerCase().contains(search.toLowerCase())) {
          allSearchResults.add(stream);
        }
      }
    }

    loadNextPage();

    if (load) isLoadingFilter.value = false;
  }

  void loadNextPage() {
    int start = _currentPage * _pageSize;
    int end = start + _pageSize;

    if (start < allSearchResults.length) {
      searchFilterd.addAll(
        allSearchResults.sublist(
          start,
          end > allSearchResults.length ? allSearchResults.length : end,
        ),
      );
      _currentPage++;
    }
  }

  void getMovieDetails({required String id, required bool isMovie}) async {
    isLoadingMovieDetials.value = true;
    MovieOrSeriesDetails? movieOrSeriesDetails =
        await ApiController().getMovieDetails(id: id, isMovie: isMovie);
    if (movieOrSeriesDetails?.movieDetails != null) {
      movieDetails = movieOrSeriesDetails!.movieDetails;
    }
    if (movieOrSeriesDetails?.seriesDetails != null) {
      seriesDetails = movieOrSeriesDetails!.seriesDetails;
    }
    isLoadingMovieDetials.value = false;
  }

  Future<void> getSeriesCategories(
      {bool load = true, bool clearData = false}) async {
    if (load) {
      isLoadingSeriesCategory.value = true;
    }

    final dbHelper = DatabaseHelper.instance;
    if (clearData) {
      await dbHelper.clearSeriesCategories();
    }
    List<CategoryModel> localSeriesCategories =
        await dbHelper.getAllSeriesCategories();
    if (localSeriesCategories.isNotEmpty) {
      seriesCategories.clear();
      seriesCategories.addAll(localSeriesCategories);
      _dedupeAndSortCategories(seriesCategories);
    } else {
      var newSerieseCategories = await ApiController().getSeriesCategories();
      seriesCategories.clear();
      seriesCategories.addAll(newSerieseCategories);
      _dedupeAndSortCategories(seriesCategories);
      for (var category in newSerieseCategories) {
        await dbHelper.insertSeriesCategory(category);
      }
    }

    if (load) {
      isLoadingSeriesCategory.value = false;
    }
  }

  Future<void> getSeriesStreams(
      {bool load = true, bool clearData = false}) async {
    if (load) {
      isLoadingSeriesStream.value = true;
    }

    final dbHelper = DatabaseHelper.instance;
    if (clearData) {
      await dbHelper.clearSeriesStreams();
    }

    List<StreamSeriesModel> localSeriesStreams =
        await dbHelper.getAllSeriesStreams();
    seriesStreams.clear();

    if (localSeriesStreams.isNotEmpty) {
      seriesStreams.clear();
      seriesStreams.addAll(localSeriesStreams);
    } else {
      var newSeriesStreams = await ApiController().getSeriesStreams(
        onProgress: (p0) {
          seriesStreamPrcent.value = (p0 * 100).toInt();
        },
      );
      seriesStreams.clear();
      seriesStreams.addAll(newSeriesStreams);
    }

    if (load) {
      isLoadingSeriesStream.value = false;
      seriesStreamPrcent.value = 0;
    }
  }

  void filterSeriesStreams({bool load = true}) {
    if (load) {
      isLoadingSeriesStream.value = false;
    }
    seriesStreamsFilterd.clear();

    if (seriesStreams.isEmpty) {
      return;
    }

    if (seriesCategories.isEmpty) {
      seriesStreamsFilterd.addAll(seriesStreams);
      return;
    }

    if (seriesCategoryIndex.value < 0 ||
        seriesCategoryIndex.value >= seriesCategories.length) {
      seriesCategoryIndex.value = 0;
    }

    void addSeriesForSelectedCategory() {
      final selectedCategoryId =
          seriesCategories[seriesCategoryIndex.value].categoryId;
      seriesStreamsFilterd.addAll(
        seriesStreams
            .where((stream) => stream.categoryId == selectedCategoryId),
      );
    }

    addSeriesForSelectedCategory();
    if (seriesStreamsFilterd.isEmpty) {
      for (var index = 0; index < seriesCategories.length; index++) {
        final categoryId = seriesCategories[index].categoryId;
        final hasSeries =
            seriesStreams.any((stream) => stream.categoryId == categoryId);
        if (hasSeries) {
          seriesCategoryIndex.value = index;
          addSeriesForSelectedCategory();
          break;
        }
      }
    }
  }

  String getCategoryName({
    required String categoryId,
    required int selectedType,
  }) {
    switch (selectedType) {
      case 0:
        return categories
                .firstWhere(
                  (element) => element.categoryId == categoryId,
                  orElse: () =>
                      CategoryModel(categoryId: '', categoryName: 'غير مصنف'),
                )
                .categoryName ??
            'غير مصنف';

      case 1:
        return movieCategories
                .firstWhere(
                  (element) => element.categoryId == categoryId,
                  orElse: () =>
                      CategoryModel(categoryId: '', categoryName: 'غير مصنف'),
                )
                .categoryName ??
            'غير مصنف';

      case 2:
        return seriesCategories
                .firstWhere(
                  (element) => element.categoryId == categoryId,
                  orElse: () =>
                      CategoryModel(categoryId: '', categoryName: 'غير مصنف'),
                )
                .categoryName ??
            'غير مصنف';

      default:
        return 'غير مصنف';
    }
  }

  void changeSelectedStreamName(String name) {
    selectedStreamName.value = name;
  }

  void changeSelectedCategoryIndex(int index) {
    categoryIndex.value = index;
  }

  void changeSelectedMovieCategoryIndex(int index) {
    movieCategoryIndex.value = index;
  }

  void changeSelectedSeriesCategoryIndex(int index) {
    seriesCategoryIndex.value = index;
  }

  void changeSelectedSeriesSesonIndex(int index) {
    selectedSeriesSesonIndex.value = index;
  }

  void changeSelectedSeriesEpisodesIndex(int index) {
    selectedSeriesEpisodesIndex.value = index;
  }

  void _dedupeAndSortCategories(RxList<CategoryModel> list) {
    final unique = <String, CategoryModel>{};
    for (final category in list) {
      final id = (category.categoryId ?? '').trim();
      if (id.isEmpty || unique.containsKey(id)) continue;
      unique[id] = category;
    }
    list
      ..clear()
      ..addAll(unique.values);
    list.sort((a, b) {
      final nameA = (a.categoryName ?? '').toLowerCase();
      final nameB = (b.categoryName ?? '').toLowerCase();
      final isFreeA = nameA.contains('مجاني') ||
          nameA.contains('free') ||
          nameA.contains('مفتوح') ||
          nameA.contains('عربي');
      final isFreeB = nameB.contains('مجاني') ||
          nameB.contains('free') ||
          nameB.contains('مفتوح') ||
          nameB.contains('عربي');
      if (isFreeA && !isFreeB) return -1;
      if (!isFreeA && isFreeB) return 1;
      return nameA.compareTo(nameB);
    });
  }
}
