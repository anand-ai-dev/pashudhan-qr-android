import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class AdPlayerWidget extends StatefulWidget {
  final String targetAudience;
  final String apiBaseUrl;

  const AdPlayerWidget({
    Key? key,
    required this.targetAudience,
    required this.apiBaseUrl,
  }) : super(key: key);

  @override
  State<AdPlayerWidget> createState() => _AdPlayerWidgetState();
}

class _AdPlayerWidgetState extends State<AdPlayerWidget> {
  VideoPlayerController? _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchAndPlayAd();
  }

  Future<void> _fetchAndPlayAd() async {
    try {
      final dio = Dio();
      final response = await dio.get(
        '${widget.apiBaseUrl}/v1/ads',
        queryParameters: {'targetAudience': widget.targetAudience},
      );

      final data = response.data as List;
        if (data.isNotEmpty) {
          final ad = data.first;
          final String rawVideoUrl = ad['videoUrl'];
          final String fullVideoUrl = '${widget.apiBaseUrl}/v1/ads/stream/$rawVideoUrl';
          
          final tempDir = await getTemporaryDirectory();
          final String filePrefix = 'ad_${widget.targetAudience}_';
          final String currentFileName = '${filePrefix}${ad['id']}.mp4';
          final String localPath = '${tempDir.path}/$currentFileName';
          final File localFile = File(localPath);

          // Cleanup old cached ads for this target audience to save device storage
          try {
            final directoryFiles = tempDir.listSync();
            for (var file in directoryFiles) {
              if (file is File) {
                final filename = file.uri.pathSegments.last;
                if (filename.startsWith(filePrefix) && filename != currentFileName) {
                  await file.delete();
                }
              }
            }
          } catch (e) {
            debugPrint('Failed to clean up old ads: $e');
          }

          if (!await localFile.exists()) {
            await dio.download(fullVideoUrl, localPath);
          }

          _controller = VideoPlayerController.file(
            localFile,
            videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
          );

          await _controller!.initialize().then((_) async {
            if (_controller!.value.hasError) {
              debugPrint('VideoPlayer Error: ${_controller!.value.errorDescription}');
              setState(() {
                _isLoading = false;
                _hasError = true;
              });
              return;
            }
            debugPrint('VideoPlayer initialized: ${_controller!.value.duration}');
            
            await _controller!.setLooping(true);
            await _controller!.setVolume(0.0); // Muted by default for auto-play
            await _controller!.play();

            setState(() {
              _isLoading = false;
            });
          });
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError || _controller == null || !_controller!.value.isInitialized) {
      return Container(
        alignment: Alignment.center,
        child: const Text(
          'Space For\nAdvertisement',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            color: Color(0xFF452B14),
            height: 1.15,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _controller!.value.size.width,
          height: _controller!.value.size.height,
          child: VideoPlayer(_controller!),
        ),
      ),
    );
  }
}
