import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final File file;

  VideoPlayerWidget({required this.file});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitializing = true;
  bool _hasError = false;
  late Timer _timer;
  Duration _currentPosition = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.file(widget.file)
        ..initialize().then((_) {
          if (mounted) {
            setState(() {
              _isInitializing = false;
            });
            _controller.play();
            _startTimer();
          }
        }).catchError((error) {
          if (mounted) {
            setState(() {
              _isInitializing = false;
              _hasError = true;
            });
            print('Error initializing video: $error');
          }
        });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _hasError = true;
        });
        print('Error initializing video: $e');
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(milliseconds: 50), (Timer timer) {
      if (_controller.value.isPlaying) {
        setState(() {
          _currentPosition = _controller.value.position;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isInitializing
            ? Center(child: CircularProgressIndicator())
            : _hasError
                ? Center(child: Text('Error loading video'))
                : Column(
                    children: [
                      AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
                      VideoProgressIndicator(
                        _controller,
                        allowScrubbing: true,
                        padding: EdgeInsets.symmetric(vertical: 8),
                      ),
                      VideoControls(
                        controller: _controller,
                        currentPosition: _currentPosition,
                        onSeek: (position) {
                          _controller.seekTo(position);
                        },
                      ),
                    ],
                  ),
      ),
    );
  }
}

class VideoControls extends StatelessWidget {
  final VideoPlayerController controller;
  final Duration currentPosition;
  final void Function(Duration) onSeek;

  VideoControls({
    required this.controller,
    required this.currentPosition,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    final totalDuration = controller.value.duration;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.replay_10),
            onPressed: () {
              final newPosition = currentPosition - Duration(seconds: 10);
              onSeek(newPosition < Duration.zero ? Duration.zero : newPosition);
            },
          ),
          IconButton(
            icon: Icon(
                controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: () {
              if (controller.value.isPlaying) {
                controller.pause();
              } else {
                controller.play();
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.forward_10),
            onPressed: () {
              final newPosition = currentPosition + Duration(seconds: 10);
              onSeek(newPosition > totalDuration ? totalDuration : newPosition);
            },
          ),
        ],
      ),
    );
  }
}
