import 'package:gallery_app1/headers.dart';

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
      type: RequestType.image,
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
