import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gallery_app/Views/AlbumPage/album_page.dart';
import 'package:photo_manager/photo_manager.dart';

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
    _loadAlbums();
  }

  Future<void> _loadAlbums() async {
    try {
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image | RequestType.video,
      );

      // Filter out empty albums
      final List<AssetPathEntity> nonEmptyAlbums = [];
      for (final album in albums) {
        final List<AssetEntity> assets =
            await album.getAssetListRange(start: 0, end: 1);
        if (assets.isNotEmpty) {
          nonEmptyAlbums.add(album);
        }
      }

      setState(() {
        _albums = nonEmptyAlbums;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading albums: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Albums'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _albums.isEmpty
              ? Center(child: Text('No albums available'))
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
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError ||
                            !snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Container(); // Should never reach here due to filtering
                        } else {
                          final asset = snapshot.data!.first;
                          return GestureDetector(
                            onTap: () async {
                              final int assetCount =
                                  await album.assetCountAsync;
                              final List<AssetEntity> media = await album
                                  .getAssetListRange(start: 0, end: assetCount);
                              if (media.isNotEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AlbumPage(
                                      album: album,
                                      initialIndex: 0,
                                      onDelete: () {
                                        setState(() {
                                          _albums.remove(album);
                                        });
                                      },
                                    ),
                                  ),
                                );
                              }
                            },
                            child: FutureBuilder<Uint8List?>(
                              future: _getThumbnailData(asset),
                              builder: (context, thumbnailSnapshot) {
                                if (thumbnailSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                } else if (thumbnailSnapshot.hasError ||
                                    !thumbnailSnapshot.hasData) {
                                  return Center(
                                      child: Text('Error loading image'));
                                } else {
                                  final thumbnail = thumbnailSnapshot.data;
                                  return Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: MemoryImage(thumbnail!),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    child: Align(
                                      alignment: Alignment.bottomLeft,
                                      child: Text(
                                        album.name,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
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
