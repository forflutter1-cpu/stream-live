import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:iptv/api/api_helper.dart';
import 'package:iptv/database/database_helper.dart';
import 'package:iptv/utils/app_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:http/http.dart' as http;

class DownloadGetxController extends GetxController with ApiHelper, AppHelper {
  ReceivePort port = ReceivePort();
  Map<String, String> downloadTasks = {};
  Map<String, int> downloadProgress = {};
  RxList<Map<String, dynamic>> downloadedVideos = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> incompleteDownloads =
      <Map<String, dynamic>>[].obs;
  RxList<String> filesName = <String>[].obs;
  RxList<DownloadTask> allDownloadedVideo = <DownloadTask>[].obs;
  RxBool isDownloadClick = false.obs;
  RxBool isDownloadPaused = false.obs;
  RxInt progres = 0.obs;
  String name = '';
  var isDownloading = false.obs;
  var downloadingFileName = ''.obs;
  final dbHelper = DatabaseHelper.instance;

  // Download queue
  List<Map<String, dynamic>> downloadQueue = [];

  @override
  void onClose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    if (kIsWeb) return;
    loadTask();
    setupDownloader();
    if (Platform.isAndroid) {
      FlutterDownloader.registerCallback(downloadCallback);
    }
    downloadingQueue();
  }

  void downloadingQueue() async {
    if (kIsWeb) return;
    downloadQueue.addAll(await dbHelper.getAllQueueDownloads());
    if (!isDownloading.value && downloadQueue.isNotEmpty) {
      var nextVideo = downloadQueue.removeAt(0);
      int? id = await dbHelper.getDownloadIdByName(nextVideo['name']);
      if (id != null) {
        await dbHelper.deleteQueueDownload(id);
      }
      startDownload(
          url: nextVideo['url'],
          name: nextVideo['name'],
          isSeries: nextVideo['isSeries'] == 1 ? true : false,
          seriesName: nextVideo['seriesName']);
    }
  }

  void loadTask() async {
    if (kIsWeb) return;
    if (Platform.isAndroid) {
      final tasks = await FlutterDownloader.loadTasks();
      if (tasks == null || tasks.isEmpty) return;

      String? currentDownloadingFile = downloadingFileName.value;

      Map<String, DownloadTask> updatedTasks = {
        for (var task in tasks) task.taskId: task
      };

      for (var task in tasks) {
        String fileNameWithoutExtension =
            (task.filename ?? "unknown").split('.').first;
        downloadTasks[task.taskId] = fileNameWithoutExtension;

        if (task.status == DownloadTaskStatus.running ||
            task.status == DownloadTaskStatus.enqueued) {
          isDownloading.value = true;

          if (currentDownloadingFile != fileNameWithoutExtension) {
            name = fileNameWithoutExtension;
            progres.value = task.progress;
            downloadingFileName.value = name;
            isDownloadClick.value = true;
            isDownloadPaused.value = task.status == DownloadTaskStatus.paused;
          }
        }

        if (task.status == DownloadTaskStatus.canceled ||
            task.status == DownloadTaskStatus.failed ||
            task.status == DownloadTaskStatus.undefined) {
          if (!incompleteDownloads
              .any((item) => item['taskId'] == task.taskId)) {
            incompleteDownloads.add({
              'taskId': task.taskId,
              'name': fileNameWithoutExtension,
              'progress': task.progress,
              'status': task.status == DownloadTaskStatus.canceled
                  ? 'Canceled'
                  : 'Failed',
              'downloadUrl': task.url,
            });
          }
        }
      }

      allDownloadedVideo.assignAll(updatedTasks.values);

      if (!isDownloading.value) {
        isDownloadClick.value = false;
        progres.value = 0;
      }
    }
    generateThumbnails();
  }

  void retryDownload(String taskId) async {
    var video = incompleteDownloads.firstWhere(
      (element) => element['taskId'] == taskId,
      orElse: () => {},
    );

    if (video.isEmpty) return;

    String downloadUrl = video['downloadUrl'];
    String name = video['name'];

    incompleteDownloads.removeWhere((element) => element['taskId'] == taskId);

    bool resumed = await tryResumeDownload(taskId);

    if (!resumed) {
      startDownload(url: downloadUrl, name: name);
    }
  }

  Future<bool> tryResumeDownload(String taskId) async {
    if (kIsWeb) return false;
    if (Platform.isAndroid) {
      var tasks = await FlutterDownloader.loadTasks();
      var currentTask = tasks?.firstWhere(
        (task) => task.taskId == taskId,
      );

      if (currentTask == null) {
        return false;
      }

      if (currentTask.status == DownloadTaskStatus.paused ||
          currentTask.status == DownloadTaskStatus.failed ||
          currentTask.status == DownloadTaskStatus.canceled) {
        String? returnedString = await FlutterDownloader.resume(taskId: taskId);
        if (returnedString != null) {
          return true;
        } else {
          return false;
        }
      }
    }
    return false;
  }

  Future<void> generateThumbnails() async {
    if (kIsWeb) return;
    Directory? appDir = await getAppDirectory();
    if (appDir == null) return;

    String appFolder = '${appDir.path}/Stream Live/';
    Directory mainDirectory = Directory(appFolder);

    if (!await mainDirectory.exists()) {
      return;
    }

    List<FileSystemEntity> filesAndFolders =
        mainDirectory.listSync(recursive: true);

    List<File> videoFiles = filesAndFolders
        .whereType<File>()
        .where((file) => file.path.endsWith('.mp4'))
        .toList();

    List<Map<String, dynamic>> tempDownloadedVideos = [];

    for (var videoFile in videoFiles) {
      String filePath = videoFile.path;
      String fileName = filePath.split('/').last;

      final thumbnail = await VideoThumbnail.thumbnailData(
        video: filePath,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 128,
        quality: 75,
      );

      if (thumbnail != null) {
        tempDownloadedVideos.add({
          'name': fileName,
          'path': filePath,
          'thumbnail': thumbnail,
          'progress': 100,
          'timestamp': videoFile.statSync().modified,
        });
      }
      filesName.add(fileName.split('.').first);
    }

    downloadedVideos.clear();
    tempDownloadedVideos
        .sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
    downloadedVideos.addAll(tempDownloadedVideos);
  }

  Future<void> startDownload({
    required String url,
    required String name,
    bool isSeries = false,
    bool isStore = false,
    String seriesName = '',
  }) async {
    if (kIsWeb) return;
    isDownloading.value = true;
    downloadingFileName.value = name;

    Directory? appDir = await getAppDirectory();
    if (appDir == null) return;

    String appFolder = '${appDir.path}/Stream Live/';
    if (isSeries) {
      appFolder = '$appFolder$seriesName/';
    }
    String filePath = '$appFolder$name.mp4';

    downloadedVideos.insert(0, {
      'name': name,
      'path': filePath,
      'thumbnail': null,
      'progress': 0,
      'timestamp': DateTime.now(),
    });

    try {
      await download(
          // url: 'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
          url: url,
          name: name,
          isSeries: isSeries,
          seriesName: seriesName,
          isStore: isStore);
    } catch (e) {
      isDownloading.value = false;
    }
  }

  Future<void> togglePauseResumeDownload(String fileName) async {
    if (kIsWeb) return;
    if (Platform.isAndroid) {
      String? taskId = downloadTasks.entries
          .firstWhere((entry) => entry.value.contains(fileName),
              orElse: () => const MapEntry('', ''))
          .key;

      if (taskId.isNotEmpty) {
        try {
          if (isDownloadPaused.value) {
            String? newTaskId = await FlutterDownloader.resume(taskId: taskId);
            if (newTaskId != null) {
              downloadTasks[newTaskId] = downloadTasks[taskId]!;
              downloadTasks.remove(taskId);
              isDownloadPaused.value = false;
            }
          } else {
            await FlutterDownloader.pause(taskId: taskId);
            isDownloadPaused.value = true;
          }
        } catch (e) {
          return;
        }
      }
    }
    // iOS لا يدعم الإيقاف المؤقت أو الاستئناف مع flutter_downloader
  }

  bool isInQueue(String videoTitle) {
    return downloadQueue.any((download) => download['name'] == videoTitle);
  }

  Future<void> cancelDownload(String fileName) async {
    if (kIsWeb) return;
    if (Platform.isAndroid) {
      String? taskId = downloadTasks.entries
          .firstWhere((entry) => entry.value.contains(fileName),
              orElse: () => const MapEntry('', ''))
          .key;

      if (taskId.isNotEmpty) {
        try {
          await FlutterDownloader.cancel(taskId: taskId);
          downloadTasks.remove(taskId);
          FlutterDownloader.remove(taskId: taskId, shouldDeleteContent: true);
          name = '';
          progres.value = 0;
          downloadingFileName.value = '';
          isDownloading.value = false;
          downloadQueue.clear();
          dbHelper.clearQueueDownloads();
        } catch (e) {
          return;
        }
      }
      loadTask();
    } else if (Platform.isIOS) {
      // حذف الملف يدويًا إذا كان موجودًا
      Directory? appDir = await getAppDirectory();
      String filePath = '${appDir!.path}/Stream Live/$fileName.mp4';
      File file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
      isDownloading.value = false;
      downloadingFileName.value = '';
      progres.value = 0;
      loadTask();
    }
  }

  Future<void> setupDownloader() async {
    if (kIsWeb) return;
    if (Platform.isAndroid) {
      IsolateNameServer.registerPortWithName(
          port.sendPort, 'downloader_send_port');

      port.listen((dynamic data) async {
        String id = data[0];
        int progress = data[2];
        DownloadTaskStatus status = DownloadTaskStatus.fromInt(data[1]);

        downloadProgress[id] = progress;
        progres.value = progress;

        for (var video in downloadedVideos) {
          if (video['name'] == downloadingFileName.value) {
            video['progress'] = progress;
            downloadedVideos.refresh();
            break;
          }
        }

        if (status == DownloadTaskStatus.complete) {
          isDownloadClick.value = false;
          name = '';
          progres.value = 0;
          downloadingFileName.value = '';
          isDownloading.value = false;
          loadTask();

          for (var video in downloadedVideos) {
            if (video['name'] == downloadingFileName.value) {
              String filePath = video['path'];
              final thumbnail = await VideoThumbnail.thumbnailData(
                video: filePath,
                imageFormat: ImageFormat.JPEG,
                maxWidth: 128,
                quality: 75,
              );

              if (thumbnail != null) {
                video['thumbnail'] = thumbnail;
                downloadedVideos.refresh();
              }
              break;
            }
          }

          if (downloadQueue.isNotEmpty) {
            var nextVideo = downloadQueue.removeAt(0);
            startDownload(url: nextVideo['url'], name: nextVideo['name']);
          }
        } else if (status == DownloadTaskStatus.failed ||
            status == DownloadTaskStatus.canceled) {
          isDownloading.value = false;
          progres.value = 0;
          loadTask();
        }
      });
    }
  }

  bool isVideoDownloaded(String name) {
    return filesName.any((file) => file == name);
  }

  Future<void> download({
    required String url,
    required String name,
    bool isSeries = false,
    String seriesName = '',
    bool isStore = false,
  }) async {
    if (kIsWeb) return;
    this.name = name;

    Directory? appDir = await getAppDirectory();
    if (appDir == null) return;

    String appFolder = '${appDir.path}/Stream Live/';
    if (isSeries) {
      appFolder = '$appFolder$seriesName/';
    }

    if (!(await Directory(appFolder).exists())) {
      await Directory(appFolder).create(recursive: true);
    }

    if (Platform.isAndroid) {
      try {
        isDownloadClick.value = true;
        final taskId = await FlutterDownloader.enqueue(
          url: isStore ? url : '$url?download=1',
          headers: header,
          savedDir: appFolder,
          fileName: '$name.mp4',
          showNotification: true,
          openFileFromNotification: true,
        );
        if (taskId != null) {
          downloadTasks[taskId] = name;
        }
      } catch (e) {
        downloadQueue.clear();
        dbHelper.clearQueueDownloads();
        return;
      }
    } else if (Platform.isIOS) {
      try {
        isDownloadClick.value = true;
        String filePath = '$appFolder$name.mp4';
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          File file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);
          isDownloading.value = false;
          progres.value = 100;
          downloadingFileName.value = '';
          isDownloadClick.value = false;
          loadTask();
        } else {
          throw Exception('Failed to download file');
        }
      } catch (e) {
        isDownloading.value = false;
        return;
      }
    }
  }

  Future<Directory?> getAppDirectory() async {
    if (kIsWeb) return null;
    if (Platform.isAndroid) {
      return await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      return await getApplicationDocumentsDirectory();
    }
    return null;
  }

  Future<bool> requestDownloadPermission() async {
    // لا حاجة لطلب إذن لأننا نستخدم المجلد الخاص بالتطبيق
    return true;
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final SendPort send = IsolateNameServer.lookupPortByName(
      'downloader_send_port',
    )!;
    send.send([id, status, progress]);
  }

  void addToDownloadQueue({
    required String url,
    required String name,
    bool isSeries = false,
    bool isStore = false,
    String seriesName = '',
  }) async {
    if (kIsWeb) return;
    downloadQueue.add({
      'url': url,
      'name': name,
      'isSeries': isSeries,
      'seriesName': seriesName
    });
    dbHelper.addQueueDownload({
      'url': url,
      'name': name,
      'isSeries': isSeries ? 1 : 0,
      'seriesName': seriesName
    });
    if (!isDownloading.value) {
      var nextVideo = downloadQueue.removeAt(0);
      int? id = await dbHelper.getDownloadIdByName(nextVideo['name']);
      if (id != null) {
        await dbHelper.deleteQueueDownload(id);
      }
      startDownload(
          url: nextVideo['url'],
          name: nextVideo['name'],
          isSeries: nextVideo['isSeries'],
          isStore: isStore,
          seriesName: nextVideo['seriesName']);
    }
  }
}
