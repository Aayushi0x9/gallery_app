import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gallery_app/Views/VideoPage/video1_page.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:gallery_app/Views/ImagePage/image1_page.dart';

class MediaViewerPage extends StatefulWidget {
  final List<AssetEntity> media;
  final int initialIndex;
  final void Function(AssetEntity) onImageDeleted;
  const MediaViewerPage.media_viewer({
    required this.media,
    required this.initialIndex,
    required this.onImageDeleted,
  });

  @override
  _MediaViewerPageState createState() => _MediaViewerPageState();
}

class _MediaViewerPageState extends State<MediaViewerPage> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final AssetEntity currentAsset = widget.media[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(currentAsset.type == AssetType.video ? 'Video' : 'Image'),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.media.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final asset = widget.media[index];
          return FutureBuilder<File?>(
            future: asset.file,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center();
              } else if (snapshot.hasError || !snapshot.hasData) {
                return const Center(child: Text('Error loading media'));
              } else {
                final file = snapshot.data!;
                if (asset.type == AssetType.video) {
                  return VideoPage(
                    file: file,
                    index: index,
                  );
                } else {
                  return ImagePage(
                    imageFile: file,
                    onDelete: () {
                      widget.onImageDeleted(asset); // Call the callback
                      Navigator.of(context).pop();
                    },
                  );
                }
              }
            },
          );
        },
      ),
    );
  }
}
