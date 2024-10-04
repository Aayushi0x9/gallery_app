// ignore_for_file: avoid_print, use_build_context_synchronously, library_private_types_in_public_api

import 'package:gallery_app1/Views/HideMedia/hide_media.dart';
import 'package:gallery_app1/headers.dart';

class AlbumsPage extends StatefulWidget {
  const AlbumsPage(
      {super.key,
      required Null Function(dynamic visible) onToggleButtonVisibilityChanged});
  // final Null Function(dynamic visible) onToggleButtonVisibilityChanged;

  @override
  State<AlbumsPage> createState() => _AlbumsPageState();
}

class _AlbumsPageState extends State<AlbumsPage> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    final mutable = Provider.of<AlbumsController>(context);
    // PhotosController photosController = Provider.of<PhotosController>(context);
    return GestureDetector(
      onLongPress: () {
        // Add this to a relevant part of your app, e.g., a button or drawer menu
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HiddenMediaPage()),
        );
      },
      child: Scaffold(
        body: mutable.isLoading
            ? const Center(child: CircularProgressIndicator())
            : mutable.isLoading
                ? const Center(
                    child: Text(
                        'Permission denied. Please enable access to photos and videos in settings.'))
                : mutable.albums.isEmpty
                    ? const Center(child: Text('No albums available'))
                    : mutable.isGridView
                        ? Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFFFFFFF), Color(0xFFFFE3EC)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: LayoutBuilder(
                                  builder: (context, constraints) {
                                // instanceView();
                                return DraggableScrollbar.semicircle(
                                  controller: mutable.gridScrollController,
                                  child: GridView.builder(
                                    controller: mutable.gridScrollController,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                      childAspectRatio: 2 / 3,
                                    ),
                                    itemCount: mutable.albums.length,
                                    itemBuilder: (context, index) {
                                      final album = mutable.albums[index];
                                      return FutureBuilder<List<AssetEntity>>(
                                        future: album.getAssetListRange(
                                            start: 0, end: 1),
                                        builder: (context, snapshot) {
                                          // if (snapshot.connectionState ==
                                          //     ConnectionState.waiting) {
                                          //   return const Center();
                                          // } else
                                          if (snapshot.hasError ||
                                              !snapshot.hasData ||
                                              snapshot.data!.isEmpty) {
                                            return const SizedBox();
                                          } else {
                                            final asset = snapshot.data!.first;
                                            return GestureDetector(
                                              onTap: () async {
                                                final int assetCount =
                                                    await album.assetCountAsync;
                                                final List<AssetEntity> media =
                                                    await album
                                                        .getAssetListRange(
                                                            start: 0,
                                                            end: assetCount);
                                                if (media.isNotEmpty) {
                                                  // Fetch the asset count asynchronously
                                                  int assetCount = await album
                                                      .assetCountAsync;

                                                  // Convert AssetPathEntity to your Album model
                                                  Album albumModel = Album(
                                                    album
                                                        .name, // Assuming AssetPathEntity has a 'name' property
                                                    await album.getAssetListRange(
                                                        start: 0,
                                                        end:
                                                            assetCount), // Fetch the list of assets
                                                  );

                                                  // Initialize AlbumController for this album
                                                  AlbumController
                                                      albumController =
                                                      AlbumController(
                                                    albumModel,
                                                    Provider.of<
                                                            HiddenMediaProvider>(
                                                        context,
                                                        listen: false),
                                                  );

                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ChangeNotifierProvider
                                                              .value(
                                                        value:
                                                            albumController, // Provide the AlbumController to AlbumPage
                                                        child: AlbumPage(
                                                          album:
                                                              albumModel, // Pass the converted Album object
                                                          initialIndex: 0,
                                                          onDelete: () {
                                                            setState(() {
                                                              // Convert albumModel to AssetPathEntity before passing it to removeAlbum
                                                              AssetPathEntity
                                                                  assetPathEntity =
                                                                  convertAlbumToAssetPathEntity(
                                                                      albumModel);
                                                              mutable.removeAlbum(
                                                                  assetPathEntity); // Remove the album from the list

                                                              // Filter albums based on the current search text
                                                              mutable.filterAlbums(
                                                                  mutable
                                                                      .searchController
                                                                      .text);
                                                            });
                                                          },
                                                        ),
                                                        // HomePage(),
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                              child: FutureBuilder<Uint8List?>(
                                                future: mutable
                                                    .getThumbnailData(asset),
                                                builder: (context,
                                                    thumbnailSnapshot) {
                                                  // if (thumbnailSnapshot
                                                  //         .connectionState ==
                                                  //     ConnectionState.waiting) {
                                                  //   return const Center(
                                                  //       child:
                                                  //           CircularProgressIndicator());
                                                  // } else
                                                  if (thumbnailSnapshot
                                                          .hasError ||
                                                      !thumbnailSnapshot
                                                          .hasData) {
                                                    return const Center(
                                                        child: Text(
                                                            'Error loading image'));
                                                  } else {
                                                    final thumbnail =
                                                        thumbnailSnapshot.data;
                                                    return Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 5),
                                                          height: size.height *
                                                              0.14,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                            image:
                                                                DecorationImage(
                                                              image: MemoryImage(
                                                                  thumbnail!),
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          '\t\t${album.name}',
                                                          style:
                                                              const TextStyle(
                                                            color: Color(
                                                                0xff000000),
                                                            fontFamily:
                                                                'AnekGujarati',
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                        ),
                                                        FutureBuilder<int>(
                                                          future: album
                                                              .assetCountAsync, // The future that provides the album asset count
                                                          builder: (context,
                                                              snapshot) {
                                                            if (snapshot
                                                                    .connectionState ==
                                                                ConnectionState
                                                                    .waiting) {
                                                              return const Text(
                                                                '', // Show loading text while waiting for the asset count
                                                                style:
                                                                    TextStyle(
                                                                  color: Color(
                                                                      0xff989898),
                                                                  fontFamily:
                                                                      'AnekGujarati-Regular',
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                ),
                                                              );
                                                            } else if (snapshot
                                                                .hasError) {
                                                              return const Text(
                                                                'Error', // Show error if there is an issue getting the count
                                                                style:
                                                                    TextStyle(
                                                                  color: Color(
                                                                      0xff989898),
                                                                  fontFamily:
                                                                      'AnekGujarati-Regular',
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                ),
                                                              );
                                                            } else if (snapshot
                                                                .hasData) {
                                                              return Text(
                                                                '\t\t${snapshot.data.toString()}', // Show the asset count
                                                                style:
                                                                    const TextStyle(
                                                                  color: Color(
                                                                      0xff989898),
                                                                  fontFamily:
                                                                      'AnekGujarati',
                                                                  fontSize: 14,
                                                                  // fontWeight:
                                                                  //     FontWeight
                                                                  //         .w400,
                                                                ),
                                                              );
                                                            } else {
                                                              return const Text(
                                                                'No Data', // Handle the case where no data is available
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontFamily:
                                                                      'AnekGujarati-Regular',
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                ),
                                                              );
                                                            }
                                                          },
                                                        )
                                                      ],
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
                              }),
                            ),
                          )
                        : Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFFFFFFF), Color(0xFFFFE3EC)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            child:
                                LayoutBuilder(builder: (context, constraints) {
                              return DraggableScrollbar.semicircle(
                                controller: mutable.listScrollController,
                                child: ListView.builder(
                                  controller: mutable.listScrollController,
                                  itemCount: mutable.filteredAlbums.length,
                                  itemBuilder: (context, index) {
                                    final album = mutable.filteredAlbums[index];
                                    return GestureDetector(
                                      onTap: () async {
                                        final int assetCount =
                                            await album.assetCountAsync;
                                        final List<AssetEntity> media =
                                            await album.getAssetListRange(
                                                start: 0, end: assetCount);
                                        if (media.isNotEmpty) {
                                          // Fetch the asset count asynchronously
                                          int assetCount =
                                              await album.assetCountAsync;

                                          // Convert AssetPathEntity to your Album model
                                          Album albumModel = Album(
                                            album
                                                .name, // Assuming AssetPathEntity has a 'name' property
                                            await album.getAssetListRange(
                                                start: 0,
                                                end:
                                                    assetCount), // Fetch the list of assets
                                          );

                                          // Initialize AlbumController for this album
                                          AlbumController albumController =
                                              AlbumController(
                                            albumModel,
                                            Provider.of<HiddenMediaProvider>(
                                                context,
                                                listen: false),
                                          );

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ChangeNotifierProvider.value(
                                                value:
                                                    albumController, // Provide the AlbumController to AlbumPage
                                                child: AlbumPage(
                                                  album:
                                                      albumModel, // Pass the converted Album object
                                                  initialIndex: 0,
                                                  onDelete: () {
                                                    setState(() {
                                                      // Convert albumModel to AssetPathEntity before passing it to removeAlbum
                                                      AssetPathEntity
                                                          assetPathEntity =
                                                          convertAlbumToAssetPathEntity(
                                                              albumModel);
                                                      mutable.removeAlbum(
                                                          assetPathEntity); // Remove the album from the list

                                                      // Filter albums based on the current search text
                                                      mutable.filterAlbums(
                                                          mutable
                                                              .searchController
                                                              .text);
                                                    });
                                                  },
                                                ),
                                                // HomePage(),
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 5, horizontal: 16.0),
                                        child: Row(
                                          children: [
                                            // Image
                                            SizedBox(
                                              width: size.height *
                                                  0.15, // Adjust width as needed
                                              height: size.height *
                                                  0.1, // Adjust height as needed
                                              child: FutureBuilder<
                                                  List<AssetEntity>>(
                                                future: album.getAssetListRange(
                                                    start: 0, end: 1),
                                                builder: (context, snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return const SizedBox(); // Show a placeholder or an empty widget while loading
                                                  } else if (snapshot
                                                          .hasError ||
                                                      !snapshot.hasData ||
                                                      snapshot.data!.isEmpty) {
                                                    return const SizedBox();
                                                    // Show an empty widget in case of error or no data
                                                  } else {
                                                    final asset =
                                                        snapshot.data!.first;
                                                    return FutureBuilder<
                                                        Uint8List?>(
                                                      future: mutable
                                                          .getThumbnailData(
                                                              asset),
                                                      builder: (context,
                                                          thumbnailSnapshot) {
                                                        if (thumbnailSnapshot
                                                                .connectionState ==
                                                            ConnectionState
                                                                .waiting) {
                                                          return const SizedBox(); // Show a placeholder or an empty widget while loading
                                                        } else if (thumbnailSnapshot
                                                                .hasError ||
                                                            !thumbnailSnapshot
                                                                .hasData) {
                                                          return const SizedBox(); // Show an empty widget in case of error or no data
                                                        } else {
                                                          final thumbnail =
                                                              thumbnailSnapshot
                                                                  .data;
                                                          return Container(
                                                            margin:
                                                                const EdgeInsets
                                                                    .only(
                                                                    right: 25),
                                                            // height: size.height *
                                                            //     0.3, // Ensure this matches the height of the SizedBox
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              image:
                                                                  DecorationImage(
                                                                image: MemoryImage(
                                                                    thumbnail!),
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                      },
                                                    );
                                                  }
                                                },
                                              ),
                                            ),
                                            // Space between image and text
                                            // Album Name
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  album.name,
                                                  style: const TextStyle(
                                                    color: Color(0xff000000),
                                                    fontFamily: 'AnekGujarati',
                                                    fontSize:
                                                        16, // Adjust font size as needed
                                                    // fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                FutureBuilder<int>(
                                                  future: album
                                                      .assetCountAsync, // The future that provides the album asset count
                                                  builder: (context, snapshot) {
                                                    if (snapshot
                                                            .connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      return const Text(
                                                        'Loading...', // Show loading text while waiting for the asset count
                                                        style: TextStyle(
                                                          color:
                                                              Color(0xff989898),
                                                          fontFamily:
                                                              'AnekGujarati-Regular',
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      );
                                                    } else if (snapshot
                                                        .hasError) {
                                                      return const Text(
                                                        'Error', // Show error if there is an issue getting the count
                                                        style: TextStyle(
                                                          color:
                                                              Color(0xff989898),
                                                          fontFamily:
                                                              'AnekGujarati-Regular',
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      );
                                                    } else if (snapshot
                                                        .hasData) {
                                                      return Text(
                                                        '${snapshot.data.toString()}', // Show the asset count
                                                        style: const TextStyle(
                                                          color:
                                                              Color(0xff989898),
                                                          fontFamily:
                                                              'AnekGujarati',
                                                          fontSize: 14,
                                                          // fontWeight:
                                                          //     FontWeight
                                                          //         .w400,
                                                        ),
                                                      );
                                                    } else {
                                                      return const Text(
                                                        'No Data', // Handle the case where no data is available
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontFamily:
                                                              'AnekGujarati-Regular',
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      );
                                                    }
                                                  },
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }),
                          ),
      ),
    );
  }

  AssetPathEntity convertAlbumToAssetPathEntity(Album album) {
    // Implement this function based on how you can retrieve the corresponding AssetPathEntity
    // For example, if you have a list of AssetPathEntities, find the matching one based on the title or some other property
    // return correspondingAssetPathEntity;

    throw UnimplementedError("Conversion method not implemented.");
  }
}
