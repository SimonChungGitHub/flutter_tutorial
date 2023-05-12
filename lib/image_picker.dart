import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerPage extends StatefulWidget {
  const ImagePickerPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ImagePickerState();
  }
}

class _ImagePickerState extends State<ImagePickerPage> {
  // 图片文件
  File? _image;

  // 实例化
  final picker = ImagePicker();

  // 获取图片
  Future getImage() async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, maxWidth: 800);
    // 更新状态
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        uploadImg(pickedFile.path); //上傳
      } else {
        debugPrint('没有选择任何图片');
      }
    });
  }

  var dio = Dio();
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
    return Scaffold(
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
                _image =null;
              },
              child: const Text("刪除照片"),
            ),
            // 展示图片
            Center(
              child: _image == null ? const Text('沒有圖片') : Image.file(_image!),
            ),
          ],
        )));
  }
}
