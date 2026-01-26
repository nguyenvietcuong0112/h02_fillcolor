import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/models/saved_artwork_model.dart';

class GalleryViewerScreen extends StatelessWidget {
  final SavedArtworkModel artwork;

  const GalleryViewerScreen({super.key, required this.artwork});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(artwork.imageName),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: Center(
        child: Hero(
          tag: artwork.filePath,
          child: InteractiveViewer(
            minScale: 0.1,
            maxScale: 5.0,
            child: Image.file(
              File(artwork.filePath),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
