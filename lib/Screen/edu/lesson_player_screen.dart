import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:iptv/controller/edu_controller.dart';
import 'package:iptv/model/edu_lesson_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class LessonPlayerScreen extends StatefulWidget {
  final EduLesson lesson;
  final List<EduLesson> allLessons;
  final int initialIndex;

  const LessonPlayerScreen({
    super.key,
    required this.lesson,
    required this.allLessons,
    required this.initialIndex,
  });

  @override
  State<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends State<LessonPlayerScreen> {
  late EduController _edu;
  YoutubePlayerController? _ytController;
  late int _currentIndex;
  late EduLesson _currentLesson;
  bool _markedWatched = false;

  @override
  void initState() {
    super.initState();
    _edu = Get.isRegistered<EduController>()
        ? Get.find<EduController>()
        : Get.put(EduController());
    _currentIndex = widget.initialIndex;
    _currentLesson = widget.lesson;
    _initPlayer();
  }

  void _initPlayer() {
    _ytController?.dispose();
    _ytController = null;
    _markedWatched = false;

    if (_currentLesson.isYoutube && _currentLesson.youtubeId != null) {
      _ytController = YoutubePlayerController(
        initialVideoId: _currentLesson.youtubeId!,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          enableCaption: false,
        ),
      );
      _ytController!.addListener(_handleYoutubeProgress);
    }
  }

  void _handleYoutubeProgress() {
    if (_markedWatched || !mounted) return;
    final controller = _ytController;
    if (controller == null) return;

    final duration = controller.metadata.duration;
    final position = controller.value.position;
    if (duration.inSeconds <= 0) return;

    if (position.inMilliseconds >= duration.inMilliseconds / 2) {
      _markedWatched = true;
      _edu.markLessonWatched(_currentLesson.id);
    }
  }

  void _navigateLesson(int newIndex) {
    if (newIndex < 0 || newIndex >= widget.allLessons.length) return;
    setState(() {
      _currentIndex = newIndex;
      _currentLesson = widget.allLessons[newIndex];
      _initPlayer();
    });
  }

  @override
  void dispose() {
    _ytController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return _buildScaffold(_buildWebLessonPlayer());
    }

    return YoutubePlayerBuilder(
      player: _ytController != null
          ? YoutubePlayer(
              controller: _ytController!,
              showVideoProgressIndicator: true,
              progressColors: const ProgressBarColors(
                playedColor: Color(0xFF6C63FF),
                handleColor: Color(0xFF6C63FF),
              ),
            )
          : YoutubePlayer(
              controller: YoutubePlayerController(initialVideoId: ''),
            ),
      builder: (ctx, player) {
        return _buildScaffold(
          _currentLesson.isYoutube && _ytController != null
              ? player
              : _buildNonYoutubePlayer(),
        );
      },
    );
  }

  Widget _buildScaffold(Widget player) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      body: SafeArea(
        child: Column(
          children: [
            _withVideoBackButton(player),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white),
                        onPressed: () => Get.back(),
                      ),
                      Expanded(
                        child: Text(
                          _currentLesson.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildNavigationBar(),
                  const SizedBox(height: 16),
                  _buildInfoCard(),
                  const SizedBox(height: 16),
                  _buildAllLessonsList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _withVideoBackButton(Widget player) {
    return Stack(
      children: [
        player,
        Positioned(
          top: 10,
          right: 10,
          child: Material(
            color: Colors.black54,
            shape: const CircleBorder(),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 18),
              tooltip: 'رجوع',
              onPressed: () => Get.back(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWebLessonPlayer() {
    final link = _currentLesson.isYoutube && _currentLesson.youtubeId != null
        ? 'https://www.youtube.com/watch?v=${_currentLesson.youtubeId}'
        : (_currentLesson.videoFile ?? _currentLesson.lessonLink);

    return Container(
      height: 220,
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_circle_outline,
                color: Colors.white54, size: 64),
            const SizedBox(height: 12),
            const Text(
              'تشغيل الدرس',
              style: TextStyle(color: Colors.white70, fontSize: 15),
            ),
            const SizedBox(height: 12),
            if (link != null && link.isNotEmpty)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.open_in_new),
                label: const Text('فتح الفيديو'),
                onPressed: () => launchUrl(Uri.parse(link),
                    mode: LaunchMode.platformDefault),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNonYoutubePlayer() {
    final link = _currentLesson.videoFile ?? _currentLesson.lessonLink;
    return Container(
      height: 220,
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_circle_outline,
                color: Colors.white54, size: 64),
            const SizedBox(height: 12),
            const Text(
              'اضغط لفتح الدرس في المتصفح',
              style: TextStyle(color: Colors.white60),
            ),
            const SizedBox(height: 12),
            if (link != null && link.isNotEmpty)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.open_in_new),
                label: const Text('فتح الدرس'),
                onPressed: () => launchUrl(Uri.parse(link),
                    mode: LaunchMode.externalApplication),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationBar() {
    final hasPrev = _currentIndex > 0;
    final hasNext = _currentIndex < widget.allLessons.length - 1;
    return Row(
      children: [
        Expanded(
          child: _navButton(
            icon: Icons.skip_previous_rounded,
            label: 'السابق',
            enabled: hasPrev,
            onTap: () => _navigateLesson(_currentIndex - 1),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2131),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${_currentIndex + 1} / ${widget.allLessons.length}',
            style: const TextStyle(color: Colors.white60, fontSize: 13),
          ),
        ),
        Expanded(
          child: _navButton(
            icon: Icons.skip_next_rounded,
            label: 'التالي',
            enabled: hasNext,
            isNext: true,
            onTap: () => _navigateLesson(_currentIndex + 1),
          ),
        ),
      ],
    );
  }

  Widget _navButton({
    required IconData icon,
    required String label,
    required bool enabled,
    required VoidCallback onTap,
    bool isNext = false,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: enabled
              ? const Color(0xFF6C63FF).withOpacity(0.15)
              : const Color(0xFF1E2131),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: enabled
                ? const Color(0xFF6C63FF).withOpacity(0.4)
                : Colors.white12,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isNext)
              Icon(icon,
                  size: 18,
                  color: enabled ? const Color(0xFF6C63FF) : Colors.white24),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    color: enabled ? const Color(0xFF6C63FF) : Colors.white24,
                    fontSize: 13)),
            const SizedBox(width: 4),
            if (isNext)
              Icon(icon,
                  size: 18,
                  color: enabled ? const Color(0xFF6C63FF) : Colors.white24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2131),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('معلومات الدرس',
              style: TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 8),
          _infoRow(Icons.play_circle_outline,
              _currentLesson.isYoutube ? 'فيديو YouTube' : 'رابط مباشر'),
          if (_currentLesson.downloadLink != null &&
              _currentLesson.downloadLink!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: GestureDetector(
                onTap: () => launchUrl(
                  Uri.parse(_currentLesson.downloadLink!),
                  mode: LaunchMode.externalApplication,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF43E97B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: const Color(0xFF43E97B).withOpacity(0.3)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.download_rounded,
                          color: Color(0xFF43E97B), size: 18),
                      SizedBox(width: 8),
                      Text('تحميل الدرس',
                          style: TextStyle(
                              color: Color(0xFF43E97B),
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white38),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.white60, fontSize: 13)),
      ],
    );
  }

  Widget _buildAllLessonsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('كل الدروس',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15)),
        const SizedBox(height: 10),
        ...widget.allLessons.asMap().entries.map((e) {
          final i = e.key;
          final l = e.value;
          final isCurrent = i == _currentIndex;
          return GestureDetector(
            onTap: () => _navigateLesson(i),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isCurrent
                    ? const Color(0xFF6C63FF).withOpacity(0.15)
                    : const Color(0xFF1A1D2E),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isCurrent ? const Color(0xFF6C63FF) : Colors.white12,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    l.isWatched
                        ? Icons.check_circle_rounded
                        : isCurrent
                            ? Icons.play_circle_filled_rounded
                            : Icons.play_circle_outline_rounded,
                    color: l.isWatched
                        ? const Color(0xFF43E97B)
                        : isCurrent
                            ? const Color(0xFF6C63FF)
                            : Colors.white38,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${i + 1}. ${l.name}',
                      style: TextStyle(
                        color: isCurrent ? Colors.white : Colors.white70,
                        fontSize: 13,
                        fontWeight:
                            isCurrent ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
