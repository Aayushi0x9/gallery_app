import 'package:gallery_app/headers.dart';

class HiddenMediaProvider with ChangeNotifier {
  List<AssetEntity> _hiddenMedia = []; // Store hidden media in memory
  Set<AssetEntity> _selectedMedia = {}; // For selection mode
  bool _isSelectionMode = false; // Flag to handle selection mode

  // Getters for media, selected items, and selection mode state
  List<AssetEntity> get hiddenMedia => _hiddenMedia;
  Set<AssetEntity> get selectedMedia => _selectedMedia;
  bool get isSelectionMode => _isSelectionMode;

  // Add media to hidden list and persist the change in SharedPreferences
  Future<void> addHiddenMedia(AssetEntity asset) async {
    _hiddenMedia.add(asset); // Add to the in-memory list
    await _saveHiddenAssetId(
        asset.id); // Save the asset ID to SharedPreferences
    notifyListeners(); // Notify listeners to update UI
  }

  // Save a hidden media asset ID in SharedPreferences
  Future<void> _saveHiddenAssetId(String assetId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> hiddenIds = prefs.getStringList('hidden_media_ids') ?? [];
    if (!hiddenIds.contains(assetId)) {
      hiddenIds.add(assetId); // Add new asset ID to the list
      await prefs.setStringList('hidden_media_ids', hiddenIds);
    }
  }

  // Fetch hidden media by reading the asset IDs from SharedPreferences
  Future<List<AssetEntity>> fetchHiddenMedia() async {
    final prefs = await SharedPreferences.getInstance();
    final hiddenAssetIds = prefs.getStringList('hidden_media_ids') ?? [];

    // Fetch all asset paths (this may depend on your app logic)
    final assetPathList =
        await PhotoManager.getAssetPathList(type: RequestType.all);
    final hiddenAssets = <AssetEntity>[];

    // Loop through asset paths and check if the asset ID is hidden
    for (final assetPath in assetPathList) {
      final assets = await assetPath.getAssetListPaged(page: 0, size: 100);
      hiddenAssets
          .addAll(assets.where((asset) => hiddenAssetIds.contains(asset.id)));
    }

    _hiddenMedia = hiddenAssets; // Update in-memory list
    notifyListeners(); // Notify listeners to update UI

    return hiddenAssets; // Return hidden assets
  }

  // Remove media from hidden list and SharedPreferences
  void removeMedia(AssetEntity asset) {
    _hiddenMedia.remove(asset); // Remove from the in-memory list
    _removeHiddenAssetId(asset.id); // Remove from SharedPreferences
    notifyListeners(); // Notify listeners to update UI
  }

  // Remove a hidden asset ID from SharedPreferences
  Future<void> _removeHiddenAssetId(String assetId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> hiddenIds = prefs.getStringList('hidden_media_ids') ?? [];
    if (hiddenIds.contains(assetId)) {
      hiddenIds.remove(assetId); // Remove the asset ID from the list
      await prefs.setStringList('hidden_media_ids', hiddenIds);
    }
  }

  // Toggle the selection mode (for multi-select actions like delete or unhide)
  void toggleSelectionMode() {
    _isSelectionMode = !_isSelectionMode;
    if (!_isSelectionMode)
      _selectedMedia
          .clear(); // Clear selected media when exiting selection mode
    notifyListeners();
  }

  // Toggle selection of a specific asset
  void toggleSelection(AssetEntity asset) {
    if (_selectedMedia.contains(asset)) {
      _selectedMedia.remove(asset);
    } else {
      _selectedMedia.add(asset);
    }
    notifyListeners();
  }

  // Unhide selected media (remove from hidden list and SharedPreferences)
  void unhideSelectedMedia() {
    _hiddenMedia.removeWhere((asset) => _selectedMedia.contains(asset));
    _selectedMedia.forEach((asset) =>
        _removeHiddenAssetId(asset.id)); // Remove from SharedPreferences
    _selectedMedia.clear();
    _isSelectionMode = false;
    notifyListeners();
  }

  // Delete selected media (permanently remove from hidden list)
  void deleteSelectedMedia() {
    _hiddenMedia.removeWhere((asset) => _selectedMedia.contains(asset));
    _selectedMedia.clear();
    _isSelectionMode = false;
    notifyListeners();
  }

  // Check if a media is selected in the selection mode
  bool isSelected(AssetEntity asset) {
    return _selectedMedia.contains(asset);
  }
}
