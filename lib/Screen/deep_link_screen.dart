import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iptv/Screen/SplashScreen.dart';
import 'package:iptv/Screen/bn_screens/live_screen.dart';
import 'package:iptv/Screen/movie_screen/movie_details_screen.dart';
import 'package:iptv/app_material/app_colors.dart';
import 'package:iptv/app_material/app_styles.dart';
import 'package:iptv/controller/home_getx_controller.dart';
import 'package:iptv/model/stream_model.dart';
import 'package:iptv/model/stream_series_model.dart';
import 'package:iptv/shared_preferences/shared_pref_controller.dart';
import 'package:iptv/utils/circal_animated.dart';
import 'package:iptv/utils/deep_link_redirect.dart';
import 'package:iptv/utils/stream_url_builder.dart';

class DeepLinkScreen extends StatefulWidget {
  final String type;
  final String id;

  const DeepLinkScreen({
    super.key,
    required this.type,
    required this.id,
  });

  @override
  State<DeepLinkScreen> createState() => _DeepLinkScreenState();
}

class _DeepLinkScreenState extends State<DeepLinkScreen> {
  late final Future<Widget> _targetFuture;

  @override
  void initState() {
    super.initState();
    _targetFuture = _resolveTarget();
  }

  Future<Widget> _resolveTarget() async {
    if (SharedPrefController().name.isEmpty ||
        SharedPrefController().password.isEmpty) {
      await saveCurrentRouteAsPending();
      return const SplashScreen();
    }

    final controller = Get.isRegistered<HomeGetxController>()
        ? Get.find<HomeGetxController>()
        : Get.put(HomeGetxController());

    switch (widget.type) {
      case 'live':
        final stream =
            Get.arguments is StreamModel ? Get.arguments as StreamModel : null;
        if (stream == null) {
          await _ensureLiveLoaded(controller);
        }
        final selectedStream = stream ?? _findStream(controller.streams);
        if (selectedStream == null) break;
        controller.changeSelectedStreamName(selectedStream.name ?? '');
        final categoryIndex = controller.categories.indexWhere(
          (category) => category.categoryId == selectedStream.categoryId,
        );
        if (categoryIndex >= 0) {
          controller.changeSelectedCategoryIndex(categoryIndex);
          controller.filterStreams(load: false);
        }
        final url = streamPlaybackUrl(selectedStream, preferWebHls: true);
        SharedPrefController().updateLastUrl(lastUrl: url);
        SharedPrefController()
            .updateStreamName(streamName: selectedStream.name ?? '');
        return LiveScreen(url: url, name: selectedStream.name);

      case 'movie':
        final stream =
            Get.arguments is StreamModel ? Get.arguments as StreamModel : null;
        if (stream == null) {
          await _ensureMoviesLoaded(controller);
        }
        final selectedStream = stream ?? _findStream(controller.movieStreams);
        if (selectedStream == null) break;
        return MovieDetailsScreen(streamModel: selectedStream, isMovie: true);

      case 'series':
        final streamArg =
            Get.arguments is StreamModel ? Get.arguments as StreamModel : null;
        final seriesArg = Get.arguments is StreamSeriesModel
            ? Get.arguments as StreamSeriesModel
            : null;
        if (streamArg == null && seriesArg == null) {
          await _ensureSeriesLoaded(controller);
        }
        final series = seriesArg ?? _findSeries(controller.seriesStreams);
        if (streamArg != null) {
          return MovieDetailsScreen(streamModel: streamArg, isMovie: false);
        }
        if (series == null) break;
        return MovieDetailsScreen(
          streamModel: _seriesToStream(series),
          isMovie: false,
        );
    }

    return _NotFoundScreen(type: widget.type);
  }

  Future<void> _ensureLiveLoaded(HomeGetxController controller) async {
    if (controller.categories.isEmpty) {
      await controller.getCategories(load: false);
    }
    if (controller.streams.isEmpty) {
      await controller.getStreams(load: false);
    }
    if (controller.streamsFilterd.isEmpty && controller.categories.isNotEmpty) {
      controller.filterStreams(load: false);
    }
  }

  Future<void> _ensureMoviesLoaded(HomeGetxController controller) async {
    if (controller.movieCategories.isEmpty) {
      await controller.getMovieCategories(load: false);
    }
    if (controller.movieStreams.isEmpty) {
      await controller.getMovieStreams(load: false);
    }
    if (controller.movieStreamsFilterd.isEmpty &&
        controller.movieCategories.isNotEmpty) {
      controller.filterMovieStreams(load: false);
    }
  }

  Future<void> _ensureSeriesLoaded(HomeGetxController controller) async {
    if (controller.seriesCategories.isEmpty) {
      await controller.getSeriesCategories(load: false);
    }
    if (controller.seriesStreams.isEmpty) {
      await controller.getSeriesStreams(load: false);
    }
    if (controller.seriesStreamsFilterd.isEmpty &&
        controller.seriesCategories.isNotEmpty) {
      controller.filterSeriesStreams(load: false);
    }
  }

  StreamModel? _findStream(Iterable<StreamModel> streams) {
    for (final stream in streams) {
      if (stream.streamId.toString() == widget.id) {
        return stream;
      }
    }
    return null;
  }

  StreamSeriesModel? _findSeries(Iterable<StreamSeriesModel> streams) {
    for (final stream in streams) {
      if (stream.streamId.toString() == widget.id) {
        return stream;
      }
    }
    return null;
  }

  StreamModel _seriesToStream(StreamSeriesModel series) {
    return StreamModel(
      added: series.added,
      categoryId: series.categoryId,
      epgChannelId: series.epgChannelId,
      name: series.name,
      num: series.num,
      streamIcon: series.streamIcon,
      streamId: int.tryParse(series.streamId.toString()),
      streamType: series.streamType,
      plot: series.plot,
      cast: series.cast,
      director: series.director,
      genre: series.genre,
      releaseDate: series.releaseDate,
      rating: series.rating,
      backdropPath: series.backdropPath,
      youtubeTrailer: series.youtubeTrailer,
      episodeRunTime: series.episodeRunTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _targetFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return snapshot.data!;
        }
        if (snapshot.hasError) {
          return _NotFoundScreen(type: widget.type);
        }
        return const Scaffold(
          backgroundColor: AppColors.blackColor,
          body: Center(child: AnimatedCircle()),
        );
      },
    );
  }
}

class _NotFoundScreen extends StatelessWidget {
  final String type;

  const _NotFoundScreen({required this.type});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.link_off, size: 56, color: AppColors.redColor),
              const SizedBox(height: 16),
              Text(
                'الرابط غير متوفر حالياً',
                textAlign: TextAlign.center,
                style: AppStyles().font18(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                type == 'live'
                    ? 'تأكد من تحديث قائمة القنوات ثم أعد المحاولة.'
                    : 'تأكد من تحديث المكتبة ثم أعد المحاولة.',
                textAlign: TextAlign.center,
                style: AppStyles().font14(color: AppColors.greysub3Color),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Get.offAllNamed('/HomeScreen'),
                child: const Text('الرئيسية'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
