import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gallery_app/Views/ImagePage/image1_page.dart';
import 'package:gallery_app/Widget/MediaTile/media_tile.dart';
import 'package:gallery_app/Widget/videoplayer_widget.dart';
import 'package:photo_manager/photo_manager.dart';

class AlbumPage extends StatefulWidget {
  final AssetPathEntity album;
  final int initialIndex;

  AlbumPage({required this.album, this.initialIndex = 0});

  @override
  _AlbumPageState createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
  List<AssetEntity> _media = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedia();
  }

  Future<void> _loadMedia() async {
    try {
      final int assetCount = await widget.album.assetCountAsync;
      final media = await widget.album.getAssetListRange(
        start: 0,
        end: assetCount,
      );

      setState(() {
        _media = media;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading media: $e');
    }
  }

  void _removeImage(AssetEntity asset) {
    setState(() {
      _media.remove(asset);
    });
    if (_media.isEmpty) {
      Navigator.of(context).pop(); // Close the album page
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.album.name),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: _media.length,
              itemBuilder: (context, index) {
                final asset = _media[index];
                // final type = asset.type;
                // Determine asset type

                return FutureBuilder<Uint8List?>(
                  future:
                      asset.thumbnailDataWithSize(ThumbnailSize.square(200)),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError || !snapshot.hasData) {
                      return Center(child: Text('Error loading thumbnail'));
                    } else {
                      final Uint8List? thumbnail = snapshot.data;
                      return GestureDetector(
                        onTap: () => _openMediaViewer(context, index),
                        child: Image.memory(
                          thumbnail!,
                          fit: BoxFit.cover,
                        ),
                      );
                    }
                  },
                );

                // {
                //   if (snapshot.connectionState == ConnectionState.waiting) {
                //     return Center(child: CircularProgressIndicator());
                //   } else if (snapshot.hasError || !snapshot.hasData) {
                //     return Center(child: Text('Error loading media'));
                //   } else {
                //     final file = snapshot.data;
                //     if (type == AssetType.video && file != null) {
                //       return GestureDetector(
                //         onTap: () => _openVideoPage(context, file),
                //         child: VideoPlayerWidget(file: file),
                //       );
                //     } else if (type == AssetType.image && file != null) {
                //       return GestureDetector(
                //         onTap: () => _openImagePage(context, file, asset),
                //         child: Image.file(file, fit: BoxFit.cover),
                //       );
                //     } else {
                //       return Center(child: Text('Unsupported media type'));
                //     }
                //   }
                // },
              },
            ),
    );
  }

  void _openMediaViewer(BuildContext context, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MediaViewerPage(
          media: _media,
          initialIndex: index,
          onImageDeleted: (asset) {
            _removeImage(asset); // Remove the image from the list
          },
        ),
      ),
    );
  }
}

// void _openImagePage(BuildContext context, File file, AssetEntity asset) {
//   Navigator.of(context).push(
//     MaterialPageRoute(
//       builder: (context) => ImagePage(
//         imageFile: file,
//         onDelete: () => _removeImage(asset), // Callback for deletion
//       ),
//     ),
//   );
// }
//
// void _openVideoPage(BuildContext context, File file) {
//   // Implement video page navigation
// }
