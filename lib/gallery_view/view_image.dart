import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../utils.dart';

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
          CircleAvatar(
            backgroundColor: Colors.black54,
            child: IconButton(
              onPressed: () async => deleteImage(),
              icon: const Icon(Icons.delete),
              color: Colors.white,
              iconSize: 25,
            ),
          ),
          CircleAvatar(
            backgroundColor: Colors.black54,
            child: IconButton(
              onPressed: () async => uploadImage(),
              icon: const Icon(Icons.upload),
              color: Colors.white,
              iconSize: 25,
            ),
          ),
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
        alignment: AlignmentDirectional.center,
        children: [
          PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            pageController: pageController,
            builder: (BuildContext context, int index) {
              //buttonShow = !buttonShow;
              return PhotoViewGalleryPageOptions(
                imageProvider: Image.file(File(widget.imageList[index])).image,
                initialScale: PhotoViewComputedScale.contained * 0.9,
                minScale: 0.5,
                heroAttributes:
                    PhotoViewHeroAttributes(tag: "photo${widget.imageIndex}"),
              );
            },
            onPageChanged: onPageChanged,
            itemCount: widget.imageList.length,
            loadingBuilder: (context, progress) => Center(
              child: (progress == null || progress.expectedTotalBytes == null)
                  ? const CircularProgressIndicator()
                  : CircularProgressIndicator(
                      value: progress.cumulativeBytesLoaded /
                          progress.expectedTotalBytes!,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> deleteImage() async {
    bool? result = await showAlertDialogWithButton(context, Icons.delete, '此張照片將被刪除');
    if (result!) {
      File image = File(widget.imageList[currentIndex]);
      image.deleteSync();
      widget.imageList.removeAt(currentIndex);
      if (widget.imageList.length <= currentIndex) {
        currentIndex--;
      }
      setState(() {
        if (currentIndex < 0) {
          Navigator.of(context).pop(widget.imageList);
        }
      });
    }
  }

  Future<void> uploadImage() async {
    debugPrint('\u001b[31m ===== upload... =====\u001b[0m');
    File file = File(widget.imageList[currentIndex]);
    var result = await dioUpload(context, file);
    if (result) {
      file.deleteSync();
      widget.imageList.removeAt(currentIndex);
      if (widget.imageList.length <= currentIndex) {
        currentIndex--;
      }
      setState(() {
        if (currentIndex < 0) {
          Navigator.of(context).pop(widget.imageList);
        }
      });
    }
  }
}
