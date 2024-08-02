import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPage extends StatefulWidget {
  final File file;

  VideoPage({required this.file});

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late VideoPlayerController _controller;
  bool _isInitializing = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.file(widget.file)
        ..addListener(() {
          if (_controller.value.hasError) {
            setState(() {
              _hasError = true;
              _isInitializing = false;
            });
          }
        })
        ..initialize().then((_) {
          if (mounted) {
            setState(() {
              _isInitializing = false;
            });
            _controller.play(); // Auto-play the video when it's ready
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video'),
      ),
      body: Center(
        child: _isInitializing
            ? Center(child: CircularProgressIndicator())
            : _hasError
                ? Center(child: Text('Error loading video'))
                : AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
      ),
      floatingActionButton: _isInitializing || _hasError
          ? null
          : FloatingActionButton(
              onPressed: () {
                setState(() {
                  if (_controller.value.isPlaying) {
                    _controller.pause();
                  } else {
                    _controller.play();
                  }
                });
              },
              child: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            ),
    );
  }
}
