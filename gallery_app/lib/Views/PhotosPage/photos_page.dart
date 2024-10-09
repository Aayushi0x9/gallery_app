import 'package:gallery_app/controllers/photos_controller.dart';
import 'package:gallery_app/headers.dart';

class PhotosPage extends StatefulWidget {
  @override
  State<PhotosPage> createState() => _PhotosPageState();
}

class _PhotosPageState extends State<PhotosPage> {
  @override
  Widget build(BuildContext context) {
    PhotosController photosController = Provider.of<PhotosController>(context);
    return Scaffold(
      body: photosController.isLoading
          ? const Center(child: CircularProgressIndicator())
          : photosController.isPermissionGranted
              ? photosController.allMedia.isEmpty
                  ? const Center(child: Text('No media found.'))
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 9,
                        mainAxisSpacing: 9,
                      ),
                      itemCount: photosController.allMedia.length,
                      itemBuilder: (context, index) {
                        return FutureBuilder<Uint8List?>(
                          future: photosController.allMedia[index]
                              .thumbnailDataWithSize(
                            const ThumbnailSize.square(100),
                            quality: 80,
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container(color: Colors.grey[200]);
                            }
                            return snapshot.hasData
                                ? GestureDetector(
                                    onTap: () {
                                      photosController.openMediaViewer(
                                          context, index);
                                    },
                                    child: Image.memory(snapshot.data!,
                                        fit: BoxFit.cover),
                                  )
                                : Container(color: Colors.grey[200]);
                          },
                        );
                      },
                    )
              : const Center(
                  child: Text(
                    'Permission denied. Unable to load media.',
                  ),
                ),
    );
  }
}
