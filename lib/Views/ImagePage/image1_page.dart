import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:image_editor/image_editor.dart';
import 'package:share/share.dart';
import 'package:path_provider/path_provider.dart';

class ImagePage extends StatefulWidget {
  final Uint8List? image;
  final File? imageFile;
  final VoidCallback? onDelete;

  ImagePage({this.image, this.imageFile, this.onDelete});

  @override
  _ImagePageState createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  bool _showBottomNavBar = false;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    if (widget.image != null) {
      _imageBytes = widget.image!;
    } else if (widget.imageFile != null) {
      _imageBytes = widget.imageFile!.readAsBytesSync();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image'),
      ),
      body: GestureDetector(
        onTap: () {
          setState(() {
            _showBottomNavBar = !_showBottomNavBar;
          });
        },
        child: Center(
          child: _imageBytes != null
              ? InteractiveViewer(
                  child: Image.memory(
                    _imageBytes!,
                    fit: BoxFit.contain,
                  ),
                )
              : Text('No image available'),
        ),
      ),
      bottomNavigationBar: _showBottomNavBar
          ? BottomNavigationBar(
              backgroundColor: Colors.black,
              unselectedItemColor: Colors.white,
              selectedItemColor: Colors.amberAccent,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.share),
                  label: 'Share',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.save),
                  label: 'Save',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.edit),
                  label: 'Edit',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.delete),
                  label: 'Delete',
                ),
              ],
              onTap: (index) {
                switch (index) {
                  case 0:
                    _shareImage();
                    break;
                  case 1:
                    _saveImage();
                    break;
                  case 2:
                    _editImage();
                    break;
                  case 3:
                    _deleteImage();
                    break;
                }
              },
            )
          : null,
    );
  }

  Future<void> _shareImage() async {
    if (_imageBytes != null) {
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/temp_image.jpg';
      final file = File(path)..writeAsBytesSync(_imageBytes!);
      await Share.shareFiles([path], text: 'Check out this image!');
    }
  }

  Future<void> _saveImage() async {
    if (_imageBytes != null) {
      final directory = await getExternalStorageDirectory();
      final path = '${directory!.path}/saved_image.jpg';
      final file = File(path)..writeAsBytesSync(_imageBytes!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image saved to $path')),
      );
    }
  }

  Future<void> _editImage() async {
    if (_imageBytes != null) {
      final ImageEditorOption editConfig = ImageEditorOption()
        ..addOption(ClipOption(x: 0, y: 0, width: 800, height: 800))
        ..addOption(RotateOption(90));

      final editedImage = await ImageEditor.editImage(
        image: _imageBytes!,
        imageEditorOption: editConfig,
      );

      setState(() {
        _imageBytes = editedImage;
      });
    }
  }

  Future<void> _deleteImage() async {
    if (widget.imageFile != null) {
      await widget.imageFile!.delete(); // Delete the image file
      widget.onDelete?.call(); // Call the callback to update the album list
      Navigator.pop(context); // Go back after deleting the image
    }
  }
}
