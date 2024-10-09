import 'package:gallery_app/headers.dart';

class PhotosController extends ChangeNotifier {
  bool _isPermissionGranted = false;
  bool _isLoading = true;
  List<AssetEntity> _allMedia = [];

  bool get isPermissionGranted => _isPermissionGranted;
  bool get isLoading => _isLoading;
  List<AssetEntity> get allMedia => _allMedia;

  PhotosController() {
    _requestPermissionAndLoadAlbums();
  }
  void deleteMedia(AssetEntity asset) {
    _allMedia.remove(asset); // Remove asset from allMedia
    notifyListeners(); // Notify listeners to update the UI
  }

  Future<void> openMediaViewer(BuildContext context, int index) async {
    final asset = _allMedia[index];

    final file = await asset.file;

    if (file != null) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MediaViewerPage(
            initialIndex: index,
            media: _allMedia, // Pass the list of AssetEntity
            onImageDeleted: (deletedAsset) {
              deleteMedia(deletedAsset);
              notifyListeners(); // Remove AssetEntity after deletion
            },
            loadMedia: () {
              _loadAlbums();
              notifyListeners(); // Reload the media after an action if needed
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

  Future<void> _requestPermissionAndLoadAlbums() async {
    final PermissionStatus storagePermission = await Permission.storage.status;
    final PermissionStatus manageStoragePermission =
        await Permission.manageExternalStorage.status;

    if (storagePermission.isGranted || manageStoragePermission.isGranted) {
      await _loadAlbums();
    } else {
      final result = await PhotoManager.requestPermissionExtend();
      if (result.isAuth) {
        await _loadAlbums();
      } else {
        _isPermissionGranted = false;
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> _loadAlbums() async {
    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.image | RequestType.video,
    );

    List<AssetEntity> allMedia = [];
    for (final album in albums) {
      final int assetCount = await album.assetCountAsync;

      for (int i = 0; i < assetCount; i += 100) {
        final List<AssetEntity> assets =
            await album.getAssetListRange(start: i, end: i + 100);
        allMedia.addAll(assets);
      }
    }

    _allMedia = allMedia;
    _isPermissionGranted = true;
    _isLoading = false;
    notifyListeners();
  }
}
