int? _intValue(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

class StreamModel {
  late int? num;
  late String? name;
  late String? streamType;
  late int? streamId;
  late String? streamIcon;
  late String? epgChannelId;
  late String? added;
  late String? categoryId;
  late String? plot;
  late String? cast;
  late String? director;
  late String? genre;
  late String? releaseDate;
  late String? rating;
  late String? backdropPath;
  late String? youtubeTrailer;
  late String? episodeRunTime;
  // late dynamic customSid;
  // late String? tvArchive;
  late String? directSource;
  // late String? tvArchiveDuration;
  // late String? live;

  StreamModel({
    this.num,
    this.name,
    this.streamType,
    this.streamId,
    this.streamIcon,
    this.epgChannelId,
    this.added,
    this.categoryId,
    this.plot,
    this.cast,
    this.director,
    this.genre,
    this.releaseDate,
    this.rating,
    this.backdropPath,
    this.youtubeTrailer,
    this.episodeRunTime,
    // this.customSid,
    // this.tvArchive,
    this.directSource,
    // this.tvArchiveDuration,
    // this.live
  });

  StreamModel.fromJson(Map<String, dynamic> json) {
    num = _intValue(json['num']);
    name = json['name'];
    streamType = json['stream_type'];
    streamId = _intValue(json['stream_id']);
    streamIcon = json['stream_icon'];
    epgChannelId = json['epg_channel_id'];
    added = json['added'];
    categoryId = json['category_id'];
    plot = json['plot']?.toString();
    cast = json['cast']?.toString();
    director = json['director']?.toString();
    genre = json['genre']?.toString();
    releaseDate = json['releaseDate']?.toString();
    rating = json['rating']?.toString();
    backdropPath = json['backdrop_path']?.toString();
    youtubeTrailer = json['youtube_trailer']?.toString();
    episodeRunTime = json['episode_run_time']?.toString();
    // customSid = json['custom_sid'];
    // // tvArchive = json['tv_archive'];
    directSource = json['direct_source'];
    // // tvArchiveDuration = json['tv_archive_duration'];
    // live = json['live'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['num'] = num;
    data['name'] = name;
    data['stream_type'] = streamType;
    data['stream_id'] = streamId;
    data['stream_icon'] = streamIcon;
    data['epg_channel_id'] = epgChannelId;
    data['added'] = added;
    data['category_id'] = categoryId;
    // data['custom_sid'] = customSid;
    // // data['tv_archive'] = tvArchive;
    data['direct_source'] = directSource;
    // // data['tv_archive_duration'] = tvArchiveDuration;
    // data['live'] = live;
    return data;
  }
}
