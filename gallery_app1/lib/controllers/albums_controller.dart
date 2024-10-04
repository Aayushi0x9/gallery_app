import 'package:gallery_app1/headers.dart';

class AlbumsController extends ChangeNotifier {
  List<AssetPathEntity> _albums = [];
  List<AssetPathEntity> filteredAlbums = [];
  bool _isLoading = true;
  // bool _permissionGranted = false;
  bool _isSearching = false;
  bool _isGridView = true;
  bool get isSearching => _isSearching;

  // Expose public controllers
  final ScrollController listScrollController = ScrollController();
  final ScrollController gridScrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  // Expose public properties
  List<AssetPathEntity> get albums => filteredAlbums;
  bool get isLoading => _isLoading;
  // bool get permissionGranted => _permissionGranted;

  bool get isGridView => _isGridView; // Expose isGridView
  void removeAlbum(AssetPathEntity album) {
    _albums.remove(album);
    filteredAlbums.remove(album); // Keep _filteredAlbums in sync
    notifyListeners(); // Notify listeners to rebuild
  }

  set isSearching(bool value) {
    _isSearching = value;
    notifyListeners();
  }

  void filterAlbums(String query) {
    if (query.isEmpty) {
      filteredAlbums = List.from(_albums); // Reset to all albums
    } else {
      filteredAlbums = _albums
          .where(
              (album) => album.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  set isGridView(bool value) {
    _isGridView = value;
    notifyListeners(); // Notify listeners to rebuild the UI
  }

  // Method to reset scroll positions
  void resetScrollPositions() {
    listScrollController.jumpTo(0); // Reset list view scroll position
    gridScrollController.jumpTo(0); // Reset grid view scroll position
  }

  Future<Uint8List?> getThumbnailData(AssetEntity asset) async {
    return asset.thumbnailDataWithSize(
      const ThumbnailSize.square(100),
      quality: 80,
    );
  }

  AlbumsController() {
    searchController.addListener(() {
      _filterAlbums(searchController.text);
    });
    _initScrollListeners();
  }

  // Toggle grid view
  void toggleGridView() {
    _isGridView = !_isGridView;
    notifyListeners();
  }

  // Start search
  void startSearching() {
    _isSearching = true;
    notifyListeners();
  }

  // Stop search
  void stopSearching() {
    _isSearching = false;
    searchController.clear(); // Clear search text
    filteredAlbums = _albums; // Reset to original list
    notifyListeners();
  }

  // Request permissions and load albums
  Future<void> requestPermissionAndLoadAlbums() async {
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

      nonEmptyAlbums
          .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      _albums = nonEmptyAlbums;
      filteredAlbums = nonEmptyAlbums;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading albums: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load albums from the photo manager
  // Future<void> _loadAlbums() async {
  //   try {
  //     final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
  //       type: RequestType.image | RequestType.video,
  //     );
  //
  //     final List<AssetPathEntity> nonEmptyAlbums = [];
  //     for (final album in albums) {
  //       final List<AssetEntity> assets =
  //           await album.getAssetListRange(start: 0, end: 1);
  //       if (assets.isNotEmpty) {
  //         nonEmptyAlbums.add(album);
  //       }
  //     }
  //
  //     nonEmptyAlbums
  //         .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  //
  //     _albums = nonEmptyAlbums;
  //     filteredAlbums = nonEmptyAlbums;
  //     _isLoading = false;
  //     notifyListeners();
  //   } catch (e) {
  //     print('Error loading albums: $e');
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }

  // Filter albums based on the search query
  void _filterAlbums(String query) {
    filteredAlbums = _albums.where((album) {
      return album.name.toLowerCase().contains(query.toLowerCase());
    }).toList();
    notifyListeners();
  }

  // Initialize scroll listeners
  void _initScrollListeners() {
    listScrollController.addListener(() {
      print('ListView Scroll Position: ${listScrollController.position}');
    });

    gridScrollController.addListener(() {
      print('GridView Scroll Position: ${gridScrollController.position}');
    });
  }

  // @override
  @override
  void dispose() {
    searchController.dispose();
    listScrollController.dispose();
    gridScrollController.dispose();
    super.dispose();
  }
}
