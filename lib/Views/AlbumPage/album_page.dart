import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gallery_app/Views/ViodeoPage/video1_page.dart';
import 'package:gallery_app/Widget/videoplayer_widget.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:gallery_app/Views/ImagePage/image1_page.dart';

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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.album.name),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : PageView.builder(
              controller: PageController(initialPage: widget.initialIndex),
              itemCount: _media.length,
              itemBuilder: (context, index) {
                final asset = _media[index];
                final type = asset.type; // Determine asset type

                return FutureBuilder<Uint8List?>(
                  future: _getThumbnailData(asset),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError || !snapshot.hasData) {
                      return Center(child: Text('Error loading media'));
                    } else {
                      final thumbnail = snapshot.data;

                      return GestureDetector(
                        onTap: () async {
                          if (type == AssetType.video) {
                            final file = await asset.file;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VideoPage(file: file!),
                              ),
                            );
                          } else if (type == AssetType.image) {
                            final file = await asset.file; // Get the image file
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ImagePage(
                                  image: null, // No thumbnail needed
                                  imageFile: file, // Pass the image file
                                ),
                              ),
                            );
                          }
                        },
                        child: type == AssetType.video
                            ? VideoPlayerWidget(asset: asset)
                            : Image.memory(thumbnail!),
                      );
                    }
                  },
                );
              },
            ),
    );
  }

  Future<Uint8List?> _getThumbnailData(AssetEntity asset) async {
    try {
      return await asset.thumbnailDataWithSize(
        ThumbnailSize.square(350),
        format: ThumbnailFormat.jpeg,
      );
    } catch (e) {
      print('Error getting thumbnail: $e');
      return null;
    }
  }
}
