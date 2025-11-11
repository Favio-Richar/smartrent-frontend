// ===============================================================
// 🎬 VIDEO PREVIEW - SmartRent+
// ---------------------------------------------------------------
// Reproductor de video para mostrar los videos de propiedades.
// Compatible con URLs del backend NestJS (http://10.0.2.2:3000/uploads/video/...).
// ===============================================================

import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class VideoPreview extends StatefulWidget {
  final String videoUrl;

  const VideoPreview({super.key, required this.videoUrl});

  @override
  State<VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  late VideoPlayerController _controller;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    await _controller.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _controller,
      autoPlay: false,
      looping: false,
      allowFullScreen: true,
      allowMuting: true,
      aspectRatio: _controller.value.aspectRatio,
    );
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_chewieController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: Chewie(controller: _chewieController!),
    );
  }
}
