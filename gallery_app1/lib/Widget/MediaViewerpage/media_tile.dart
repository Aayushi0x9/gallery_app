import 'package:gallery_app1/Views/ImagePage/image1_page.dart';
import 'package:gallery_app1/Views/VideoPage/video1_page.dart';
import 'package:gallery_app1/headers.dart';

class MediaViewerPage extends StatefulWidget {
  final List<AssetEntity> media;
  final int initialIndex;
  final Function(AssetEntity) onImageDeleted;
  final Function loadMedia;

  const MediaViewerPage({
    super.key,
    required this.media,
    required this.initialIndex,
    required this.onImageDeleted,
    required this.loadMedia,
    // required Uint8List image,
  });

  @override
  _MediaViewerPageState createState() => _MediaViewerPageState();
}

class _MediaViewerPageState extends State<MediaViewerPage> {
  late PageController _pageController;
  int _currentIndex = 0;
  int currentBNBIndex = 0;
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    loadMedia();
  }

  Future<void> loadMedia() async {
    // You might want to get the media from the provider
    Provider.of<AlbumController>(context).loadedAssets;
    // Provider.of<AlbumController>(context).loadMedia();
    await Provider.of<AlbumController>(context, listen: false).loadMedia();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final mediaProvider =
        Provider.of<MediaProvider>(context); // Access MediaProvider
    Size size = MediaQuery.sizeOf(context);
    // final AssetEntity currentAsset = widget.media[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
            widget.loadMedia();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        // title: Text(currentAsset.type == AssetType.video ? 'Video' : 'Image'),
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
          if (index >= widget.media.length) {
            return const SizedBox.shrink();
          }

          final asset = widget.media[index];

          return FutureBuilder<File?>(
            future: asset.file,
            builder: (context, snapshot) {
              // if (snapshot.connectionState == ConnectionState.waiting) {
              //   return const Center(child: CircularProgressIndicator());
              // } else
              if (snapshot.hasError || !snapshot.hasData) {
                return const Center();
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
                    onDelete: () async {
                      await mediaProvider.deleteCurrentImage();
                    },
                  );
                }
              }
            },
          );
        },
      ),
      bottomNavigationBar: SizedBox(
        height: size.height * 0.08,
        child: BottomNavigationBar(
          iconSize: 23,
          type: BottomNavigationBarType.fixed,
          // backgroundColor: const Color(0xffFAD1E1),
          selectedItemColor: Colors.black,
          selectedLabelStyle: const TextStyle(
            fontFamily: 'AnekGujarati',
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'AnekGujarati',
          ),
          unselectedItemColor: Colors.grey,
          currentIndex: currentBNBIndex,
          onTap: onTabTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.share_outlined),
              label: 'Share',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.edit_outlined),
              label: 'Edit',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.delete_outline),
              label: 'Delete',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.more_vert_outlined),
              label: 'More',
            ),
          ],
        ),
      ),
    );
  }

  void onHideMedia(AssetEntity asset) {
    final hiddenMediaProvider =
        Provider.of<HiddenMediaProvider>(context, listen: false);
    final mediaProvider = Provider.of<MediaProvider>(context, listen: false);

    mediaProvider
        .hideMedia(context, asset, hiddenMediaProvider, 'image')
        .then((_) {
      // Remove the hidden media from the list
      setState(() {
        widget.media.removeAt(_currentIndex);
        if (_currentIndex < widget.media.length) {
          // Move to the next media
          _pageController.jumpToPage(_currentIndex);
        } else {
          // No more media, so go to the previous one if available
          if (_currentIndex > 0) {
            _currentIndex = widget.media.length - 1;
            _pageController.jumpToPage(_currentIndex);
          } else {
            // No more media left, exit the viewer
            Navigator.pop(context);
          }
        } // Remove the currently hidden media
      });

      // Check if there is a next item to display

      // Reload the media from the album to ensure the changes are reflected in the album pages
      widget.loadMedia;
      loadMedia();
      setState(() {});
      hiddenMediaProvider.notify();
    });
  }

  void onTabTapped(int index) {
    setState(() {
      currentBNBIndex = index;
    });

    // MediaProvider instance (make sure it is accessible in your widget)
    final mediaProvider = Provider.of<MediaProvider>(context,
        listen: false); // Assuming it's instantiated elsewhere
    // final hiddenMediaProvider =
    //     Provider.of<HiddenMediaProvider>(context, listen: false);
    // if (index == 0) {
    //   // Photos tab action
    //   mediaProvider.shareImage(context, widget.media[_currentIndex]);
    // } else
    if (index == 0) {
      mediaProvider.shareImage(context, widget.media[_currentIndex]);
    } else if (index == 1) {
      mediaProvider.shareImage(context, widget.media[_currentIndex]);
    } else if (index == 2) {
      // Get the asset for hiding
      final asset = widget.media[_currentIndex];
      setState(() {
        onHideMedia(asset); //
      });

      // onHideMedia(
      //     asset); // Call the hide media method// Call the hide media method
    } else if (index == 3) {
      if (_currentIndex < widget.media.length) {
        // Ensure _currentIndex is valid
        showPopupMenu(
            context: context,
            asset: widget.media[_currentIndex]); // Pass the current asset
      } else {
        // Handle case when _currentIndex is invalid
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid media index.')),
        );
      }
    }
  }

// Method to show popup menu
  void showPopupMenu(
      {required BuildContext context, required AssetEntity asset}) {
    // Size size = MediaQuery.sizeOf(context);
    final mediaProvider = Provider.of<MediaProvider>(context, listen: false);
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(
          700, 720, 50, 00), // Adjust position as needed
      items: [
        PopupMenuItem<String>(
          value: 'Set As Wallpaper',
          onTap: () {
            mediaProvider.setAsWallpaper(context, asset);
          },
          child: const Text(
            'Set As Wallpaper',
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              fontFamily: 'AnekGujarati',
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'Hide',
          onTap: () {
            onHideMedia(asset);
          },
          child: const Text(
            'Hide',
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              fontFamily: 'AnekGujarati',
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'Show Hidden',
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.hiddenPage);
          },
          child: const Text(
            'Show Hidden',
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              fontFamily: 'AnekGujarati',
            ),
          ),
        ),
      ],
    );
  }
}
