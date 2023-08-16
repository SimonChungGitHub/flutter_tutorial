import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ViewPhotos extends StatefulWidget {
  final String heroTitle;
  final int imageIndex;
  final List<dynamic> imageList;

  const ViewPhotos(
      {super.key,
      this.imageIndex = 0,
      required this.imageList,
      this.heroTitle = "img"});

  @override
  ViewPhotosState createState() => ViewPhotosState();
}

class ViewPhotosState extends State<ViewPhotos> {
  late PageController pageController;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.imageIndex;
    pageController = PageController(initialPage: widget.imageIndex);
  }

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "${currentIndex + 1} out of ${widget.imageList.length}",
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.clear,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
        centerTitle: true,
        leading: Container(),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
      PhotoViewGallery.builder(
        scrollPhysics: const BouncingScrollPhysics(),
        pageController: pageController,
        builder: (BuildContext context, int index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: Image.file(File(widget.imageList[index])).image,
            heroAttributes:
                PhotoViewHeroAttributes(tag: "photo${widget.imageIndex}"),
          );
        },
        onPageChanged: onPageChanged,
        itemCount: widget.imageList.length,
        loadingBuilder: (context, progress) => Center(
          child: SizedBox(
            width: 60.0,
            height: 60.0,
            child: (progress == null || progress.expectedTotalBytes == null)
                ? const CircularProgressIndicator()
                : CircularProgressIndicator(
                    value: progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!,
                  ),
          ),
        ),
      ),
        ],
      ),
    );
  }
}
