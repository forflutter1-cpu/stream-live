import 'package:iptv/model/edu_model_parsing.dart';

class EduLesson {
  final int id;
  final String name;
  final int unitId;
  final String? lessonLink;
  final String? lessonLinkType; // 'YT' = YouTube, 'VI' = Video, 'LI' = Link
  final String? backupLink;
  final String? videoFile;
  final String? downloadLink;
  final int myOrder;
  bool isWatched;

  EduLesson({
    required this.id,
    required this.name,
    required this.unitId,
    this.lessonLink,
    this.lessonLinkType,
    this.backupLink,
    this.videoFile,
    this.downloadLink,
    required this.myOrder,
    this.isWatched = false,
  });

  bool get isYoutube => lessonLinkType == 'YT';
  bool get isVideo => lessonLinkType == 'VI' || videoFile != null;

  String? get youtubeId {
    if (!isYoutube || lessonLink == null) return null;
    final uri = Uri.tryParse(lessonLink!);
    if (uri == null) return null;
    if (uri.queryParameters.containsKey('v')) return uri.queryParameters['v'];
    // handle youtu.be/ID
    if (uri.host == 'youtu.be') {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    }
    return null;
  }

  factory EduLesson.fromJson(Map<String, dynamic> json) {
    return EduLesson(
      id: eduInt(json['id']),
      name: eduString(json['name_ar'] ?? json['name']),
      unitId: eduRelatedId(json['unit']) ?? 0,
      lessonLink: json['lesson_link']?.toString(),
      lessonLinkType: json['lesson_link_type']?.toString(),
      backupLink: json['backup_link']?.toString(),
      videoFile: json['video_file']?.toString(),
      downloadLink: json['download_link']?.toString(),
      myOrder: eduInt(json['my_order']),
      isWatched: eduBool(json['is_watched']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'unit_id': unitId,
      'lesson_link': lessonLink,
      'lesson_link_type': lessonLinkType,
      'backup_link': backupLink,
      'video_file': videoFile,
      'download_link': downloadLink,
      'my_order': myOrder,
      'is_watched': isWatched ? 1 : 0,
    };
  }

  factory EduLesson.fromMap(Map<String, dynamic> map) {
    return EduLesson(
      id: eduInt(map['id']),
      name: eduString(map['name']),
      unitId: eduInt(map['unit_id']),
      lessonLink: map['lesson_link']?.toString(),
      lessonLinkType: map['lesson_link_type']?.toString(),
      backupLink: map['backup_link']?.toString(),
      videoFile: map['video_file']?.toString(),
      downloadLink: map['download_link']?.toString(),
      myOrder: eduInt(map['my_order']),
      isWatched: eduBool(map['is_watched']),
    );
  }
}
