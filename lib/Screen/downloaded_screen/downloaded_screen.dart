import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iptv/Screen/player_screen/player__local_screen.dart';
import 'package:iptv/controller/download_getx_controller.dart';
import 'dart:math' as math;

import 'package:iptv/utils/app_helper.dart';

class DownloadedScreen extends StatefulWidget {
  const DownloadedScreen({super.key});

  @override
  State<DownloadedScreen> createState() => _DownloadedScreenState();
}

class _DownloadedScreenState extends State<DownloadedScreen>
    with AppHelper, SingleTickerProviderStateMixin {
  final DownloadGetxController downloadGetxController = Get.find();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('التحميلات'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'المكتملة'),
            Tab(text: 'غير المكتملة'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildVideoList(isCompleted: true),
          _buildVideoList(isCompleted: false),
        ],
      ),
    );
  }

  Widget _buildVideoList({required bool isCompleted}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Obx(() {
        // اختيار القائمة بناءً على حالة الفيديوهات
        List<Map<String, dynamic>> videos = isCompleted
            ? downloadGetxController.downloadedVideos
            : downloadGetxController.incompleteDownloads;

        if (videos.isEmpty) {
          return Center(
            child: Text(
              isCompleted
                  ? 'لم يتم تحميل أي فيديوهات مكتملة.'
                  : 'لا توجد فيديوهات غير مكتملة.',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          );
        }

        // عرض القائمة
        return ListView.builder(
          itemCount: videos.length,
          itemBuilder: (context, index) {
            final video = videos[index];
            final isDownloading = isCompleted && video['progress'] != 100;

            return InkWell(
              onTap: () {
                if (!isDownloading && isCompleted) {
                  Get.to(() => PlayerLocalScreen(
                        title: video['name'],
                        videoUrl: File(video['path']),
                      ));
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 6,
                      offset: Offset(0, 3),
                      color: Colors.black12,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: video['thumbnail'] != null
                          ? Image.memory(
                              video['thumbnail'],
                              height: 80,
                              width: 80,
                              fit: BoxFit.fill,
                            )
                          : Image.asset(
                              'images/new_logo.jpg',
                              height: 80,
                              width: 80,
                              fit: BoxFit.cover,
                            ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            video['name'].split('.').first,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            isDownloading
                                ? 'تحميل: ${video['progress']}%'
                                : (isCompleted ? 'مكتمل' : 'فشل أو تم إلغاؤه'),
                            style: TextStyle(
                              fontSize: 14,
                              color: isDownloading
                                  ? Colors.grey
                                  : (isCompleted ? Colors.green : Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    _buildActionButtons(video, isDownloading, isCompleted),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildActionButtons(
      Map<String, dynamic> video, bool isDownloading, bool isCompleted) {
    if (isDownloading) {
      return Row(
        children: [
          Obx(() {
            return IconButton(
              icon: downloadGetxController.isDownloadPaused.value
                  ? const Icon(Icons.play_arrow)
                  : const Icon(Icons.pause),
              onPressed: () {
                downloadGetxController.togglePauseResumeDownload(video['name']);
              },
            );
          }),
          IconButton(
            icon: const Icon(Icons.cancel),
            onPressed: () {
              downloadGetxController.cancelDownload(video['name']);
            },
          ),
        ],
      );
    } else if (!isCompleted) {
      return IconButton(
        icon: const Icon(Icons.refresh),
        onPressed: () {
          downloadGetxController.retryDownload(video['taskId']);
        },
      );
    } else {
      return Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationY(math.pi),
        child: const Icon(Icons.play_arrow),
      );
    }
  }
}
