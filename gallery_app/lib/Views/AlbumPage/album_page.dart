import 'package:gallery_app/headers.dart';

class MediaFile {
  final String id;
  final String path;
  final bool isVideo;

  MediaFile({
    required this.id,
    required this.path,
    required this.isVideo,
  });
}

class AlbumPage extends StatefulWidget {
  final Album album;
  final int initialIndex;
  final VoidCallback onDelete;

  const AlbumPage({
    Key? key,
    required this.album,
    required this.initialIndex,
    required this.onDelete,
  }) : super(key: key);

  @override
  _AlbumPageState createState() => _AlbumPageState();
}

class _AlbumPageState extends State<AlbumPage> {
  @override
  Widget build(BuildContext context) {
    final lisnable = Provider.of<AlbumController>(context);
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          widget.album.title,
          style: TextStyle(
              fontFamily: 'AnekGujarati',
              fontSize: 20,
              color: Color(0xff000000)),
        ),
        leading: IconButton(
          onPressed: () {
            setState(() {
              Navigator.pop(context, lisnable.loadMedia());
            });
          },
          icon: const Icon(Icons.arrow_back),
        ),
        leadingWidth: size.width * 0.17,
        centerTitle: true,
      ),
      body: lisnable.isLoading && lisnable.media.isEmpty
          ? const Center()
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DraggableScrollbar.semicircle(
                controller: lisnable.scrollController,
                child: MasonryGridView.count(
                  controller: lisnable.scrollController,
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  itemCount:
                      lisnable.media.length + (lisnable.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == lisnable.media.length) {
                      return const Center(); // Show loading indicator at the end
                    }

                    final asset = lisnable.media[index];

                    return FutureBuilder<Uint8List?>(
                      future: asset.thumbnailDataWithSize(
                          const ThumbnailSize.square(200)),
                      builder: (context, snapshot) {
                        // Check if the data is available (i.e., the thumbnail is not null)
                        if (snapshot.hasData && snapshot.data != null) {
                          final Uint8List thumbnail = snapshot.data!;

                          // Calculate the aspect ratio
                          final double aspectRatio = asset.width / asset.height;

                          // Display the thumbnail if it is available
                          return GestureDetector(
                            onTap: () =>
                                lisnable.openMediaViewer(context, index),
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                image: DecorationImage(
                                  image: MemoryImage(thumbnail),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              width: MediaQuery.of(context).size.width / 2 - 8,
                              height:
                                  (MediaQuery.of(context).size.width / 2 - 8) /
                                      aspectRatio,
                            ),
                          );
                        }

                        // Show error text if there is no data or if there is an error
                        return const Center(
                            // child: Text('Error loading thumbnail'),
                            );
                      },
                    );
                  },
                ),
              ),
            ),
      bottomNavigationBar: Container(
        height: size.height * 0.08,
        child: BottomNavigationBar(
          iconSize: 23,
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xffFAD1E1),
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          currentIndex: _currentIndex,
          onTap: onTabTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.photo),
              label: 'Photos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.photo_library),
              label: 'Albums',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  int _currentIndex = 0;
  bool _showToggleButton = false;
  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;

      if (index == 1) {
        // Albums page is selected, show the toggle button for grid/list view
        _showToggleButton = true;
        Provider.of<AlbumsController>(context, listen: false).isSearching =
            false;
      } else if (index == 2) {
        // Search tab is selected, hide the toggle button and enter search mode
        _showToggleButton = false;
        Provider.of<AlbumsController>(context, listen: false).isSearching =
            true;
      } else {
        // Any other page, hide the toggle button and reset searching state
        _showToggleButton = false;
        Provider.of<AlbumsController>(context, listen: false).isSearching =
            false;
      }
      // Navigate back to HomePage with the selected index
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomePage(initialIndex: _currentIndex),
        ),
      );
    });
  }
// Future<void> _openMediaViewer(BuildContext context, int index) async {
  //   final asset = _media[index];
  //
  //   final file = await asset.file;
  //
  //   if (file != null) {
  //     await Navigator.of(context).push(
  //       MaterialPageRoute(
  //         builder: (context) => MediaViewerPage(
  //           initialIndex: index,
  //           media: _media, // Pass the list of AssetEntity
  //           onImageDeleted: (deletedAsset) {
  //             _removeImage(deletedAsset); // Remove AssetEntity after deletion
  //           },
  //           loadMedia: () {
  //             _loadMedia();
  //           },
  //         ),
  //       ),
  //     );
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Unable to load image')),
  //     );
  //   }
  // }
}
