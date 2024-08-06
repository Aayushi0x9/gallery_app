import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

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

    if (totalDuration == Duration.zero) {
      return SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Text(_formatDuration(currentPosition)),
              Expanded(
                child: Slider(
                  value: currentPosition.inSeconds.toDouble(),
                  min: 0.0,
                  max: totalDuration.inSeconds.toDouble(),
                  onChanged: (value) {
                    onSeek(Duration(seconds: value.toInt()));
                  },
                ),
              ),
              Text(_formatDuration(totalDuration - currentPosition)),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.replay_10),
              onPressed: () {
                final newPosition = currentPosition - Duration(seconds: 10);
                onSeek(
                    newPosition < Duration.zero ? Duration.zero : newPosition);
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
                onSeek(
                    newPosition > totalDuration ? totalDuration : newPosition);
              },
            ),
          ],
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
