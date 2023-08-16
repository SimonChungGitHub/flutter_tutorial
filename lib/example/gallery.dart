import 'dart:io';

import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:galleryimage/galleryimage.dart';

import '../gallery_view/gallery_view.dart';

class MyGallery extends StatefulWidget {
  const MyGallery({super.key, required this.images});

  final List<File> images;

  @override
  State<MyGallery> createState() => MyGalleryState();
}

class MyGalleryState extends State<MyGallery> with WidgetsBindingObserver {
  List<String> imagesStr = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsFlutterBinding.ensureInitialized();
    for (File f in widget.images) {
      imagesStr.add(f.path);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  ///暫不知用在何處適合,繼承 WidgetsBindingObserver
  ///init: WidgetsBinding.instance.addObserver(this);
  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.inactive) {
      debugPrint('\u001b[31m app inactive \u001b[0m');
    } else {
      debugPrint('\u001b[31m app active \u001b[0m');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '相簿',
        ),
        backgroundColor: Colors.blue,
      ),
      body: GalleryView(imageList: imagesStr),
    );
  }

  Widget listView(images) {
    return ListView.builder(
      itemCount: images.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          title: easyImageViewer(images[index]),
          onTap: () {
            debugPrint('\u001b[31m ${images[index].path}  \u001b[0m');
          },
        );
      },
    );
  }

  ///source img = network
  Widget showImages(images) {
    return GalleryImage(
      imageUrls: images,
      numOfShowImages: 4,
      titleGallery: '我的相簿',
    );
  }

  Widget gridView(images) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, //每行三列
        mainAxisSpacing: 0,
        childAspectRatio: 1, //显示区域宽高相等
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return InkWell(
          highlightColor: Colors.orange,
          onTap: () {
            debugPrint('==================');
          },
          onLongPress: () {
            //todo navigator to edit page
          },
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: ClipRRect(
              ///是 ClipRRect，不是 ClipRect
              borderRadius: BorderRadius.circular(10),
              child: images[index] == null
                  ? null
                  : Image.file(
                      images[index]!,
                      fit: BoxFit.fill,
                      alignment: Alignment.topCenter,
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget easyImageViewer(image) {
    return GestureDetector(
      onTap: () {
        showImageViewerPager(
          context,
          SingleImageProvider(Image.file(image!).image),
          doubleTapZoomable: true,
        );
      },
      child: ClipRRect(
        ///是 ClipRRect，不是 ClipRect
        borderRadius: BorderRadius.circular(12),
        child: image == null
            ? null
            : Image.file(
                image!,
                fit: BoxFit.fill,
                alignment: Alignment.topCenter,
              ),
      ),
    );
  }
}
