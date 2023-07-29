import 'dart:io';

import 'package:camera_camera/camera_camera.dart';
import 'package:dio/dio.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:zoom_pinch_overlay/zoom_pinch_overlay.dart';

import '../config.dart';

class TakePhotoExample extends StatefulWidget {
  const TakePhotoExample({super.key});

  @override
  State<TakePhotoExample> createState() => _TakePhotoExampleState();
}

class _TakePhotoExampleState extends State<TakePhotoExample> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late CameraDescription firstCamera;
  File? image;
  bool zoomMode = false;
  String mode = 'easy_image_viewer';

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    availableCameras().then((cameras) {
      firstCamera = cameras.first;
      _controller = CameraController(
        firstCamera,
        ResolutionPreset.high,
      );
      _initializeControllerFuture = _controller.initialize();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            children: [
              ///camera_camera
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(10),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[900]),
                    child: const Text('camera_camera'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CameraCamera(
                            onFile: (file) {
                              Navigator.pop(context);
                              setState(() => image = file);
                              _showSnackBar(file.parent);
                            },
                          ),
                        ),
                      );
                    }),
              ),

              ///image_picker
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(10),
                child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('image_picker'),
                    onPressed: () {
                      final picker = ImagePicker();
                      picker
                          .pickImage(source: ImageSource.camera)
                          .then((value) async {
                        _showLoadingDialog();
                        await Future.delayed(const Duration(seconds: 2));
                        setState(() => image = File(value!.path));
                        await Future.delayed(const Duration(seconds: 1));
                        setState(() => Navigator.pop(context));
                      });
                    }),
              ),
            ],
          ),
          Row(
            children: [
              ///自製相機
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(10),
                child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('自製相機'),
                    onPressed: () {
                      WidgetsFlutterBinding.ensureInitialized();
                      availableCameras().then((cameras) {
                        firstCamera = cameras.first;
                        _controller = CameraController(
                          firstCamera,
                          ResolutionPreset.high,
                        );
                        _initializeControllerFuture = _controller.initialize();
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
              ),

              ///dioUpload
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(10),
                child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('上傳'),
                    onPressed: () => _dioUpload()),
              ),
              Text(mode),
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
            ],
          ),
          Expanded(
            child: Container(
                alignment: Alignment.topCenter,
                margin: const EdgeInsets.all(10),
                child: zoomMode ? easyImageViewer() : zoomPinchOverlay()),
          ),
        ],
      ),
    );
  }

  ///自製相機
  Widget takePhotoScreen() {
    return Scaffold(
      body: FutureBuilder<void>(
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            _showLoadingDialog();
            await _initializeControllerFuture;
            final xFile = await _controller.takePicture();
            if (!mounted) return;
            setState(() {
              image = File(xFile.path);
              Navigator.pop(context); // 進度條dismiss
              Navigator.pop(context); //離開相機
            });
          } catch (e) {
            _showSnackBar(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
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
        borderRadius: BorderRadius.circular(12),
        child: image == null ? null : Image.file(image!),
      ),
    );
  }

  Widget zoomPinchOverlay() {
    return ZoomOverlay(
      modalBarrierColor: Colors.black12,
      minScale: 0.8,
      maxScale: 1.8,
      animationCurve: Curves.fastOutSlowIn,
      animationDuration: const Duration(milliseconds: 300),
      twoTouchOnly: true,
      onScaleStart: () {},
      onScaleStop: () {},
      child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: image == null ? null : Image.file(image!)),
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
  Future<void> _dioUpload() async {
    try {
      if (image == null) return;
      var dio = Dio();
      ProgressDialog pd = ProgressDialog(context: context);
      pd.show(max: 100, msg: '檔案上傳中 請稍後');
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
      bool result = bool.parse(response.data.toString());
      if (result && image != null) {
        File(image!.path).deleteSync();
        image = null;
        setState(() {});
      }
      debugPrint('\u001b[31m ${response.data.toString()} \u001b[0m');
    } catch (e) {
      debugPrint('\u001b[31m $e \u001b[0m');
    }
  }
}
