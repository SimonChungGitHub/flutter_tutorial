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
import 'animation.dart';
import 'custom_camera_one_shot.dart';

class TakePhotoExample extends StatefulWidget {
  const TakePhotoExample({super.key, this.image});

  final File? image;

  @override
  State<TakePhotoExample> createState() => _TakePhotoExampleState();
}

class _TakePhotoExampleState extends State<TakePhotoExample> {
  File? image;
  bool zoomMode = false;
  String mode = 'easy_image_viewer';
  late ProgressDialog pd;
  DateTime? lastPopTime;

  @override
  void initState() {
    super.initState();
    //固定該頁面螢幕垂直不旋轉
    // SystemChrome.setPreferredOrientations(
    //     [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    image = widget.image;
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitUp,
    //   DeviceOrientation.portraitDown,
    //   DeviceOrientation.landscapeLeft,
    //   DeviceOrientation.landscapeRight
    // ]);
    if (zoomMode) {
      mode = 'easy_image_viewer';
    } else {
      mode = 'zoom_pinch_overlay';
    }
    debugPrint(
        '\u001b[31m ================initState==================== \u001b[0m');

    setState(() {});
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    pd = ProgressDialog(context: context);
    // SystemChrome.setPreferredOrientations(
    //     [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
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
                  setState(() => Navigator.of(context).pop());
                  setState(() {});
                }),

            ///自製相機
            ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('自製相機'),
                onPressed: () {
                  SystemChrome.setPreferredOrientations([
                    DeviceOrientation.portraitUp,
                    DeviceOrientation.portraitDown,
                    DeviceOrientation.landscapeRight,
                    DeviceOrientation.landscapeLeft
                  ]);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CustomCameraOneShot(),
                      )).then((value) {
                    setState(() {
                      image = value;
                      SystemChrome.setPreferredOrientations([
                        DeviceOrientation.portraitUp,
                        DeviceOrientation.portraitDown
                      ]);
                    });
                  });
                }),

            ///dioUpload
            ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('上傳'),
                onPressed: () async {
                  if (image == null) return;
                  final result = await _dioUpload();
                  if (result) {
                    // final file = await _reSizeImage(image!, 256);
                    // await _dioUploadFileDeleteFile(file);
                    await image!.delete();
                    image = null;
                    setState(() {
                      showDialog(
                          context: context,
                          builder: (_) => const ShowAnimDialog(success: true));
                    });
                  } else {
                    setState(() {
                      showDialog(
                          context: context,
                          builder: (_) => const ShowAnimDialog(success: false));
                    });
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
                  fit: BoxFit.contain,
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

      BaseOptions options = BaseOptions(
        receiveDataWhenStatusError: true,
        connectTimeout: const Duration(seconds: 3),
        receiveTimeout: const Duration(seconds: 5),
      );

      var dio = Dio(options);
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
      showSnackBar(context, _.toString());
    } finally {
      pd.close();
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
