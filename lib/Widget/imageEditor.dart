// import 'dart:typed_data';
//
// import 'package:flutter/material.dart';
// import 'package:image/image.dart' as img;
//
// class EditImagePage extends StatefulWidget {
//   final Uint8List image;
//
//   EditImagePage({required this.image});
//
//   @override
//   _EditImagePageState createState() => _EditImagePageState();
// }
//
// class _EditImagePageState extends State<EditImagePage> {
//   Uint8List? _editedImage;
//   bool _isEditing = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _editedImage = widget.image;
//   }
//
//   Future<void> _editImage() async {
//     try {
//       // Decode the image
//       final image = img.decodeImage(widget.image);
//
//       if (image == null) return;
//
//       // Example resizing
//       img.Image resizedImage = img.copyResize(image, width: 800, height: 800);
//
//       // Example rotating
//       img.Image rotatedImage =
//           img.copyRotate(resizedImage, angle: 90); // Add the angle parameter
//
//       // Encode the image back to Uint8List
//       final editedImageBytes = Uint8List.fromList(img.encodeJpg(rotatedImage));
//
//       setState(() {
//         _editedImage = editedImageBytes;
//         _isEditing = false;
//       });
//     } catch (e) {
//       print('Error editing image: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Edit Image'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.check),
//             onPressed: () async {
//               if (_isEditing) {
//                 await _editImage();
//               } else {
//                 Navigator.pop(context, _editedImage);
//               }
//             },
//           )
//         ],
//       ),
//       body: Center(
//         child: _editedImage != null
//             ? Image.memory(_editedImage!)
//             : CircularProgressIndicator(),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           setState(() {
//             _isEditing = !_isEditing;
//           });
//         },
//         child: Icon(_isEditing ? Icons.done : Icons.edit),
//       ),
//     );
//   }
// }
