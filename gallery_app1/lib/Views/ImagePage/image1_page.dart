import 'package:gallery_app1/headers.dart';

class ImagePage extends StatefulWidget {
  final Uint8List? image;
  final File? imageFile;
  final VoidCallback? onDelete;

  const ImagePage({
    this.image,
    this.imageFile,
    this.onDelete,
    // required Future<Null> Function() onHide,
  });

  @override
  _ImagePageState createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  Uint8List? _imageBytes;
  void loadImage() {
    if (widget.image != null) {
      _imageBytes = widget.image!;
    } else if (widget.imageFile != null) {
      _imageBytes = widget.imageFile!.readAsBytesSync();
    }
    setState(() {}); // Trigger UI update after image is loaded
  }

  @override
  void initState() {
    super.initState();
    loadImage();
  }

  @override
  Widget build(BuildContext context) {
    return
        // PopScope(
        // canPop: true,
        // onPopInvokedWithResult: (bool canPop, dynamic result) {
        //   // Logic when the back button is pressed or navigation occurs, with result
        //   if (canPop) {
        //     // Perform any refresh or update logic before navigating back
        //     loadImage(); // Refresh the image
        //     // You can also process `result` if needed
        //     if (result != null) {
        //       // Handle the result if necessary
        //       print('Pop result: $result');
        //     }
        //   }
        // },
        // child:
        Scaffold(
      body: Center(
        child: _imageBytes != null
            ? InteractiveViewer(
                child: Image.memory(
                  _imageBytes!,
                  fit: BoxFit.contain,
                ),
              )
            : const Text('No image available'),
      ),
      // ),
    );
  }
}
