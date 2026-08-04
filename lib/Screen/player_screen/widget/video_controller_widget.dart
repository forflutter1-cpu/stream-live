// import 'package:flutter/material.dart';
// import 'package:flutter_vlc_player/flutter_vlc_player.dart';
// import 'package:iptv/app_material/app_colors.dart';

// class VideoControls extends StatefulWidget {
//   final VlcPlayerController controller;
//   final VoidCallback onPlayPause;
//   final void Function()? onMenuPressed;
//   final void Function()? onNextPressed;
//   final void Function()? onPreviousPressed;
//   final void Function()? onPrevious10SecPressed;
//   final void Function()? onNext10Pressed;

//   const VideoControls({
//     super.key,
//     required this.controller,
//     required this.onPlayPause,
//     this.onMenuPressed,
//     this.onNextPressed,
//     this.onPreviousPressed,
//     this.onNext10Pressed,
//     this.onPrevious10SecPressed,
//   });

//   @override
//   _VideoControlsState createState() => _VideoControlsState();
// }

// class _VideoControlsState extends State<VideoControls> {
//   late Duration _duration;
//   late Duration _position;
//   bool _isDragging = false;

//   @override
//   void initState() {
//     super.initState();
//     _duration = widget.controller.value.duration;
//     _position = widget.controller.value.position;

//     widget.controller.addListener(videoListener);
//   }

//   void videoListener() {
//     if (mounted && !_isDragging) {
//       setState(() {
//         _position = widget.controller.value.position;
//         _duration = widget.controller.value.duration;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 120,
//       color: Colors.black54,
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: <Widget>[
//           SizedBox(
//             height: 20,
//             child: Slider(
//               value: _position.inSeconds.toDouble(),
//               min: 0.0,
//               max: _duration.inSeconds.toDouble(),
//               onChanged: (value) {
//                 setState(() {
//                   _isDragging = true;
//                   _position = Duration(seconds: value.toInt());
//                 });
//               },
//               onChangeEnd: (value) {
//                 widget.controller.seekTo(Duration(seconds: value.toInt()));
//                 setState(() {
//                   _isDragging = false;
//                 });
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 10.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: <Widget>[
//                 Text(_formatDuration(_position),
//                     style: const TextStyle(color: Colors.white)),
//                 Text(_formatDuration(_duration),
//                     style: const TextStyle(color: Colors.white)),
//               ],
//             ),
//           ),
//           SizedBox(
//             height: 40,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 Padding(
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
//                   child: IconButton(
//                       onPressed: widget.onPreviousPressed,
//                       icon: Icon(
//                         Icons.skip_next,
//                         color: widget.onPreviousPressed != null
//                             ? AppColors.whiteColor
//                             : AppColors.blacksub3Color,
//                       )),
//                 ),
//                 // IconButton(
//                 //     onPressed: widget.onPrevious10SecPressed,
//                 //     icon: const Icon(
//                 //       Icons.forward_10,
//                 //       color: AppColors.whiteColor,
//                 //     )),
//                 Padding(
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
//                   child: IconButton(
//                       onPressed: widget.onMenuPressed,
//                       icon: Icon(Icons.menu,
//                           color: widget.onMenuPressed != null
//                               ? AppColors.whiteColor
//                               : AppColors.blacksub3Color)),
//                 ),
//                 // IconButton(
//                 //     onPressed: widget.onNext10Pressed,
//                 //     icon: const Icon(Icons.replay_10,
//                 //         color: AppColors.whiteColor)),
//                 Padding(
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
//                   child: IconButton(
//                       onPressed: widget.onNextPressed,
//                       icon: Icon(Icons.skip_previous,
//                           color: widget.onNextPressed != null
//                               ? AppColors.whiteColor
//                               : AppColors.blacksub3Color)),
//                 ),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   String _formatDuration(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     final minutes = twoDigits(duration.inMinutes.remainder(60));
//     final seconds = twoDigits(duration.inSeconds.remainder(60));
//     return '${twoDigits(duration.inHours)}:$minutes:$seconds';
//   }
// }
