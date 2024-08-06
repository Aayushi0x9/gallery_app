// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:share/share.dart';
// import 'package:video_player/video_player.dart';
// import 'package:path_provider/path_provider.dart';
//
// class VideoPage extends StatefulWidget {
//   final List<File> files; // Changed from a single file to a list of files
//   final int initialIndex;
//   final VoidCallback onDelete; // Callback for when a video is deleted
//
//   VideoPage({
//     required this.files,
//     required this.initialIndex,
//     required this.onDelete,
//   });
//
//   @override
//   _VideoPageState createState() => _VideoPageState();
// }
//
// class _VideoPageState extends State<VideoPage> {
//   late VideoPlayerController _controller;
//   bool _isInitializing = true;
//   bool _hasError = false;
//   late Timer _timer;
//   Duration _currentPosition = Duration.zero;
//   bool _showBottomNavBar = false;
//   late int _currentIndex;
//
//   @override
//   void initState() {
//     super.initState();
//     _currentIndex = widget.initialIndex;
//     _initializeVideo();
//   }
//
//   Future<void> _initializeVideo() async {
//     try {
//       _controller = VideoPlayerController.file(widget.files[_currentIndex])
//         ..initialize().then((_) {
//           if (mounted) {
//             setState(() {
//               _isInitializing = false;
//             });
//             _controller.play();
//             _startTimer();
//           }
//         }).catchError((error) {
//           if (mounted) {
//             setState(() {
//               _isInitializing = false;
//               _hasError = true;
//             });
//             print('Error initializing video: $error');
//           }
//         });
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _isInitializing = false;
//           _hasError = true;
//         });
//         print('Error initializing video: $e');
//       }
//     }
//   }
//
//   void _startTimer() {
//     _timer = Timer.periodic(Duration(milliseconds: 100), (Timer timer) {
//       if (_controller.value.isPlaying) {
//         setState(() {
//           _currentPosition = _controller.value.position;
//         });
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _timer.cancel();
//     _controller.dispose();
//     super.dispose();
//   }
//
//   String _formatDuration(Duration duration) {
//     final minutes = duration.inMinutes;
//     final seconds = duration.inSeconds % 60;
//     return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
//   }
//
//   Future<void> _shareVideo() async {
//     final directory = await getTemporaryDirectory();
//     final path = '${directory.path}/temp_video.mp4';
//     await widget.files[_currentIndex].copy(path);
//     await Share.shareFiles([path], text: 'Check out this video!');
//   }
//
//   Future<void> _saveVideo() async {
//     final directory = await getExternalStorageDirectory();
//     final path = '${directory!.path}/saved_video_${_currentIndex}.mp4';
//     await widget.files[_currentIndex].copy(path);
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Video saved to $path')),
//     );
//   }
//
//   Future<void> _deleteVideo() async {
//     try {
//       await widget.files[_currentIndex].delete();
//       setState(() {
//         widget.files.removeAt(_currentIndex);
//       });
//       if (widget.files.isEmpty) {
//         widget.onDelete.call(); // Call the onDelete callback
//         Navigator.of(context).pop(); // Navigate back to the previous page
//       } else {
//         if (_currentIndex >= widget.files.length) {
//           _currentIndex = widget.files.length - 1;
//         }
//         _initializeVideo(); // Reinitialize the video player for the new video
//       }
//     } catch (e) {
//       print('Error deleting video: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: GestureDetector(
//         onTap: () {
//           setState(() {
//             _showBottomNavBar = !_showBottomNavBar;
//           });
//         },
//         child: Column(
//           children: [
//             Expanded(
//               child: Center(
//                 child: _isInitializing
//                     ? Center(child: CircularProgressIndicator())
//                     : _hasError
//                         ? Center(child: Text('Error loading video'))
//                         : AspectRatio(
//                             aspectRatio: _controller.value.aspectRatio,
//                             child: VideoPlayer(_controller),
//                           ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 8.0),
//               child: Row(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                     child: Text(
//                       _formatDuration(_currentPosition),
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ),
//                   Expanded(
//                     child: VideoProgressIndicator(
//                       _controller,
//                       allowScrubbing: true,
//                       padding: EdgeInsets.symmetric(vertical: 8.0),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                     child: Text(
//                       _formatDuration(_controller.value.duration),
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             VideoControls(
//               controller: _controller,
//               currentPosition: _currentPosition,
//               onSeek: (position) {
//                 _controller.seekTo(position);
//               },
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: _showBottomNavBar
//           ? BottomNavigationBar(
//               backgroundColor: Colors.black,
//               unselectedItemColor: Colors.white,
//               selectedItemColor: Colors.grey,
//               items: [
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.share),
//                   label: 'Share',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.save),
//                   label: 'Save',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Icon(Icons.delete),
//                   label: 'Delete',
//                 ),
//               ],
//               onTap: (index) {
//                 switch (index) {
//                   case 0:
//                     _shareVideo();
//                     break;
//                   case 1:
//                     _saveVideo();
//                     break;
//                   case 2:
//                     _deleteVideo();
//                     break;
//                 }
//               },
//             )
//           : null,
//     );
//   }
// }
//
// class VideoControls extends StatelessWidget {
//   final VideoPlayerController controller;
//   final Duration currentPosition;
//   final void Function(Duration) onSeek;
//
//   VideoControls({
//     required this.controller,
//     required this.currentPosition,
//     required this.onSeek,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final totalDuration = controller.value.duration;
//
//     if (totalDuration == Duration.zero) {
//       return SizedBox.shrink();
//     }
//
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           IconButton(
//             icon: Icon(Icons.replay_10),
//             onPressed: () {
//               final newPosition = currentPosition - Duration(seconds: 10);
//               onSeek(newPosition < Duration.zero ? Duration.zero : newPosition);
//             },
//           ),
//           IconButton(
//             icon: Icon(
//                 controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
//             onPressed: () {
//               if (controller.value.isPlaying) {
//                 controller.pause();
//               } else {
//                 controller.play();
//               }
//             },
//           ),
//           IconButton(
//             icon: Icon(Icons.forward_10),
//             onPressed: () {
//               final newPosition = currentPosition + Duration(seconds: 10);
//               onSeek(newPosition > totalDuration ? totalDuration : newPosition);
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:share/share.dart';
import 'package:path_provider/path_provider.dart';

class VideoPage extends StatefulWidget {
  final File file;
  final int index;
  VideoPage({
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
  late Timer _timer;
  Duration _currentPosition = Duration.zero;
  bool _showBottomNavBar = false;

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
    _timer = Timer.periodic(Duration(milliseconds: 100), (Timer timer) {
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

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _shareVideo() async {
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/temp_video.mp4';
    await widget.file.copy(path);
    await Share.shareFiles([path], text: 'Check out this video!');
  }

  Future<void> _saveVideo() async {
    final directory = await getExternalStorageDirectory();
    final path = '${directory!.path}/saved_video.mp4';
    await widget.file.copy(path);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Video saved to $path')),
    );
  }

  void _deleteVideo() async {
    await widget.file.delete();
    Navigator.pop(context, widget.index);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          setState(() {
            _showBottomNavBar = !_showBottomNavBar;
          });
        },
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: _isInitializing
                    ? Center()
                    : _hasError
                        ? Center(child: Text('Error loading video'))
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
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  Expanded(
                    child: VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      colors: VideoProgressColors(playedColor: Colors.indigo),
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      _formatDuration(_controller.value.duration),
                      style: TextStyle(color: Colors.black),
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
      ),
      bottomNavigationBar: _showBottomNavBar
          ? BottomNavigationBar(
              backgroundColor: Colors.black,
              unselectedItemColor: Colors.white,
              selectedItemColor: Colors.grey,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.share),
                  label: 'Share',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.save),
                  label: 'Save',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.delete),
                  label: 'Delete',
                ),
              ],
              onTap: (index) {
                switch (index) {
                  case 0:
                    _shareVideo();
                    break;
                  case 1:
                    _saveVideo();
                    break;
                  case 2:
                    _deleteVideo();

                    break;
                }
              },
            )
          : null,
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

    if (totalDuration == Duration.zero) {
      return SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.replay_5),
            onPressed: () {
              final newPosition = currentPosition - Duration(seconds: 5);
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
            icon: Icon(Icons.forward_5),
            onPressed: () {
              final newPosition = currentPosition + Duration(seconds: 5);
              onSeek(newPosition > totalDuration ? totalDuration : newPosition);
            },
          ),
        ],
      ),
    );
  }
}
