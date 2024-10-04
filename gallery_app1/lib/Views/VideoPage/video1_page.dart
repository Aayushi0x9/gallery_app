// ignore_for_file: avoid_print, library_private_types_in_public_api

import 'package:gallery_app1/headers.dart';

class VideoPage extends StatefulWidget {
  final File file;
  final int index;
  const VideoPage({
    super.key,
    required this.file,
    required this.index,
  });

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late VideoPlayerController _controller;
  bool _isInitializing = true;
  bool _hasError = false;
  Timer? _timer;
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
    _timer = Timer.periodic(const Duration(milliseconds: 100), (Timer timer) {
      if (_controller.value.isPlaying) {
        setState(() {
          _currentPosition = _controller.value.position;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _isInitializing
                  ? const Center()
                  : _hasError
                      ? const Center(child: Text('Error loading video'))
                      : AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    _formatDuration(_currentPosition),
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
                Expanded(
                  child: VideoProgressIndicator(
                    _controller,
                    allowScrubbing: true,
                    colors:
                        const VideoProgressColors(playedColor: Colors.indigo),
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    _formatDuration(_controller.value.duration),
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
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
    );
  }
}

class VideoControls extends StatelessWidget {
  final VideoPlayerController controller;
  final Duration currentPosition;
  final void Function(Duration) onSeek;

  const VideoControls({
    super.key,
    required this.controller,
    required this.currentPosition,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    final totalDuration = controller.value.duration;

    if (totalDuration == Duration.zero) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.replay_5),
            onPressed: () {
              final newPosition = currentPosition - const Duration(seconds: 5);
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
            icon: const Icon(Icons.forward_5),
            onPressed: () {
              final newPosition = currentPosition + const Duration(seconds: 5);
              onSeek(newPosition > totalDuration ? totalDuration : newPosition);
            },
          ),
        ],
      ),
    );
  }
}
