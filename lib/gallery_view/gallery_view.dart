import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tutorial/gallery_view/view_photo.dart';

class GalleryView extends StatelessWidget {
  final List<String> imageUrlList;
  final int crossAxisCount;
  const GalleryView(
      {super.key, required this.imageUrlList, this.crossAxisCount = 3});

  static const MethodChannel _channel = MethodChannel('gallery_view');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
            itemCount: imageUrlList.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 6.0,
                mainAxisSpacing: 6.0),
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) {
                            return ViewPhotos(
                              imageIndex: index,
                              imageList: imageUrlList,
                              heroTitle: "image$index",
                            );
                          },
                          fullscreenDialog: true));
                },
                child: Hero(
                    tag: "photo$index",
                    child: Image.file(File(imageUrlList[index]),
                      fit: BoxFit.fill,
                    )),
              );
            }),
      ),
    );
  }
}