// import 'package:gallery_app/headers.dart';
//
// class PhotosPage extends StatefulWidget {
//   @override
//   State<PhotosPage> createState() => _PhotosPageState();
// }
//
// class _PhotosPageState extends State<PhotosPage> {
//   bool _isPermissionGranted = false;
//   bool _isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _requestPermissionAndLoadAlbums();
//   }
//
//   Future<void> _requestPermissionAndLoadAlbums() async {
//     final PermissionStatus storagePermission = await Permission.storage.status;
//     final PermissionStatus manageStoragePermission =
//         await Permission.manageExternalStorage.status;
//
//     if (storagePermission.isGranted || manageStoragePermission.isGranted) {
//       _loadAlbums();
//     } else {
//       final result = await PhotoManager.requestPermissionExtend();
//       if (result.isAuth) {
//         _loadAlbums();
//       } else {
//         setState(() {
//           _isPermissionGranted = false;
//           _isLoading = false;
//         });
//       }
//     }
//   }
//
//   Future<void> _loadAlbums() async {
//     final albumsController =
//         Provider.of<AlbumsController>(context, listen: false);
//     await albumsController.requestPermissionAndLoadAlbums();
//
//     setState(() {
//       _isPermissionGranted = true;
//       _isLoading = false;
//     });
//   }
//
//   Future<Uint8List?> getAlbumThumbnail(AssetPathEntity album) async {
//     final List<AssetEntity> assets = await album.getAssetListRange(
//         start: 0, end: 1); // Get the first asset for thumbnail
//
//     if (assets.isNotEmpty) {
//       return await assets.first.thumbnailDataWithSize(
//         const ThumbnailSize.square(100), // Define the thumbnail size
//         quality: 80,
//       );
//     }
//
//     return null; // Return null if there are no assets in the album
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final albumsController = Provider.of<AlbumsController>(context);
//
//     return Scaffold(
//       // appBar: AppBar(
//       //   title: const Text("Albums"),
//       // ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _isPermissionGranted
//               ? FutureBuilder<List<AssetPathEntity>>(
//                   future: _getVisibleAlbums(albumsController),
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return const Center(child: CircularProgressIndicator());
//                     }
//
//                     if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                       return const Center(child: Text('No albums found.'));
//                     }
//
//                     return GridView.builder(
//                       controller: albumsController.gridScrollController,
//                       gridDelegate:
//                           const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 3,
//                         crossAxisSpacing: 4.0,
//                         mainAxisSpacing: 4.0,
//                       ),
//                       itemCount: snapshot.data!.length,
//                       itemBuilder: (context, index) {
//                         final AssetPathEntity album = snapshot.data![index];
//
//                         return FutureBuilder<Uint8List?>(
//                           future: getAlbumThumbnail(album),
//                           builder: (context, snapshot) {
//                             if (snapshot.connectionState ==
//                                 ConnectionState.waiting) {
//                               return Container(color: Colors.grey[200]);
//                             }
//                             return GestureDetector(
//                               onTap: () async {
//                                 // Navigate to a detailed view of the album when tapped
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) =>
//                                         AlbumDetailPage(album: album),
//                                   ),
//                                 );
//                               },
//                               child: snapshot.hasData
//                                   ? Image.memory(snapshot.data!,
//                                       fit: BoxFit.cover)
//                                   : Container(color: Colors.grey[200]),
//                             );
//                           },
//                         );
//                       },
//                     );
//                   },
//                 )
//               : Center(
//                   child: const Text(
//                       'Permission denied. Please allow access to photos.')),
//     );
//   }
//
//   Future<List<AssetPathEntity>> _getVisibleAlbums(
//       AlbumsController albumsController) async {
//     // Filter and sort the albums
//     final List<AssetPathEntity> allAlbums = albumsController.albums;
//
//     final List<AssetPathEntity> visibleAlbums = [];
//
//     for (final album in allAlbums) {
//       final List<AssetEntity> assets =
//           await album.getAssetListRange(start: 0, end: 1);
//       if (assets.isNotEmpty) {
//         visibleAlbums.add(album);
//       }
//     }
//
//     // Sort visible albums based on the latest asset added
//     visibleAlbums.sort((a, b) async {
//       final List<AssetEntity> assetsA =
//           await a.getAssetListRange(start: 0, end: 1);
//       final List<AssetEntity> assetsB =
//           await b.getAssetListRange(start: 0, end: 1);
//
//       final DateTime lastModifiedA =
//           assetsA.isNotEmpty ? assetsA.first.createDateTime : DateTime.now();
//       final DateTime lastModifiedB =
//           assetsB.isNotEmpty ? assetsB.first.createDateTime : DateTime.now();
//
//       return lastModifiedB.compareTo(lastModifiedA); // Sort in descending order
//     } as int Function(AssetPathEntity a, AssetPathEntity b)?);
//
//     return visibleAlbums;
//   }
// }
//
// class AlbumDetailPage extends StatelessWidget {
//   final AssetPathEntity album;
//
//   const AlbumDetailPage({Key? key, required this.album}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(album.name)),
//       body: FutureBuilder<int>(
//         future: album.assetCountAsync, // Await the asset count
//         builder: (context, countSnapshot) {
//           if (countSnapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (!countSnapshot.hasData || countSnapshot.data == 0) {
//             return const Center(child: Text('No media found.'));
//           }
//
//           // Once the asset count is ready, proceed to load the assets
//           return FutureBuilder<List<AssetEntity>>(
//             future: album.getAssetListRange(start: 0, end: countSnapshot.data!),
//             builder: (context, assetSnapshot) {
//               if (assetSnapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//
//               if (!assetSnapshot.hasData || assetSnapshot.data!.isEmpty) {
//                 return const Center(child: Text('No media found.'));
//               }
//
//               return GridView.builder(
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 3,
//                   crossAxisSpacing: 4.0,
//                   mainAxisSpacing: 4.0,
//                 ),
//                 itemCount: assetSnapshot.data!.length,
//                 itemBuilder: (context, index) {
//                   final AssetEntity asset = assetSnapshot.data![index];
//
//                   return FutureBuilder<Uint8List?>(
//                     future: asset.thumbnailDataWithSize(
//                       const ThumbnailSize.square(100),
//                       quality: 80,
//                     ),
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return Container(color: Colors.grey[200]);
//                       }
//
//                       return snapshot.hasData
//                           ? Image.memory(snapshot.data!, fit: BoxFit.cover)
//                           : Container(color: Colors.grey[200]);
//                     },
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
// import 'package:gallery_app/controllers/photos_controller.dart';
import 'package:gallery_app1/controllers/photos_controller.dart';
import 'package:gallery_app1/headers.dart';

