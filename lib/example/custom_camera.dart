import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

///使用 camera 拍照, 使用 gallery_saver 存入相簿
class CustomCamera extends StatefulWidget {
  const CustomCamera(this._initializeControllerFuture, this._controller,
      {super.key});

  final Future<void> _initializeControllerFuture;
  final CameraController _controller;

  @override
  State<CustomCamera> createState() => CustomCameraState();
}

class CustomCameraState extends State<CustomCamera> {
  late CameraDescription camera;
  late File image;
  DateTime? lastPopTime;

  @override
  void initState() {
    super.initState();
    //固定該頁面螢幕垂直不旋轉
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }

  @override
  void dispose() {
    widget._controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    Future.delayed(const Duration(seconds: 10));
    return Scaffold(
      body: OrientationBuilder(builder: (context, orientation) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight
        ]);
        if (orientation == Orientation.landscape) return landscape(context);
        return portrait(context);
      }),
    );
  }

  Widget portrait(context) {
    return Column(
      children: [
        Expanded(
          flex: 85,
          child: FutureBuilder<void>(
            future: widget._initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return CameraPreview(widget._controller);
              } else {
                // Otherwise, display a loading indicator.
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
        Expanded(
          flex: 15,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                  icon: const Icon(
                    Icons.camera_alt,
                  ),
                  iconSize: 60,
                  onPressed: () => onPressAndTakePhoto()),
            ],
          ),
        ),
      ],
    );
  }

  Widget landscape(context) {
    return Row(
      children: [
        Expanded(
          flex: 85,
          child: FutureBuilder<void>(
            future: widget._initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return CameraPreview(widget._controller);
              } else {
                // Otherwise, display a loading indicator.
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
        Expanded(
          flex: 15,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                  icon: const Icon(
                    Icons.camera_alt,
                  ),
                  iconSize: 60,
                  onPressed: () => onPressAndTakePhoto()),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> onPressAndTakePhoto() async {
    if (lastPopTime == null ||
        DateTime.now().difference(lastPopTime!) > const Duration(seconds: 1)) {
      try {
        await widget._initializeControllerFuture;
        //Error: select a camera first.
        if (!widget._controller.value.isInitialized) return;
        // // A capture is already pending, do nothing.
        if (widget._controller.value.isTakingPicture) return;
        widget._controller.setFocusMode(FocusMode.locked);
        final xFile = await widget._controller.takePicture();
        if (!mounted) return;

        ///相機快門音效
        final player = AudioPlayer();
        await player.play(AssetSource('snapshot.mp3'));

        String newPath =
            '${(await getTemporaryDirectory()).path}/${DateFormat('yyyyMMdd_HHmmss_SSS').format(DateTime.now())}.jpg';
        image = await File(xFile.path).rename(newPath);
        debugPrint('\u001b[31m ${image.path} \u001b[0m');
        ///相片存入相簿後刪除檔案
        await GallerySaver.saveImage(image.path);
        image.delete();
        setState(() {});
      } on Exception catch (_) {
        debugPrint('\u001b[31m ${_.toString()} \u001b[0m');
      }
      lastPopTime = DateTime.now();
    }
  }
}
