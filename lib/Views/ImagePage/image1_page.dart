import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';

class ImagePage extends StatelessWidget {
  final Uint8List? image;
  final File? imageFile;

  ImagePage({this.image, this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image'),
      ),
      body: Center(
        child: image != null
            ? InteractiveViewer(
                child: Image.memory(
                image!,
                fit: BoxFit.contain,
              ))
            : imageFile != null
                ? Image.file(imageFile!)
                : Text('No image available'),
      ),
    );
  }
}
