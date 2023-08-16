import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tutorial/gallery_view/view_photo.dart';

class GalleryView extends StatelessWidget {
  final List<String> imageList;
  final int crossAxisCount;
  const GalleryView(
      {super.key, required this.imageList, this.crossAxisCount = 3});

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
        padding: const EdgeInsets.all(10),
        child: GridView.builder(
            itemCount: imageList.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 6.0,
                mainAxisSpacing: 6.0),
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                highlightColor: Colors.orange,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) {
                            return ViewPhotos(
                              imageIndex: index,
                              imageList: imageList,
                              heroTitle: "image$index",
                            );
                          },
                          fullscreenDialog: true));
                },
                onLongPress: () {
                  //todo navigator to edit page
                },
                child: ClipRRect(
                  ///是 ClipRRect，不是 ClipRect
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(imageList[index]),
                    fit: BoxFit.fill,
                    alignment: Alignment.topCenter,
                  ),
                ),
              );
            }),
      ),
    );
  }
}