int? _intValue(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

num? _numValue(dynamic value) {
  if (value is num) return value;
  return num.tryParse(value?.toString() ?? '');
}

Map<String, dynamic>? _mapValue(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }
  return null;
}

class SeriesDetailsModel {
  List<Seasons>? seasons;
  Info? info;
  Episodes? episodes;

  SeriesDetailsModel({this.seasons, this.info, this.episodes});

  SeriesDetailsModel.fromJson(Map<String, dynamic> json) {
    if (json['seasons'] is List) {
      seasons = <Seasons>[];
      (json['seasons'] as List).forEach((v) {
        seasons!.add(Seasons.fromJson(v));
      });
    }
    info = json['info'] != null ? Info.fromJson(json['info']) : null;
    episodes = json['episodes'] is Map<String, dynamic>
        ? Episodes.fromJson(json['episodes'])
        : Episodes(countsBySeason: <String, List<Counts>>{});
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (seasons != null) {
      data['seasons'] = seasons!.map((v) => v.toJson()).toList();
    }
    if (info != null) {
      data['info'] = info!.toJson();
    }
    if (episodes != null) {
      data['episodes'] = episodes!.toJson();
    }
    return data;
  }
}

class Seasons {
  dynamic airDate;
  int? episodeCount;
  int? id;
  dynamic name;
  dynamic overview;
  int? seasonNumber;
  dynamic cover;
  dynamic coverBig;

  Seasons(
      {this.airDate,
      this.episodeCount,
      this.id,
      this.name,
      this.overview,
      this.seasonNumber,
      this.cover,
      this.coverBig});

  Seasons.fromJson(Map<String, dynamic> json) {
    airDate = json['air_date'];
    episodeCount = _intValue(json['episode_count']);
    id = _intValue(json['id']);
    name = json['name'];
    overview = json['overview'];
    seasonNumber = _intValue(json['season_number']);
    cover = json['cover'];
    coverBig = json['cover_big'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['air_date'] = airDate;
    data['episode_count'] = episodeCount;
    data['id'] = id;
    data['name'] = name;
    data['overview'] = overview;
    data['season_number'] = seasonNumber;
    data['cover'] = cover;
    data['cover_big'] = coverBig;
    return data;
  }
}

class Info {
  dynamic name;
  dynamic cover;
  dynamic plot;
  dynamic cast;
  dynamic director;
  dynamic genre;
  dynamic releaseDate;
  dynamic lastModified;
  dynamic rating;
  num? rating5based;
  List<String>? backdropPath;
  dynamic youtubeTrailer;
  dynamic episodeRunTime;
  dynamic categoryId;

  Info(
      {this.name,
      this.cover,
      this.plot,
      this.cast,
      this.director,
      this.genre,
      this.releaseDate,
      this.lastModified,
      this.rating,
      this.rating5based,
      this.backdropPath,
      this.youtubeTrailer,
      this.episodeRunTime,
      this.categoryId});

  Info.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    cover = json['cover'];
    plot = json['plot'];
    cast = json['cast'];
    director = json['director'];
    genre = json['genre'];
    releaseDate = json['releaseDate'];
    lastModified = json['last_modified'];
    rating = json['rating'];
    rating5based = _numValue(json['rating_5based']);
    final rawBackdrop = json['backdrop_path'];
    if (rawBackdrop is List) {
      backdropPath = <String>[];
      rawBackdrop.forEach((v) {
        backdropPath!.add(v.toString());
      });
    } else if (rawBackdrop != null &&
        rawBackdrop.toString().trim().isNotEmpty) {
      backdropPath = [rawBackdrop.toString()];
    } else {
      backdropPath = <String>[];
    }
    youtubeTrailer = json['youtube_trailer'];
    episodeRunTime = json['episode_run_time'];
    categoryId = json['category_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['cover'] = cover;
    data['plot'] = plot;
    data['cast'] = cast;
    data['director'] = director;
    data['genre'] = genre;
    data['releaseDate'] = releaseDate;
    data['last_modified'] = lastModified;
    data['rating'] = rating;
    data['rating_5based'] = rating5based;
    if (backdropPath != null) {
      data['backdrop_path'] = backdropPath!;
    }
    data['youtube_trailer'] = youtubeTrailer;
    data['episode_run_time'] = episodeRunTime;
    data['category_id'] = categoryId;
    return data;
  }
}

class Episodes {
  Map<String, List<Counts>>? countsBySeason;

  Episodes({this.countsBySeason});

  Episodes.fromJson(Map<String, dynamic> json) {
    countsBySeason = {};
    json.forEach((key, value) {
      if (value is List) {
        countsBySeason![key] = <Counts>[];
        value.forEach((v) {
          countsBySeason![key]!.add(Counts.fromJson(v));
        });
      }
    });
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    countsBySeason?.forEach((key, value) {
      data[key] = value.map((v) => v.toJson()).toList();
    });
    return data;
  }
}

class Counts {
  dynamic id;
  num? episodeNum;
  dynamic title;
  dynamic containerExtension;
  InfoCount? info;
  dynamic customSid;
  dynamic added;
  num? season;
  dynamic directSource;

  Counts(
      {this.id,
      this.episodeNum,
      this.title,
      this.containerExtension,
      this.info,
      this.customSid,
      this.added,
      this.season,
      this.directSource});

  Counts.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    episodeNum = _numValue(json['episode_num']);
    title = json['title'];
    containerExtension = json['container_extension'];
    final infoMap = _mapValue(json['info']);
    info = infoMap != null ? InfoCount.fromJson(infoMap) : null;
    customSid = json['custom_sid'];
    added = json['added'];
    season = _numValue(json['season']);
    directSource = json['direct_source'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['episode_num'] = episodeNum;
    data['title'] = title;
    data['container_extension'] = containerExtension;
    if (info != null) {
      data['info'] = info!.toJson();
    }
    data['custom_sid'] = customSid;
    data['added'] = added;
    data['season'] = season;
    data['direct_source'] = directSource;
    return data;
  }
}

class InfoCount {
  dynamic movieImage;
  dynamic plot;
  dynamic rating;
  dynamic releaseDate;
  int? durationSecs;
  dynamic duration;
  int? bitrate;

  InfoCount(
      {this.movieImage,
      this.plot,
      this.rating,
      this.releaseDate,
      this.durationSecs,
      this.duration,
      this.bitrate});

  InfoCount.fromJson(Map<String, dynamic> json) {
    movieImage = json['movie_image'];
    plot = json['plot'];
    rating = json['rating'];
    releaseDate = json['releaseDate'];
    durationSecs = _intValue(json['duration_secs']);
    duration = json['duration'];
    bitrate = _intValue(json['bitrate']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['movie_image'] = movieImage;
    data['plot'] = plot;
    data['rating'] = rating;
    data['releaseDate'] = releaseDate;
    data['duration_secs'] = durationSecs;
    data['duration'] = duration;
    data['bitrate'] = bitrate;
    return data;
  }
}
