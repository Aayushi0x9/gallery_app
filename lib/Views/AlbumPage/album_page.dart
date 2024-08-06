import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gallery_app/Widget/MediaViewerpage/media_tile.dart';
import 'package:photo_manager/photo_manager.dart';

class AlbumPage extends StatefulWidget {
  final AssetPathEntity album;
  final int initialIndex;
  final VoidCallback? onDelete;
  AlbumPage({required this.album, this.initialIndex = 0, this.onDelete});

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

  void _removeImage(AssetEntity asset) async {
    try {
      // Get the file associated with the asset
      final file = await asset.file;

      if (file != null && await file.exists()) {
        // Delete the file
        await file.delete();

        // Remove the asset from the media list
        setState(() {
          _media.remove(asset);
        });

        // Check if the album is empty
        if (_media.isEmpty) {
          widget.onDelete?.call(); // Refresh the albums list
          Navigator.of(context).pop(); // Navigate back to AlbumsPage
        }
      } else {
        print('Asset file not found');
      }
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.album.name),
      ),
      body: _isLoading
          ? const Center()
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                  future: asset
                      .thumbnailDataWithSize(const ThumbnailSize.square(200)),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center();
                    } else if (snapshot.hasError || !snapshot.hasData) {
                      return const Center(
                          child: Text('Error loading thumbnail'));
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
              },
            ),
    );
  }

  void _openMediaViewer(BuildContext context, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MediaViewerPage.media_viewer(
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
