import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tutorial/gallery_view/pick_images.dart';
import 'package:flutter_tutorial/gallery_view/view_photo.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../example/custom_camera.dart';
import '../example/custom_video_player.dart';
import '../utils.dart';

class VideoView extends StatefulWidget {
  const VideoView({super.key});

  static const MethodChannel _channel = MethodChannel('video_view');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  @override
  State<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  int crossAxisCount = 3;
  List<String> videoList = [];

  @override
  void initState() {
    super.initState();
    getVideoListFromCacheDirectory().then((value) {
      videoList = value;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text(
          '影片',
        ),
        actions: [
          IconButton(
            tooltip: '錄影機',
            icon: const Icon(
              Icons.videocam,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MaterialApp(
                    theme: ThemeData.dark(),
                    home: const CustomVideoPlayer(),
                  ),
                ),
              ).then((value) async {
                videoList = await getVideoListFromCacheDirectory();
                setState(() {});
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
            itemCount: videoList.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 6.0,
                mainAxisSpacing: 6.0),
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                onTap: () {
                  ///顯示自訂相簿
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) {
                            return ViewPhotos(
                              imageIndex: index,
                              imageList: videoList,
                              heroTitle: "image$index",
                            );
                          },
                          fullscreenDialog: true))
                      .then((value) async {
                    videoList = await getVideoListFromCacheDirectory();
                    setState(() {});
                  });
                },
                onLongPress: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PickImages(
                        imageList: videoList,
                        crossAxisCount: crossAxisCount,
                        index: index,
                      ),
                    ),
                  ).then((value) {
                    setState(() {
                      debugPrint('\u001b[31m $value \u001b[0m');
                    });
                  });
                },
                child: ClipRRect(
                  ///是 ClipRRect，不是 ClipRect
                  borderRadius: BorderRadius.circular(5),
                  child: Image.file(
                    File(videoList[index]),
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
