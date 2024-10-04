import 'package:gallery_app1/headers.dart';

class MediaProvider with ChangeNotifier {
  List<AssetEntity> _media = [];
  int _currentIndex = 0;

  List<AssetEntity> get media => _media;
  int get currentIndex => _currentIndex;

  void setMedia(List<AssetEntity> media) {
    _media = media;
    notifyListeners();
  }

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  Future<void> deleteCurrentImage() async {
    if (_currentIndex < 0 || _currentIndex >= _media.length) return;

    final currentAsset = _media[_currentIndex];
    final result = await PhotoManager.editor.deleteWithIds([currentAsset.id]);

    if (result.isNotEmpty && result.first == true) {
      _media.removeAt(_currentIndex);
      if (_media.isEmpty) {
        // Notify the app to pop or navigate as necessary
      } else {
        if (_currentIndex >= _media.length) {
          _currentIndex = _media.length - 1;
        }
      }
      notifyListeners();
    }
  }

  Future<String?> shareImage(BuildContext context, AssetEntity asset) async {
    final file = await asset.file;
    if (file != null) {
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/temp_image.jpg';
      await file.copy(path);
      await Share.shareFiles([path], text: 'Check out this image!');
      return 'Image shared successfully';
    } else {
      return 'No image to share';
    }
  }

  Future<String?> setAsWallpaper(
      BuildContext context, AssetEntity asset) async {
    final file = await asset.file;
    if (file != null) {
      try {
        String? selectedLocation = await showModalBottomSheet<String>(
          context: context,
          builder: (context) {
            return Platform.isAndroid
                ? _buildWallpaperLocationOptions(context)
                : _buildUnsupportedPlatformMessage();
          },
        );

        if (selectedLocation != null) {
          bool result;
          if (Platform.isAndroid) {
            result = await AsyncWallpaper.setWallpaperFromFile(
              filePath: file.path,
              wallpaperLocation: selectedLocation == 'both'
                  ? AsyncWallpaper.BOTH_SCREENS
                  : (selectedLocation == 'home'
                      ? AsyncWallpaper.HOME_SCREEN
                      : AsyncWallpaper.LOCK_SCREEN),
              goToHome: false,
            );

            return result
                ? 'Wallpaper set successfully'
                : 'Failed to set wallpaper';
          } else {
            return 'Setting wallpaper is not supported on this platform';
          }
        }
      } catch (e) {
        return 'Failed to set wallpaper: $e';
      }
    } else {
      return 'No image to set as wallpaper';
    }
    return 'no';
  }

  Future<void> shareVideo(AssetEntity videoAsset) async {
    final file = await videoAsset.file;
    if (file != null) {
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/temp_video.mp4';
      await file.copy(path);
      await Share.shareFiles([path], text: 'Check out this video!');
    }
  }

  // Future<void> hideMedia(BuildContext context, AssetEntity asset,
  //     HiddenMediaProvider hiddenMediaProvider, String mediaType) async {
  //   // Find if the media exists in the current media list
  //   final mediaToRemove =
  //       media.firstWhere((item) => item.id == asset.id, orElse: () => asset);
  //
  //   media.remove(mediaToRemove); // Remove from visible list
  //   hiddenMediaProvider.addHiddenMedia(asset);
  //   if (_currentIndex >= media.length) {
  //     _currentIndex = media.length - 1; // Prevent going out of bounds
  //   } // Add to hidden media list
  //   notifyListeners(); // Update the UI
  // }
  Future<void> hideMedia(BuildContext context, AssetEntity asset,
      HiddenMediaProvider hiddenMediaProvider, String mediaType) async {
    // Find the media to remove
    final mediaToRemove =
        media.firstWhere((item) => item.id == asset.id, orElse: () => asset);

    // Remove the media from the visible list
    if (media.contains(mediaToRemove)) {
      // Update the provider
      hiddenMediaProvider.addHiddenMedia(asset); // Add to hidden media list
      hiddenMediaProvider
          .removeMedia(asset); // Remove from visible list using provider

      // Notify the listeners to refresh the UI
      hiddenMediaProvider.notifyListeners();

      // Ensure the current index is valid after removal
      if (_currentIndex >= media.length) {
        _currentIndex = media.isNotEmpty ? media.length - 1 : 0;
      }
    }
  }

  Future<void> _saveHiddenAssetId(String assetId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> hiddenIds = prefs.getStringList('hidden_media_ids') ?? [];
    hiddenIds.add(assetId);
    await prefs.setStringList('hidden_media_ids', hiddenIds);
  }

  Widget _buildWallpaperLocationOptions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, 'home');
            },
            child: const Text("Home Screen",
                style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, 'lock');
            },
            child: const Text("Lock Screen",
                style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, 'both');
            },
            child: const Text("Home and Lock Screens",
                style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildUnsupportedPlatformMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Center(
          child: Text('Setting wallpaper is not supported on this platform')),
    );
  }
}