class PhotosPage extends StatefulWidget {
  @override
  State<PhotosPage> createState() => _PhotosPageState();
}

class _PhotosPageState extends State<PhotosPage> {
  // bool _isPermissionGranted = false;
  // bool _isLoading = true;
  // List<AssetEntity> _allMedia = [];
  //
  // @override
  // void initState() {
  //   super.initState();
  //   // Request permission and load albums
  //   final photosController =
  //       Provider.of<PhotosController>(context, listen: false);
  //   if (!photosController.hasLoadedMedia) {
  //     _requestPermissionAndLoadAlbums();
  //   } else {
  //     setState(() {
  //       _isPermissionGranted = true;
  //       _isLoading = false; // Set loading to false if media is already loaded
  //     });
  //   }
  // }
  //
  // Future<void> _requestPermissionAndLoadAlbums() async {
  //   final PermissionStatus storagePermission = await Permission.storage.status;
  //   final PermissionStatus manageStoragePermission =
  //       await Permission.manageExternalStorage.status;
  //
  //   if (storagePermission.isGranted || manageStoragePermission.isGranted) {
  //     await _loadAlbums();
  //   } else {
  //     final result = await PhotoManager.requestPermissionExtend();
  //     if (result.isAuth) {
  //       await _loadAlbums();
  //     } else {
  //       setState(() {
  //         _isPermissionGranted = false;
  //         _isLoading = false;
  //       });
  //     }
  //   }
  // }
  //
  // Future<void> _loadAlbums() async {
  //   // Access the AlbumsController to load albums
  //   final albumsController =
  //       Provider.of<AlbumsController>(context, listen: false);
  //
  //   await albumsController.requestPermissionAndLoadAlbums();
  //   final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
  //     type: RequestType.image,
  //   );
  //
  //   List<AssetEntity> allMedia = [];
  //   for (final album in albums) {
  //     final int assetCount = await album.assetCountAsync;
  //
  //     // Fetch all assets in batches
  //     for (int i = 0; i < assetCount; i += 100) {
  //       final List<AssetEntity> assets =
  //           await album.getAssetListRange(start: i, end: i + 100);
  //       allMedia.addAll(assets);
  //     }
  //   }
  //
  //   setState(() {
  //     _allMedia = allMedia; // Store all media in the list
  //     _isPermissionGranted = true;
  //     _isLoading = false;
  //   });
  // }
  //
  // Future<Uint8List?> getAlbumThumbnail(AssetPathEntity album) async {
  //   final List<AssetEntity> assets =
  //       await album.getAssetListRange(start: 0, end: 1);
  //
  //   if (assets.isNotEmpty) {
  //     return assets.first.thumbnailDataWithSize(
  //       const ThumbnailSize.square(100), // Define the thumbnail size
  //       quality: 80,
  //     );
  //   }
  //
  //   return null; // Return null if there are no assets in the album
  // }
  //
  // Future<Uint8List?> _getThumbnail(AssetEntity asset) async {
  //   return await asset.thumbnailDataWithSize(
  //     const ThumbnailSize.square(100), // Define the thumbnail size
  //     quality: 80,
  //   );
  // }
  //
  @override
  Widget build(BuildContext context) {
    PhotosController photosController = Provider.of<PhotosController>(context);
    return Scaffold(
      body: photosController.isLoading
          ? const Center(child: CircularProgressIndicator())
          : photosController.isPermissionGranted
              ? photosController.allMedia.isEmpty
                  ? const Center(child: Text('No media found.'))
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 9,
                        mainAxisSpacing: 9,
                      ),
                      itemCount: photosController.allMedia.length,
                      itemBuilder: (context, index) {
                        return FutureBuilder<Uint8List?>(
                          future: photosController.allMedia[index]
                              .thumbnailDataWithSize(
                            const ThumbnailSize.square(100),
                            quality: 80,
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container(color: Colors.grey[200]);
                            }
                            return snapshot.hasData
                                ? Image.memory(snapshot.data!,
                                    fit: BoxFit.cover)
                                : Container(color: Colors.grey[200]);
                          },
                        );
                      },
                    )
              : const Center(
                  child: Text(
                    'Permission denied. Unable to load media.',
                  ),
                ),
    );
  }
}
