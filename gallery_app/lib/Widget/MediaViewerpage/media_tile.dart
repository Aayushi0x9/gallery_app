import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gallery_app/Views/ImagePage/image1_page.dart';
import 'package:gallery_app/Views/VideoPage/video1_page.dart';
import 'package:gallery_app/controllers/album_controller.dart';
import 'package:gallery_app/controllers/hidden_controller.dart';
import 'package:gallery_app/controllers/media_controller.dart';
import 'package:gallery_app/utils/route_utils.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

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
    // loadMedia();
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
                      // Call the onImageDeleted callback here
                      await mediaProvider.deleteCurrentImage();
                      widget.onImageDeleted(asset); // Notify the deletion
                      // After deleting, you might want to update the UI or handle the deletion logic
                      setState(() {
                        widget.media.removeAt(_currentIndex);
                      });
                      // You might want to navigate back or handle it differently if it's the last item
                      if (widget.media.isEmpty) {
                        Navigator.pop(context);
                      }
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

  void onHideMedia(AssetEntity asset) async {
    final hiddenMediaProvider =
        Provider.of<HiddenMediaProvider>(context, listen: false);
    final mediaProvider = Provider.of<MediaProvider>(context, listen: false);

    // Hide the media
    await mediaProvider.hideMedia(context, asset, hiddenMediaProvider, 'image');

    // Update the hidden media provider to include this media
    hiddenMediaProvider.addHiddenMedia(asset);

    setState(() {
      // Remove the hidden media from the current media list
      widget.media.removeAt(_currentIndex);

      // Check if there is a next media to display
      if (_currentIndex < widget.media.length) {
        // Move to the next media
        _pageController.jumpToPage(_currentIndex);
      } else {
        // No more media, go to the previous one if available
        if (_currentIndex > 0) {
          _currentIndex = widget.media.length - 1;
          _pageController.jumpToPage(_currentIndex);
        } else {
          // No more media left, exit the viewer
          Navigator.pop(context);
        }
      }
    });

    // Reload the media from the album to reflect changes in the album pages
    await widget.loadMedia(); // Ensure this is invoked correctly
    loadMedia(); // Call any additional load if needed

    // Ensure the hidden media is shown in HiddenMediaPage by calling notify
    hiddenMediaProvider.notifyListeners(); // Notify listeners to refresh UI
  }

  Future<void> onTabTapped(int index) async {
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
      // mediaProvider.shareImage(context, widget.media[_currentIndex]);
    } else if (index == 2) {
      final confirmDelete = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Delete Media'),
          content: Text('Are you sure you want to delete this media?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmDelete == true) {
        await mediaProvider.deleteMedia(widget.media[_currentIndex]);
        widget.onImageDeleted(widget.media[_currentIndex]);
        if (widget.media.isEmpty) {
          Navigator.of(context).pop(); // Exit the viewer if no media left
        } else {
          setState(() {
            // Refresh the current page
            widget.media.removeAt(_currentIndex);
            // _pageController.jumpToPage(_currentIndex + 1);
            // Adjust _currentIndex if needed
            if (_currentIndex <= widget.media.length) {
              _pageController
                  .jumpToPage(_currentIndex - 1); // Move to the last item
            }
          });
        }
      }
    } else {
      showPopupMenu(context: context, asset: widget.media[_currentIndex]);
    }
  }

// Method to show popup menu
  void showPopupMenu({
    required BuildContext context,
    required AssetEntity asset,
  }) {
    final mediaProvider = Provider.of<MediaProvider>(context, listen: false);

    // Check if the asset is a video
    bool isVideo = asset.type == AssetType.video;

    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(
          700, 720, 50, 00), // Adjust position as needed
      items: [
        // Conditionally add 'Set As Wallpaper' only if the media is not a video
        if (!isVideo)
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
