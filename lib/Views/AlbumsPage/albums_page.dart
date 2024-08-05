import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:gallery_app/Views/AlbumPage/album_page.dart';

class AlbumsPage extends StatefulWidget {
  @override
  _AlbumsPageState createState() => _AlbumsPageState();
}

class _AlbumsPageState extends State<AlbumsPage> {
  List<AssetPathEntity> _albums = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final status = await Permission.photos.request();
    if (status.isGranted) {
      print('Permission granted');
      _loadAlbums();
    } else {
      print('Permission denied');
      setState(() {
        _isLoading = false;
      });
      _showPermissionDialog();
    }
  }

  Future<void> _loadAlbums() async {
    if (await Permission.photos.isGranted) {
      try {
        final List<AssetPathEntity> albums =
            await PhotoManager.getAssetPathList(
          type: RequestType.image | RequestType.video,
        );
        setState(() {
          _albums = albums;
          _isLoading = false;
        });
      } catch (e) {
        print('Error loading albums: $e');
      }
    } else {
      print('Permission not granted');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Permission Required'),
          content: Text(
              'This app needs access to your photos and videos to show albums.'),
          actions: [
            TextButton(
              child: Text('Settings'),
              onPressed: () {
                openAppSettings();
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Albums'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: _albums.length,
              itemBuilder: (context, index) {
                final album = _albums[index];
                return FutureBuilder<List<AssetEntity>>(
                  future: album.getAssetListRange(start: 0, end: 1),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError ||
                        !snapshot.hasData ||
                        snapshot.data!.isEmpty) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AlbumPage(
                                album: album,
                                initialIndex: 0,
                              ),
                            ),
                          );
                        },
                        child: Image.asset(
                          'assets/images/black.jpg',
                          fit: BoxFit.cover,
                        ),
                      );
                    } else {
                      final asset = snapshot.data!.first;
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AlbumPage(
                                album: album,
                                initialIndex: 0,
                              ),
                            ),
                          );
                        },
                        child: FutureBuilder<Uint8List?>(
                          future: _getThumbnailData(asset),
                          builder: (context, thumbnailSnapshot) {
                            if (thumbnailSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (thumbnailSnapshot.hasError ||
                                !thumbnailSnapshot.hasData) {
                              return Center(child: Text('Error loading image'));
                            } else {
                              final thumbnail = thumbnailSnapshot.data;
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: MemoryImage(thumbnail!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
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
        ThumbnailSize.square(200),
        format: ThumbnailFormat.jpeg,
      );
    } catch (e) {
      print('Error getting thumbnail: $e');
      return null;
    }
  }
}
