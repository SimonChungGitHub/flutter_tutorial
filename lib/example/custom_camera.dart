import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class CustomCamera extends StatefulWidget {
  final bool oneShot;

  const CustomCamera({super.key, this.oneShot = false});

  @override
  State<CustomCamera> createState() => CustomCameraState();
}

class CustomCameraState extends State<CustomCamera>
    with WidgetsBindingObserver {
  late CameraController _controller;
  Future<void>? _initializeControllerFuture;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;
  int _pointers = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    try {
      WidgetsFlutterBinding.ensureInitialized();
      availableCameras().then((cameras) async {
        final camera = cameras.first;
        _controller = CameraController(camera, ResolutionPreset.high,
            imageFormatGroup: ImageFormatGroup.jpeg);
        _initializeControllerFuture = _controller.initialize();
        await _initializeControllerFuture;
        setState(() {});
        _controller
            .getMaxZoomLevel()
            .then((double value) => _maxAvailableZoom = value);
        _controller
            .getMinZoomLevel()
            .then((double value) => _minAvailableZoom = value);

        ///If the controller is updated then update the UI.
        _controller.addListener(() {
          debugPrint('\u001b[31m listen............. \u001b[0m');
          if (mounted) setState(() {});
          if (_controller.value.hasError) {
            debugPrint(
                '\u001b[31m Camera error ${_controller.value.errorDescription} \u001b[0m');
          }
        });
      });
    } on Exception catch (_) {
      debugPrint('\u001b[31m Camera error ${_.toString()} \u001b[0m');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  ///暫不知用在何處適合,繼承 WidgetsBindingObserver
  ///init: WidgetsBinding.instance.addObserver(this);
  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.inactive) {
      debugPrint('\u001b[31m app inactive \u001b[0m');
      if (mounted) {
        if (widget.oneShot) Navigator.of(context).pop();
      }
    } else {
      debugPrint('\u001b[31m app active \u001b[0m');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _openCamera();
  }

  ///相機預覽
  Widget _cameraPreviewWidget(controller) {
    if (controller == null || !controller.value.isInitialized) {
      return const Text(
        'Tap a camera',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return Listener(
        onPointerDown: (_) => _pointers++,
        onPointerUp: (_) => _pointers--,
        child: Stack(
          alignment: AlignmentDirectional.center,
          fit: StackFit.loose,
          children: [
            CameraPreview(
              controller!,
              child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onScaleStart: _handleScaleStart,
                  onScaleUpdate: _handleScaleUpdate,
                  onTapDown: (TapDownDetails details) =>
                      _onViewFinderTap(details, constraints),
                );
              }),
            ),
            if (_pointers == 2)
              CircleAvatar(
                backgroundColor: Colors.black45,
                radius: 50.0,
                child: Text(
                  'x${_currentScale.toStringAsFixed(1)}',
                  style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Colors.white),
                ),
              )
          ],
        ),
      );
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseScale = _currentScale;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (_pointers != 2) return;
    _currentScale = (_baseScale * details.scale)
        .clamp(_minAvailableZoom, _maxAvailableZoom);
    await _controller.setZoomLevel(_currentScale);
    setState(() {
      debugPrint(
          '\u001b[31m 變焦倍率: x${_currentScale.toStringAsFixed(1)} \u001b[0m');
    });
  }

  void _onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    final CameraController cameraController = _controller;
    final Offset offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
  }

  ///開啟自製相機 (相機預覽 + 拍照按鈕)
  Widget _openCamera() {
    return Scaffold(
      body: SizedBox.expand(
        child: FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return OrientationBuilder(builder: (context, orientation) {
                  if (orientation == Orientation.landscape) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          flex: 85,
                          child: _cameraPreviewWidget(_controller),
                        ),
                        Expanded(
                          flex: 15,
                          child: IconButton(
                              icon: const Icon(
                                Icons.camera_alt,
                              ),
                              iconSize: 60,
                              onPressed: () => _takePicture()),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          flex: 85,
                          child: _cameraPreviewWidget(_controller),
                        ),
                        Expanded(
                          flex: 15,
                          child: IconButton(
                              icon: const Icon(
                                Icons.camera_alt,
                              ),
                              iconSize: 60,
                              onPressed: () => _takePicture()),
                        ),
                      ],
                    );
                  }
                });
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }),
      ),
    );
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      if (!_controller.value.isInitialized) {
        await _controller.initialize();
      }
      // A capture is already pending, do nothing.
      if (_controller.value.isTakingPicture) return;

      ///相機快門音效
      final player = AudioPlayer();
      await player.play(AssetSource('snapshot.mp3'));
      await _controller.setFocusMode(FocusMode.locked);
      final xFile = await _controller.takePicture();

      ///xFile存入指定路徑, 然後刪除xFile
      String newPath =
          '${(await getTemporaryDirectory()).path}/${DateFormat('yyyyMMdd_HHmmss_SSS').format(DateTime.now())}.jpg';
      await xFile.saveTo(newPath);
      await File(xFile.path).delete();
      debugPrint('\u001b[31m $newPath \u001b[0m');
      if (widget.oneShot) {
        setState(() {
          File image = File(newPath);
          Navigator.of(context).pop(image);
        });
      } else {
        ///相片存入相簿後刪除檔案
        await GallerySaver.saveImage(newPath);
        setState(() {});
      }
    } on Exception catch (_) {
      debugPrint('\u001b[31m ${_.toString()} \u001b[0m');
    }
  }
}
