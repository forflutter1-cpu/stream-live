import 'package:flutter/foundation.dart';
import 'package:iptv/model/stream_model.dart';
import 'package:iptv/shared_preferences/shared_pref_controller.dart';

String streamPlaybackUrl(StreamModel stream, {bool preferWebHls = false}) {
  if (stream.directSource != null && stream.directSource!.isNotEmpty) {
    return stream.directSource!;
  }

  final type = stream.streamType ?? 'live';
  return contentPlaybackUrl(
    contentId: stream.streamId,
    type: type,
    extension: type == 'live' ? null : 'mp4',
    preferWebHls: preferWebHls,
  );
}

String contentPlaybackUrl({
  required Object? contentId,
  required String type,
  String? extension,
  bool preferWebHls = false,
}) {
  final protocol = SharedPrefController().serverProtocol;
  final port = protocol == 'http'
      ? SharedPrefController().port
      : SharedPrefController().httpsPort;
  final base = '$protocol://${SharedPrefController().url}:$port/';
  final normalizedType = type.trim().isEmpty ? 'live' : type;
  final normalizedExtension = extension != null && extension.isNotEmpty
      ? '.$extension'
      : normalizedType == 'live'
          ? (preferWebHls || kIsWeb ? '.m3u8' : '.ts')
          : '.mp4';

  return '$base$normalizedType/${SharedPrefController().name}/${SharedPrefController().password}/$contentId$normalizedExtension';
}
