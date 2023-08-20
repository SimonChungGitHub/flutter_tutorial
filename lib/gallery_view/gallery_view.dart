import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tutorial/gallery_view/pick_images.dart';
import 'package:flutter_tutorial/gallery_view/view_photo.dart';

import '../example/custom_camera.dart';
import '../utils.dart';

class GalleryView extends StatefulWidget {
  const GalleryView({super.key});

  static const MethodChannel _channel = MethodChannel('gallery_view');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  @override
  State<GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
  int crossAxisCount = 3;
  List<String> imageList = [];

  @override
  void initState() {
    super.initState();
    dirList2().then((value) {
      setState(() {
        imageList = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text(
          '相簿',
        ),
        actions: [
          IconButton(
            tooltip: '選照片',
            icon: const Icon(
              Icons.task_alt,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PickImages(
                    imageList: imageList,
                    crossAxisCount: crossAxisCount,
                  ),
                ),
              ).then((value) {
                setState(() {
                  debugPrint('\u001b[31m $value \u001b[0m');
                });
              });
            },
          ),
          IconButton(
            tooltip: '相機',
            icon: const Icon(
              Icons.camera_alt,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MaterialApp(
                    theme: ThemeData.dark(),
                    home: const CustomCamera(),
                  ),
                ),
              ).then((value) {
                setState(() {
                  debugPrint('\u001b[31m $value \u001b[0m');
                });
              });
            },
          ),
          PopupMenuButton<Text>(itemBuilder: (context) {
            return [
              PopupMenuItem(
                child: const Text(
                  '大(2張)',
                ),
                onTap: () {
                  setState(() {
                    crossAxisCount = 2;
                  });
                },
              ),
              PopupMenuItem(
                child: const Text(
                  '中(3張)',
                ),
                onTap: () {
                  setState(() {
                    crossAxisCount = 3;
                  });
                },
              ),
              PopupMenuItem(
                child: const Text(
                  '小(4張)',
                ),
                onTap: () {
                  setState(() {
                    crossAxisCount = 4;
                  });
                },
              ),
            ];
          }),
        ],
      ),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PickImages(
                        imageList: imageList,
                        crossAxisCount: crossAxisCount,
                        index: index,
                      ),
                    ),
                  ).then((value) {
                    setState(() {
                      debugPrint('\u001b[31m $value \u001b[0m');
                    });
                  } );
                },
                child: ClipRRect(
                  ///是 ClipRRect，不是 ClipRect
                  borderRadius: BorderRadius.circular(5),
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
