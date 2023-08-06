import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../utils.dart';

class CustomCamera extends StatefulWidget {
  const CustomCamera(this.initializeControllerFuture, this._controller, {super.key});

  final Future<void> initializeControllerFuture;
  final CameraController _controller;

  @override
  State<CustomCamera> createState() => CustomCameraState();
}

class CustomCameraState extends State<CustomCamera> {
  // late CameraController _controller;
  // late Future<void> _initializeControllerFuture;
  late CameraDescription camera;
  late File image;

  @override
  void initState() {
    super.initState();
    //固定該頁面螢幕垂直不旋轉
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    // WidgetsFlutterBinding.ensureInitialized();
    // availableCameras().then((cameras) async {
    //   camera = cameras.first;
    //   _controller = CameraController(
    //     camera,
    //     ResolutionPreset.high,
    //   );
    //   _initializeControllerFuture = _controller.initialize();
    // });
    //
    // Future.delayed(const Duration(seconds: 10));
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
        FutureBuilder<void>(
          future: widget.initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return CameraPreview(widget._controller);
            } else {
              // Otherwise, display a loading indicator.
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                  icon: const Icon(
                    Icons.camera_alt,
                  ),
                  iconSize: 60,
                  onPressed: () async {
                    try {
                      ///相機快門音效
                      final player = AudioPlayer();
                      await player.play(AssetSource('snapshot.mp3'));

                      ///碼表計時
                      final Stopwatch stopwatch = Stopwatch();
                      stopwatch.start();

                      await widget.initializeControllerFuture;
                      String newPath =
                          '${(await getTemporaryDirectory()).path}/${DateFormat('yyyyMMdd_HHmmss_SSS').format(DateTime.now())}.jpg';
                      widget._controller.setFocusMode(FocusMode.locked);
                      final xFile = await widget._controller.takePicture();

                      image = await File(xFile.path).rename(newPath);
                      debugPrint('\u001b[31m ${image.path} \u001b[0m');
                      debugPrint(
                          '\u001b[31m ${stopwatch.elapsedMicroseconds / 1000} ms \u001b[0m');
                      stopwatch.stop();
                    } on Exception catch (_) {
                      showSnackBar(context, _.toString());
                    } finally {
                      // Navigator.pop(context); //離開相機
                    }
                  }),
            ],
          ),
        ),
      ],
    );
  }

  Widget landscape(context) {
    return Row(
      children: [
        FutureBuilder<void>(
          future: widget.initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return CameraPreview(widget._controller);
            } else {
              // Otherwise, display a loading indicator.
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                  icon: const Icon(
                    Icons.camera_alt,
                  ),
                  iconSize: 60,
                  onPressed: () async {
                    try {
                      ///相機快門音效
                      final player = AudioPlayer();
                      await player.play(AssetSource('snapshot.mp3'));

                      ///碼表計時
                      final Stopwatch stopwatch = Stopwatch();
                      stopwatch.start();

                      await widget.initializeControllerFuture;
                      String newPath =
                          '${(await getTemporaryDirectory()).path}/${DateFormat('yyyyMMdd_HHmmss_SSS').format(DateTime.now())}.jpg';
                      widget._controller.setFocusMode(FocusMode.locked);
                      final xFile = await widget._controller.takePicture();

                      if (!mounted) return;
                      image = await File(xFile.path).rename(newPath);
                      debugPrint('\u001b[31m ${image.path} \u001b[0m');
                      debugPrint(
                          '\u001b[31m ${stopwatch.elapsedMicroseconds / 1000} ms \u001b[0m');
                      stopwatch.stop();
                    } on Exception catch (_) {
                      showSnackBar(context, _.toString());
                    } finally {
                      // Navigator.pop(context); //離開相機
                    }
                  }),
            ],
          ),
        ),
      ],
    );
  }
}
