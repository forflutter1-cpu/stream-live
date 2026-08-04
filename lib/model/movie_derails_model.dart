class MovieDetailsModel {
  late Info? info;
  late MovieData? movieData;

  MovieDetailsModel({this.info, this.movieData});

  MovieDetailsModel.fromJson(Map<String, dynamic> json) {
    info = json['info'] != null ? Info.fromJson(json['info']) : null;
    movieData = json['movie_data'] != null
        ? MovieData.fromJson(json['movie_data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (info != null) {
      data['info'] = info!.toJson();
    }
    if (movieData != null) {
      data['movie_data'] = movieData!.toJson();
    }
    return data;
  }
}

class Info {
  late dynamic movieImage;
  late dynamic name;
  late dynamic oName;
  late dynamic youtubeTrailer;
  late dynamic genre;
  late dynamic plot;
  late dynamic director;
  late dynamic cast;
  late dynamic rating;
  late dynamic releasedate;
  late dynamic tmdbId;
  late dynamic durationSecs;
  late dynamic duration;
  late List<String>? backdropPath;

  Info(
      {this.movieImage,
      this.name,
      this.oName,
      this.youtubeTrailer,
      this.genre,
      this.plot,
      this.director,
      this.cast,
      this.rating,
      this.releasedate,
      this.tmdbId,
      this.durationSecs,
      this.duration,
      this.backdropPath});

  Info.fromJson(Map<String, dynamic> json) {
    movieImage = json['movie_image'];
    name = json['name'];
    oName = json['o_name'];
    youtubeTrailer = json['youtube_trailer'];
    genre = json['genre'];
    plot = json['plot'];
    director = json['director'];
    cast = json['cast'];
    rating = json['rating'];
    releasedate = json['releasedate'];
    tmdbId = json['tmdb_id'];
    durationSecs = json['duration_secs'];
    duration = json['duration'];
    final rawBackdrop = json['backdrop_path'];
    if (rawBackdrop is List) {
      backdropPath = rawBackdrop.map((item) => item.toString()).toList();
    } else {
      backdropPath = <String>[];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['movie_image'] = movieImage;
    data['name'] = name;
    data['o_name'] = oName;
    data['youtube_trailer'] = youtubeTrailer;
    data['genre'] = genre;
    data['plot'] = plot;
    data['director'] = director;
    data['cast'] = cast;
    data['rating'] = rating;
    data['releasedate'] = releasedate;
    data['tmdb_id'] = tmdbId;
    data['duration_secs'] = durationSecs;
    data['duration'] = duration;
    data['backdrop_path'] = backdropPath;
    return data;
  }
}

class MovieData {
  late int? streamId;
  late String? name;
  late dynamic added;
  late dynamic containerExtension;
  late dynamic customSid;
  late dynamic directSource;

  MovieData(
      {this.streamId,
      this.name,
      this.added,
      this.containerExtension,
      this.customSid,
      this.directSource});

  MovieData.fromJson(Map<String, dynamic> json) {
    streamId = int.tryParse(json['stream_id'].toString());
    name = json['name'];
    added = json['added'];
    containerExtension = json['container_extension'];
    customSid = json['custom_sid'];
    directSource = json['direct_source'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stream_id'] = streamId;
    data['name'] = name;
    data['added'] = added;
    data['container_extension'] = containerExtension;
    data['custom_sid'] = customSid;
    data['direct_source'] = directSource;
    return data;
  }
}
