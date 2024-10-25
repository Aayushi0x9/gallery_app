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

class HiddenMediaPage extends StatefulWidget {
  const HiddenMediaPage({super.key});

  @override
  HiddenMediaPageState createState() => HiddenMediaPageState();
}

class HiddenMediaPageState extends State<HiddenMediaPage> {
  Future<void> _handleMediaNavigation(BuildContext context, int index) async {
    final mediaProvider =
        Provider.of<HiddenMediaProvider>(context, listen: false);
    List<AssetEntity> media = mediaProvider.hiddenMedia;

    if (media.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hidden media found.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MediaViewerPage(
          media: media,
          initialIndex: index,
          onImageDeleted: (asset) {
            mediaProvider.removeMedia(asset); // Use provider to delete asset
          },
          loadMedia: () {
            mediaProvider.fetchHiddenMedia(); // Refresh hidden media
          },
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    final provider = Provider.of<HiddenMediaProvider>(context, listen: false);
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'do you want to delete this media ?',
            style: TextStyle(
              fontFamily: 'AnekGujarati',
              fontSize: 20,
              color: Color(0xff000000),
            ),
          ),
          content: const Text(''),
          actions: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                alignment: Alignment.center,
                height: 36,
                width: 85,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xffF1F1F1),
                ),
                child: const Center(
                  child: Text(
                    textAlign: TextAlign.center,
                    "Cancel",
                    style: TextStyle(
                        fontFamily: 'AnekGujarati',
                        color: Color(0xff000000),
                        fontSize: 14,
                        fontWeight: FontWeight.w400),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                provider.deleteSelectedMedia();
                Navigator.of(context).pop();
              },
              child: Container(
                height: 36,
                width: 85,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xffC1003F),
                ),
                child: const Center(
                  child: Text(
                    textAlign: TextAlign.center,
                    "Delete",
                    style: TextStyle(
                        fontFamily: 'AnekGujarati',
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w400),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showUnhideConfirmationDialog(BuildContext context) async {
    final provider = Provider.of<HiddenMediaProvider>(context, listen: false);
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Do you want to Unhide this photos ?',
            style: TextStyle(
              fontFamily: 'AnekGujarati',
              fontSize: 20,
              color: Color(0xff000000),
            ),
          ),
          content: const Text(''),
          // content: const Text('Do you want to Unhide this photos ?'),
          actions: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                alignment: Alignment.center,
                height: 36,
                width: 85,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xffF1F1F1),
                ),
                child: const Center(
                  child: Text(
                    textAlign: TextAlign.center,
                    "Cancel",
                    style: TextStyle(
                        fontFamily: 'AnekGujarati',
                        color: Color(0xff000000),
                        fontSize: 14,
                        fontWeight: FontWeight.w400),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                provider.unhideSelectedMedia();
                Navigator.of(context).pop();
              },
              child: Container(
                height: 36,
                width: 85,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xffC1003F),
                ),
                child: const Center(
                  child: Text(
                    textAlign: TextAlign.center,
                    "Unhide",
                    style: TextStyle(
                        fontFamily: 'AnekGujarati',
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w400),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hiddenMediaProvider = Provider.of<HiddenMediaProvider>(context);
    final media = hiddenMediaProvider.hiddenMedia;
    return Scaffold(
      appBar: AppBar(
        centerTitle: hiddenMediaProvider.isSelectionMode ? false : true,
        leadingWidth: 30,
        leading: hiddenMediaProvider.isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  hiddenMediaProvider.toggleSelectionMode();
                },
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
        title: hiddenMediaProvider.isSelectionMode
            ? Text(
                '${hiddenMediaProvider.selectedMedia.length} Selected',
                style: const TextStyle(
                  fontFamily: 'AnekGujarati',
                  fontSize: 20,
                  color: Color(0xff000000),
                ),
              )
            : const Text(
                'Hidden Media',
                style: TextStyle(
                  fontFamily: 'AnekGujarati',
                  fontSize: 20,
                  color: Color(0xff000000),
                ),
              ),
        actions: hiddenMediaProvider.isSelectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    _showDeleteConfirmationDialog(context);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.visibility_off),
                  onPressed: () {
                    _showUnhideConfirmationDialog(context);
                  },
                ),
                const SizedBox(
                  width: 20,
                ),
              ]
            : null,
      ),
      body: hiddenMediaProvider.hiddenMedia.isEmpty
          ? const Center(child: Text('No hidden media'))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 4.0,
                ),
                itemCount: media.length,
                itemBuilder: (context, index) {
                  final asset = media[index];
                  final isVideo = asset.type == AssetType.video;

                  return GestureDetector(
                    onLongPress: () {
                      hiddenMediaProvider.toggleSelectionMode();
                    },
                    onTap: () {
                      if (hiddenMediaProvider.isSelectionMode) {
                        hiddenMediaProvider.toggleSelection(asset);
                      } else {
                        _handleMediaNavigation(context, index);
                      }
                    },
                    child: Stack(
                      children: [
                        FutureBuilder<Uint8List?>(
                          future: asset.thumbnailData, // Fetch the thumbnail
                          builder: (context, thumbnailSnapshot) {
                            if (thumbnailSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child:
                                    CircularProgressIndicator(), // Loading thumbnail
                              );
                            }

                            if (!thumbnailSnapshot.hasData ||
                                thumbnailSnapshot.data == null) {
                              return const Center();
                            }
                            return Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: MemoryImage(thumbnailSnapshot.data!),
                                  fit: BoxFit.cover,
                                ),
                                color: isVideo ? Colors.black : null,
                              ),
                              child: isVideo
                                  ? const Center(
                                      child: Icon(Icons.video_library,
                                          color: Colors.white, size: 40),
                                    )
                                  : null,
                            );
                          },
                        ),
                        if (hiddenMediaProvider.isSelectionMode)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () {
                                hiddenMediaProvider.toggleSelection(asset);
                              },
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: hiddenMediaProvider.selectedMedia
                                          .contains(asset)
                                      ? const Color(0xffC1003F)
                                      : const Color(0xffD9D9D9)
                                          .withOpacity(0.5),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xffFFFFFF),
                                    width: 1.0,
                                  ),
                                ),
                                child: hiddenMediaProvider.selectedMedia
                                        .contains(asset)
                                    ? const Icon(
                                        Icons.check,
                                        color: Color(0xffFFFFFF),
                                        size: 15.0,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              // },
            ),
    );
  }
}
