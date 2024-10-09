import 'package:gallery_app/headers.dart';

class MediaManager extends ChangeNotifier {
  final List<AlbumController> albumControllers = [];

  void addAlbum(Album album, BuildContext context) {
    AlbumController albumController = AlbumController(
      album,
      Provider.of<HiddenMediaProvider>(context, listen: false),
    );
    notifyListeners(); // Notify listeners of the change
  }

  // Method to get a specific AlbumController by index or identifier
  AlbumController getAlbumController(int index) {
    return albumControllers[index];
  }

  @override
  void dispose() {
    for (var controller in albumControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}

class Album {
  final String title;
  final List<AssetEntity> assets;

  Album(this.title, this.assets);

  Future<int> get assetCountAsync async {
    return assets.length; // Return the count of assets
  }

  Future<List<AssetEntity>> getAssetListRange({
    required int start,
    required int end,
  }) async {
    return assets.sublist(start, end); // Return the range of assets
  }
}

class AlbumController extends ChangeNotifier {
  final List<AssetEntity> media = [];
  bool isLoading = true;
  final ScrollController scrollController = ScrollController();
  int loadedAssets = 0;
  final int batchSize = 50; // Adjust based on performance
  final Album album; // Reference to the album
  final HiddenMediaProvider hiddenMediaProvider;

  AlbumController(this.album, this.hiddenMediaProvider) {
    loadMedia();
    scrollController.addListener(onScroll);
  }

  Future<void> loadMedia() async {
    try {
      final int assetCount = await album.assetCountAsync;
      final end = (loadedAssets + batchSize > assetCount)
          ? assetCount
          : loadedAssets + batchSize;

      if (loadedAssets < assetCount) {
        final mediaBatch = await album.getAssetListRange(
          start: loadedAssets,
          end: end,
        );

        // Retrieve hidden media IDs from SharedPreferences
        // final prefs = await SharedPreferences.getInstance();
        // List<String> hiddenIds = prefs.getStringList('hidden_media_ids') ?? [];

        // Filter out hidden media
        final visibleMedia = mediaBatch
            .where((asset) => !hiddenMediaProvider.hiddenMedia.contains(asset))
            .toList();

        media.addAll(visibleMedia);
        loadedAssets = end;
        isLoading = false;

        notifyListeners(); // Notify listeners of changes
      }
    } catch (e) {
      print('Error loading media: $e');
      isLoading = false;
      notifyListeners(); // Notify listeners of changes
    }
  }

  void onScroll() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200 &&
        !isLoading) {
      loadMoreMedia();
    }
  }

  Future<void> loadMoreMedia() async {
    isLoading = true;
    notifyListeners(); // Notify listeners of loading state change
    await loadMedia();
  }

  /// This function opens the media viewer page
  Future<void> openMediaViewer(BuildContext context, int index) async {
    final asset = media[index];

    final file = await asset.file;

    if (file != null) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MediaViewerPage(
            initialIndex: index,
            media: media, // Pass the list of AssetEntity
            onImageDeleted: (deletedAsset) {
              removeImage(deletedAsset); // Remove AssetEntity after deletion
            },
            loadMedia: () {
              loadMedia(); // Reload the media after an action if needed
            },
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load image')),
      );
    }
  }

  void removeImage(AssetEntity asset) async {
    try {
      media.remove(asset);
      notifyListeners(); // Notify listeners of media change

      if (media.isEmpty) {
        // Notify that the album is empty, handle any additional logic if needed
      }
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(onScroll);
    scrollController.dispose();
    super.dispose();
  }
}
