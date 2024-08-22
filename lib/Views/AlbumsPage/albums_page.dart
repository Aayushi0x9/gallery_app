import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gallery_app/Views/AlbumPage/album_page.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:permission_handler/permission_handler.dart';

class AlbumsPage extends StatefulWidget {
  @override
  _AlbumsPageState createState() => _AlbumsPageState();
}

class _AlbumsPageState extends State<AlbumsPage> {
  List<AssetPathEntity> _albums = [];
  List<AssetPathEntity> _filteredAlbums = [];
  bool _isLoading = true;
  bool _permissionGranted = false;
  bool _isSearching = false;
  bool _isGridView = true; // State variable for view type
  TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _requestPermissionAndLoadAlbums();
    _searchController.addListener(() {
      _filterAlbums(_searchController.text);
    });
  }

  // Future<void> _requestPermissionAndLoadAlbums() async {
  //   final PermissionState result = await PhotoManager.requestPermissionExtend();
  //   if (result.isAuth) {
  //     _loadAlbums();
  //     setState(() {
  //       _permissionGranted = true;
  //     });
  //   } else {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }
  Future<void> _requestPermissionAndLoadAlbums() async {
    final PermissionStatus storagePermission = await Permission.storage.status;
    final PermissionStatus manageStoragePermission =
        await Permission.manageExternalStorage.status;

    if (storagePermission.isGranted || manageStoragePermission.isGranted) {
      _loadAlbums();
      setState(() {
        _permissionGranted = true;
      });
    } else {
      final result = await PhotoManager.requestPermissionExtend();
      if (result.isAuth) {
        _loadAlbums();
        setState(() {
          _permissionGranted = true;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadAlbums() async {
    try {
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image | RequestType.video,
      );

      final List<AssetPathEntity> nonEmptyAlbums = [];
      for (final album in albums) {
        final List<AssetEntity> assets =
            await album.getAssetListRange(start: 0, end: 1);
        if (assets.isNotEmpty) {
          nonEmptyAlbums.add(album);
        }
      }
      // Separate the most recent album from the rest
      AssetPathEntity? recentAlbum;
      if (nonEmptyAlbums.isNotEmpty) {
        recentAlbum = nonEmptyAlbums.removeAt(0); // Assume first is most recent
      }

      // Sort the remaining albums alphabetically by name
      nonEmptyAlbums
          .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      // Add the recent album back to the top of the list
      if (recentAlbum != null) {
        nonEmptyAlbums.insert(0, recentAlbum);
      }

      setState(() {
        _albums = nonEmptyAlbums;
        _filteredAlbums = nonEmptyAlbums;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading albums: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterAlbums(String query) {
    final filteredAlbums = _albums.where((album) {
      return album.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredAlbums = filteredAlbums;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search albums',
                  border: InputBorder.none,
                ),
              )
            : const Text('Albums'),
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchController.clear();
                  _filteredAlbums = _albums; // Reset the filtered list
                });
              },
            ),
          IconButton(
            icon: Icon(_isGridView ? Icons.grid_view : Icons.list),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          const SizedBox(
            width: 16,
          )
        ],
      ),
      body: _isLoading
          ? const Center()
          : !_permissionGranted
              ? const Center(
                  child: Text(
                      'Permission denied. Please enable access to photos and videos in settings.'))
              : _filteredAlbums.isEmpty
                  ? const Center(child: Text('No albums available'))
                  : Scrollbar(
                      controller: _scrollController,
                      child: _isGridView
                          ? GridView.builder(
                              controller: _scrollController,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 4,
                                mainAxisSpacing: 4,
                              ),
                              itemCount: _filteredAlbums.length,
                              itemBuilder: (context, index) {
                                final album = _filteredAlbums[index];
                                return FutureBuilder<List<AssetEntity>>(
                                  future:
                                      album.getAssetListRange(start: 0, end: 1),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center();
                                    } else if (snapshot.hasError ||
                                        !snapshot.hasData ||
                                        snapshot.data!.isEmpty) {
                                      return Container();
                                    } else {
                                      final asset = snapshot.data!.first;
                                      return GestureDetector(
                                        onTap: () async {
                                          final int assetCount =
                                              await album.assetCountAsync;
                                          final List<AssetEntity> media =
                                              await album.getAssetListRange(
                                                  start: 0, end: assetCount);
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
                                                      _filterAlbums(
                                                          _searchController
                                                              .text);
                                                    });
                                                  },
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        child: FutureBuilder<Uint8List?>(
                                          future: _getThumbnailData(asset),
                                          builder:
                                              (context, thumbnailSnapshot) {
                                            if (thumbnailSnapshot
                                                    .connectionState ==
                                                ConnectionState.waiting) {
                                              return const Center(
                                                  child:
                                                      CircularProgressIndicator());
                                            } else if (thumbnailSnapshot
                                                    .hasError ||
                                                !thumbnailSnapshot.hasData) {
                                              return const Center(
                                                  child: Text(
                                                      'Error loading image'));
                                            } else {
                                              final thumbnail =
                                                  thumbnailSnapshot.data;
                                              return Container(
                                                padding:
                                                    const EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  image: DecorationImage(
                                                    image:
                                                        MemoryImage(thumbnail!),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                child: Align(
                                                  alignment:
                                                      Alignment.bottomLeft,
                                                  child: Text(
                                                    album.name,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              itemCount: _filteredAlbums.length,
                              itemBuilder: (context, index) {
                                final album = _filteredAlbums[index];
                                return FutureBuilder<List<AssetEntity>>(
                                  future:
                                      album.getAssetListRange(start: 0, end: 1),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center();
                                    } else if (snapshot.hasError ||
                                        !snapshot.hasData ||
                                        snapshot.data!.isEmpty) {
                                      return Container();
                                    } else {
                                      final asset = snapshot.data!.first;
                                      return ListTile(
                                        onTap: () async {
                                          final int assetCount =
                                              await album.assetCountAsync;
                                          final List<AssetEntity> media =
                                              await album.getAssetListRange(
                                                  start: 0, end: assetCount);
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
                                                      _filterAlbums(
                                                          _searchController
                                                              .text);
                                                    });
                                                  },
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        contentPadding:
                                            const EdgeInsets.all(8.0),
                                        leading: FutureBuilder<Uint8List?>(
                                          future: _getThumbnailData(asset),
                                          builder:
                                              (context, thumbnailSnapshot) {
                                            if (thumbnailSnapshot
                                                    .connectionState ==
                                                ConnectionState.waiting) {
                                              return const CircularProgressIndicator();
                                            } else if (thumbnailSnapshot
                                                    .hasError ||
                                                !thumbnailSnapshot.hasData) {
                                              return const Icon(Icons.error);
                                            } else {
                                              return Image.memory(
                                                thumbnailSnapshot.data!,
                                                fit: BoxFit.cover,
                                                width: 100,
                                                height: 70,
                                              );
                                            }
                                          },
                                        ),
                                        title: Text(album.name),
                                      );
                                    }
                                  },
                                );
                              },
                            ),
                    ),
    );
  }

  Future<Uint8List?> _getThumbnailData(AssetEntity asset) async {
    try {
      return await asset.thumbnailDataWithSize(
        const ThumbnailSize.square(200),
        format: ThumbnailFormat.jpeg,
      );
    } catch (e) {
      print('Error getting thumbnail: $e');
      return null;
    }
  }
}
