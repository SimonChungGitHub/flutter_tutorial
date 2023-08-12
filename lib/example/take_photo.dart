import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tutorial/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:zoom_pinch_overlay/zoom_pinch_overlay.dart';
import 'package:image/image.dart' as img;
import '../config.dart';

class TakePhotoExample extends StatefulWidget {
  const TakePhotoExample({super.key});

  @override
  State<TakePhotoExample> createState() => _TakePhotoExampleState();
}

class _TakePhotoExampleState extends State<TakePhotoExample> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late CameraDescription camera;
  File? image;
  bool zoomMode = false;
  String mode = 'easy_image_viewer';
  late ProgressDialog pd;
  DateTime? lastPopTime;

  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;

  // Counting pointers (number of user fingers on screen)
  int _pointers = 0;

  @override
  void initState() {
    super.initState();
    //固定該頁面螢幕垂直不旋轉
    // SystemChrome.setPreferredOrientations(
    //     [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);
    if (zoomMode) {
      mode = 'easy_image_viewer';
    } else {
      mode = 'zoom_pinch_overlay';
    }
    debugPrint(
        '\u001b[31m ================initState==================== \u001b[0m');

    WidgetsFlutterBinding.ensureInitialized();
    availableCameras().then((cameras) {
      camera = cameras.first;
      _controller = CameraController(camera, ResolutionPreset.high,
          imageFormatGroup: ImageFormatGroup.jpeg);
      _initializeControllerFuture = _controller.initialize();
      _initializeControllerFuture.then((value) {
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
            showSnackBar(
                context, 'Camera error ${_controller.value.errorDescription}');
          }
        });
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    pd = ProgressDialog(context: context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'TakePhotoExample',
        ),
        backgroundColor: Colors.blue,
      ),
      body: body(),
    );
  }

  Widget body() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: [
            ///image_picker, ps:拍完照返回若有do something(ex:建立縮圖),會導致reBuild UI延遲
            ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('系統相機'),
                onPressed: () async {
                  final picker = ImagePicker();
                  final xFile = await picker.pickImage(
                      source: ImageSource.camera,
                      maxWidth: 1024,
                      maxHeight: 1024,
                      imageQuality: 100);
                  debugPrint('\u001b[31m 拍照返回xFile ${xFile!.path}. \u001b[0m');
                  final Stopwatch stopwatch = Stopwatch();
                  stopwatch.start();
                  _showLoadingDialog();
                  await Future.delayed(const Duration(seconds: 1));
                  File file = File(xFile.path);
                  String filename =
                      DateFormat('yyyyMMdd_HHmmss_SSS').format(DateTime.now());
                  String newPath = '${file.parent.path}/$filename.jpg';
                  image = await file.rename(newPath);
                  debugPrint('\u001b[31m rename ${image!.path}. \u001b[0m');
                  debugPrint(
                      '\u001b[31m ${stopwatch.elapsedMicroseconds / 1000} ms \u001b[0m');
                  stopwatch.stop();
                  setState(() => Navigator.pop(context));
                }),

            ///自製相機
            ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('自製相機'),
                onPressed: () async {
                  WidgetsFlutterBinding.ensureInitialized();
                  final cameras = await availableCameras();
                  camera = cameras.first;
                  _controller = CameraController(camera, ResolutionPreset.high,
                      imageFormatGroup: ImageFormatGroup.jpeg);
                  _initializeControllerFuture = _controller.initialize();
                  _initializeControllerFuture.then((value) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MaterialApp(
                            theme: ThemeData.dark(),
                            home: _openCamera(),
                          ),
                        ));
                  });
                }),

            ///dioUpload
            ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('上傳'),
                onPressed: () async {
                  final result = await _dioUpload();
                  if (result) {
                    final file = await _reSizeImage(image!, 256);
                    await _dioUploadFileDeleteFile(file);
                    await image!.delete();
                    image = null;
                    setState(() {});
                  }
                }),
          ],
        ),
        Row(
          children: [
            Switch(
                value: zoomMode,
                onChanged: (value) {
                  setState(() {
                    zoomMode = !zoomMode;
                    if (zoomMode) {
                      mode = 'easy_image_viewer';
                    } else {
                      mode = 'zoom_pinch_overlay';
                    }
                  });
                }),
            Text(
              mode,
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
        const SizedBox(
          width: 100,
          height: 5,
        ),
        Expanded(
          child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: zoomMode ? easyImageViewer() : zoomPinchOverlay()),
        ),
      ],
    );
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
        child: CameraPreview(
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
      body: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return OrientationBuilder(builder: (context, orientation) {
                if (orientation == Orientation.landscape) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _cameraPreviewWidget(_controller),
                      IconButton(
                          icon: const Icon(
                            Icons.camera_alt,
                          ),
                          iconSize: 60,
                          onPressed: () => _takePicture()),
                    ],
                  );
                } else {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _cameraPreviewWidget(_controller),
                      IconButton(
                          icon: const Icon(
                            Icons.camera_alt,
                          ),
                          iconSize: 60,
                          onPressed: () => _takePicture()),
                    ],
                  );
                }
              });
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
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
      String newPath =
          '${(await getTemporaryDirectory()).path}/${DateFormat('yyyyMMdd_HHmmss_SSS').format(DateTime.now())}.jpg';
      await xFile.saveTo(newPath);
      image = File(newPath);
      await File(xFile.path).delete();
      debugPrint('\u001b[31m ${image!.path} \u001b[0m');
      setState(() => Navigator.pop(context));
    } on Exception catch (_) {
      debugPrint('\u001b[31m ${_.toString()} \u001b[0m');
    }
  }

  ///開啟全螢幕畫面做圖片縮放
  Widget easyImageViewer() {
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
        // borderRadius: BorderRadius.circular(12),
        child: image == null
            ? null
            : Image.file(
                image!,
                fit: BoxFit.fitWidth,
                alignment: Alignment.topCenter,
              ),
      ),
    );
  }

  ///直接對圖片進行縮放
  Widget zoomPinchOverlay() {
    return ZoomOverlay(
      modalBarrierColor: Colors.black12,
      minScale: 0.8,
      maxScale: 2.5,
      animationCurve: Curves.fastOutSlowIn,
      animationDuration: const Duration(milliseconds: 300),
      twoTouchOnly: true,
      onScaleStart: () {},
      onScaleStop: () {},
      child: ClipRRect(
          child: image == null
              ? null
              : Image.file(
                  image!,
                  fit: BoxFit.fill,
                  alignment: Alignment.topCenter,
                )),
    );
  }

  Future<File> _reSizeImage(File jpgFile, width) async {
    String newPath = jpgFile.path.replaceAll('.jpg', '_$width.jpg');
    img.Image? srcImg = img.decodeImage(jpgFile.readAsBytesSync());
    img.Image? destImg = img.copyResize(srcImg!, width: width);
    File(newPath).writeAsBytesSync(img.encodePng(destImg));
    File newFile = File(newPath);
    debugPrint('\u001b[31m 建立檔案(resize) ${newFile.path} \u001b[0m');
    return newFile;
  }

  ///進度條
  _showLoadingDialog() {
    showDialog(
        context: context,
        barrierDismissible: false, //點擊遮罩不關閉對話框
        builder: (context) {
          return const UnconstrainedBox(
            constrainedAxis: Axis.vertical,
            child: SizedBox(
              width: 280,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0))),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CircularProgressIndicator(),
                    Padding(
                      padding: EdgeInsets.only(top: 26.0),
                      child: Text("相片載入中"),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  ///上傳
  Future<bool> _dioUpload() async {
    try {
      if (image == null) return false;
      pd.show(max: 100, msg: '檔案上傳 請稍後');
      await Future.delayed(const Duration(seconds: 1));
      //todo watermark
      var dio = Dio();
      FormData formData = FormData.fromMap(
          {"dept": "temp", "file": await MultipartFile.fromFile(image!.path)});
      final response = await dio.post(
        fileUploadURL,
        data: formData,
        onSendProgress: (int sent, int total) {
          int progress = (((sent / total) * 100).toInt());
          pd.update(value: progress);
        },
      );
      debugPrint('\u001b[31m ${response.data.toString()} \u001b[0m');
      return bool.parse(response.data.toString());
    } on Exception catch (_) {
      debugPrint('\u001b[31m ${_.toString()} \u001b[0m');
    }
    return false;
  }

  ///上傳後刪除
  Future<void> _dioUploadFileDeleteFile(file) async {
    try {
      if (file == null) return;
      var dio = Dio();
      FormData formData = FormData.fromMap(
          {"dept": "temp", "file": await MultipartFile.fromFile(file!.path)});
      final response = await dio.post(
        fileUploadURL,
        data: formData,
      );
      bool result = bool.parse(response.data.toString());
      if (result) debugPrint('\u001b[31m 上傳檔案 ${file.path} \u001b[0m');
      await file.delete();
      debugPrint('\u001b[31m 刪除檔案 ${file.path} \u001b[0m');
    } on Exception catch (_) {
      debugPrint('\u001b[31m ${_.toString()} \u001b[0m');
    }
  }
}
