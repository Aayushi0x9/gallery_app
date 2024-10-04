import 'package:gallery_app1/headers.dart';

class HiddenMediaProvider with ChangeNotifier {
  List<AssetEntity> _hiddenMedia = [];
  Set<AssetEntity> _selectedMedia = {};
  bool _isSelectionMode = false;

  List<AssetEntity> get hiddenMedia => _hiddenMedia;
  Set<AssetEntity> get selectedMedia => _selectedMedia;
  bool get isSelectionMode => _isSelectionMode;

  void addHiddenMedia(AssetEntity asset) {
    if (!_hiddenMedia.contains(asset)) {
      _hiddenMedia.add(asset);
      _saveHiddenAssetId(asset.id);
      // Save hidden media ID to shared preferences

      notifyListeners(); // Notify listeners to update UI
    }
  }

  Future<void> _saveHiddenAssetId(String assetId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> hiddenIds = prefs.getStringList('hidden_media_ids') ?? [];
    if (!hiddenIds.contains(assetId)) {
      hiddenIds.add(assetId);
      await prefs.setStringList('hidden_media_ids', hiddenIds);
    }
    // notifyListeners();
  }

  notify() {
    notifyListeners();
  }

  Future<List<AssetEntity>> fetchHiddenMedia() async {
    final prefs = await SharedPreferences.getInstance();
    final hiddenAssetIds = prefs.getStringList('hidden_media_ids') ?? [];

    final assetPathList =
        await PhotoManager.getAssetPathList(type: RequestType.all);

    final hiddenAssets = <AssetEntity>[];
    for (final assetPath in assetPathList) {
      final assets = await assetPath.getAssetListPaged(page: 0, size: 100);
      hiddenAssets
          .addAll(assets.where((asset) => hiddenAssetIds.contains(asset.id)));
    }

    _hiddenMedia =
        hiddenAssets; // You can still keep this line to maintain the state
    notifyListeners();

    return hiddenAssets; // Return the list of hidden assets
  }

  void toggleSelectionMode() {
    _isSelectionMode = !_isSelectionMode;
    if (!_isSelectionMode) _selectedMedia.clear();
    notifyListeners();
  }

  void toggleSelection(AssetEntity asset) {
    if (_selectedMedia.contains(asset)) {
      _selectedMedia.remove(asset);
    } else {
      _selectedMedia.add(asset);
    }
    notifyListeners();
  }

  void unhideSelectedMedia() {
    _hiddenMedia.removeWhere((asset) => _selectedMedia.contains(asset));
    _selectedMedia.clear();
    _isSelectionMode = false;
    notifyListeners();
  }

  // Check if an asset is selected
  bool isSelected(AssetEntity asset) {
    return _selectedMedia.contains(asset);
  }

  void deleteSelectedMedia() {
    _hiddenMedia.removeWhere((asset) => _selectedMedia.contains(asset));
    _selectedMedia.clear();
    _isSelectionMode = false;
    notifyListeners();
  }

  // Delete individual media
  void deleteMedia(AssetEntity asset) {
    _hiddenMedia.remove(asset);
    notifyListeners();
  }

  void removeMedia(AssetEntity asset) {
    _hiddenMedia.remove(asset); // Remove from the hidden media list
    _removeHiddenAssetId(asset.id); // Remove from SharedPreferences
    notifyListeners(); // Notify UI to update
  }

  Future<void> _removeHiddenAssetId(String assetId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> hiddenIds = prefs.getStringList('hidden_media_ids') ?? [];
    if (hiddenIds.contains(assetId)) {
      hiddenIds.remove(assetId); // Remove the asset ID from the list
      await prefs.setStringList('hidden_media_ids', hiddenIds);
    }
  }
}
