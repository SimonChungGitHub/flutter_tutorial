import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerPage extends StatefulWidget {
  const ImagePickerPage({super.key});

  @override
  State<StatefulWidget> createState() => _ImagePickerState();
}

class _ImagePickerState extends State<ImagePickerPage> {
  File? _image;
  final picker = ImagePicker();
  var dio = Dio();

  Future getImage() async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, maxWidth: 800);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        uploadImg(pickedFile.path); //上傳
      } else {
        debugPrint('没有选择任何图片');
      }
    });
  }

  void uploadImg(imageUrl) async {
    FormData formData = FormData.fromMap(
        {"dept": "temp", "file": await MultipartFile.fromFile(imageUrl)});
    var result = await dio.post(
        "http://192.168.0.238/okhttp/api/values/FileUpload",
        data: formData);

    bool b = bool.parse(result.toString());
    if (b) {
      _image?.delete();
      debugPrint("delete true");
    } else {
      debugPrint("delete fail");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home:Scaffold(
        appBar: AppBar(
          title: const Text("ImagePicker"),
        ),
        body: SingleChildScrollView(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // 点击按钮
            TextButton(
              onPressed: getImage,
              child: const Text("選擇圖片"),
            ),
            TextButton(
              onPressed: () {
                picker.pickImage(source: ImageSource.camera);
              },
              child: const Text("拍照片"),
            ),
            TextButton(
              onPressed: () {
                picker.pickVideo(source: ImageSource.camera);
              },
              child: const Text("錄影"),
            ),
            TextButton(
              onPressed: () {
                _image?.deleteSync();
                _image = null;
              },
              child: const Text("刪除照片"),
            ),
            // 展示图片
            Center(
              child: _image == null ? const Text('沒有圖片') : Image.file(_image!),
            ),
          ],
        ))));
  }
}
