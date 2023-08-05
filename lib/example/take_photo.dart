import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    if (zoomMode) {
      mode = 'easy_image_viewer';
    } else {
      mode = 'zoom_pinch_overlay';
    }
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: [
              ///image_picker, ps:拍完照返回若有do something(ex:建立縮圖),會導致reBuild UI延遲
              ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('image_picker'),
                  onPressed: () async {
                    final picker = ImagePicker();
                    final xFile = await picker.pickImage(
                        source: ImageSource.camera,
                        maxWidth: 1024,
                        maxHeight: 1024,
                        imageQuality: 100);
                    debugPrint(
                        '\u001b[31m 拍照返回xFile ${xFile!.path}. \u001b[0m');
                    final Stopwatch stopwatch = Stopwatch();
                    stopwatch.start();
                    _showLoadingDialog();
                    await Future.delayed(const Duration(seconds: 1));
                    File file = File(xFile.path);
                    String filename = DateFormat('yyyyMMdd_HHmmss_SSS')
                        .format(DateTime.now());
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
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('自製相機'),
                  onPressed: () async {
                    WidgetsFlutterBinding.ensureInitialized();
                    final cameras = await availableCameras();
                    camera = cameras.first;
                    _controller = CameraController(
                      camera,
                      ResolutionPreset.high,
                    );
                    _initializeControllerFuture = _controller.initialize();
                    setState(() {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MaterialApp(
                              theme: ThemeData.dark(),
                              home: takePhotoScreen(),
                            ),
                          ));
                    });
                  }),

              ///dioUpload
              ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
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
                // alignment: Alignment.topCenter,
                // margin: const EdgeInsets.all(10),
                child: zoomMode ? easyImageViewer() : zoomPinchOverlay()),
          ),
        ],
      ),
    );
  }

  ///自製相機
  Widget takePhotoScreen() {
    return Scaffold(
      body: Column(
        children: [
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return CameraPreview(_controller);
              } else {
                // Otherwise, display a loading indicator.
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          Expanded(
            child: Container(
              color: Colors.black54,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.undo),
                    iconSize: 60,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  IconButton(
                      icon: const Icon(
                        Icons.camera_alt,
                      ),
                      iconSize: 60,
                      onPressed: () async {
                        try {
                          ///相機快門音效
                          final player = AudioPlayer();
                          await player.play(AssetSource('camera_sound.mp3'));

                          ///碼表計時
                          final Stopwatch stopwatch = Stopwatch();
                          stopwatch.start();

                          ///顯示相片下載 dialog
                          _showLoadingDialog();
                          await _initializeControllerFuture;
                          String newPath =
                              '${(await getTemporaryDirectory()).path}/${DateFormat('yyyyMMdd_HHmmss_SSS').format(DateTime.now())}.jpg';
                          _controller.setFocusMode(FocusMode.locked);
                          final xFile = await _controller.takePicture();

                          if (!mounted) return;
                          image = await File(xFile.path).rename(newPath);
                          debugPrint('\u001b[31m ${image!.path} \u001b[0m');
                          debugPrint(
                              '\u001b[31m ${stopwatch.elapsedMicroseconds / 1000} ms \u001b[0m');
                          stopwatch.stop();
                        } on Exception catch (_) {
                          _showSnackBar(_.toString());
                        } finally {
                          setState(() {
                            Navigator.pop(context); // 進度條dismiss
                            Navigator.pop(context); //離開相機
                          });
                        }
                      }),
                ],
              ),
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //     onPressed: () async {
      //       try {
      //         ///相機快門音效
      //         final player = AudioPlayer();
      //         await player.play(AssetSource('camera_sound.mp3'));
      //
      //         ///碼表計時
      //         final Stopwatch stopwatch = Stopwatch();
      //         stopwatch.start();
      //
      //         ///顯示相片下載 dialog
      //         _showLoadingDialog();
      //         await _initializeControllerFuture;
      //         final xFile = await _controller.takePicture();
      //         if (!mounted) return;
      //         image = File(xFile.path);
      //         debugPrint(
      //             '\u001b[31m ${stopwatch.elapsedMicroseconds / 1000} ms \u001b[0m');
      //         stopwatch.stop();
      //       } on Exception catch (_) {
      //         _showSnackBar(_.toString());
      //       } finally {
      //         setState(() {
      //           Navigator.pop(context); // 進度條dismiss
      //           Navigator.pop(context); //離開相機
      //         });
      //       }
      //     },
      //     child: const Icon(Icons.camera_alt),
      //   ),
    );
  }

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
        child: image == null ? null : Image.file(image!, fit: BoxFit.fill),
      ),
    );
  }

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
          // borderRadius: BorderRadius.circular(12),
          child: image == null ? null : Image.file(image!, fit: BoxFit.fill)),
    );
  }

  _showSnackBar(text) {
    final snackBar = SnackBar(
      content: text == null ? const Text('text is null') : Text(text),
      action: SnackBarAction(
        label: 'undo',
        onPressed: () {},
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
