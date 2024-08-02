import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gallery_app/Views/ImagePage/image1_page.dart';
import 'package:gallery_app/Views/ViodeoPage/video1_page.dart';
import 'package:photo_manager/photo_manager.dart';

class MediaTile extends StatelessWidget {
  final AssetEntity asset;

  MediaTile({required this.asset});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailData, // Request a larger thumbnail
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center();
        } else if (snapshot.hasError || !snapshot.hasData) {
          return Center(child: Text('Error loading image'));
        } else {
          final thumbnail = snapshot.data;
          return GestureDetector(
            onTap: () async {
              final file = await asset.file;
              final mediaType = asset.type;
              if (mediaType == AssetType.video) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoPage(file: file!),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImagePage(
                      imageFile: file!,
                    ),
                  ),
                );
              }
            },
            child: Image.memory(thumbnail!, fit: BoxFit.cover),
          );
        }
      },
    );
  }
}
