import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

import 'config.dart';

String identifierToHex(var identifier) {
  var hex = [
    "0",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "A",
    "B",
    "C",
    "D",
    "E",
    "F"
  ];
  String id = "";
  late int i;
  for (var data in identifier) {
    data = data & 0xff;
    i = (data >> 4) & 0x0f;
    id += hex[i];
    i = data & 0x0f;
    id += hex[i];
  }
  return id;
}

Future<String?> getAndroidID() async {
  const androidIdPlugin = AndroidId();
  return await androidIdPlugin.getId();
}

Future<bool> checkPermission() async {
  var camera = await Permission.camera.status;
  if (camera.isDenied) {
    await Permission.camera.request();
  }

  DeviceInfoPlugin build = DeviceInfoPlugin();
  var androidInfo = await build.androidInfo;

  if (androidInfo.version.sdkInt < 29) {
    var phone = await Permission.phone.status;
    if (phone.isDenied) {
      await Permission.phone.request();
      return false;
    }

    if (androidInfo.version.sdkInt <= 32) {
      var photos = await Permission.photos.status;
      var videos = await Permission.videos.status;
      if (photos.isDenied || videos.isDenied) {
        await [
          Permission.photos,
          Permission.videos,
        ].request();
        return false;
      }

      var audio = await Permission.audio.status;
      if (audio.isDenied) {
        await Permission.audio.request();
        return false;
      }
    }
  }
  return true;
}

void showSnackBar(context, text) {
  final snackBar = SnackBar(
    content: text == null ? const Text('text is null') : Text(text),
    action: SnackBarAction(
      label: 'undo',
      onPressed: () {},
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

/// use path_provider package
Future<void> createDir() async {
  Directory directory = await getTemporaryDirectory();
  String path = '${directory.path}${Platform.pathSeparator}';
  var dir = Directory(path);
  if (dir.existsSync()) {
    debugPrint('\u001b[31m 資料夾已存在 $path \u001b[0m');
  } else {
    await dir.create();
    debugPrint('\u001b[31m 建立資料夾 $path \u001b[0m');
  }
}

///取得指定目錄下所有檔案
Future<List<File>> dirList() async {
  Directory directory = await getTemporaryDirectory();
  String path = '${directory.path}${Platform.pathSeparator}';
  Stream<FileSystemEntity> list = Directory(path).list();
  List<File> files = [];
  await for (FileSystemEntity entity in list) {
    debugPrint('\u001b[31m ${entity.toString()} \u001b[0m');
    if (entity.path.endsWith('jpg')) files.add(File(entity.path));
  }
  return files;
}

///取得指定目錄下所有檔案檔案路徑
Future<List<String>> dirList2() async {
  Directory directory = await getTemporaryDirectory();
  String path = '${directory.path}${Platform.pathSeparator}';
  Stream<FileSystemEntity> list = Directory(path).list();
  List<String> files = [];
  await for (FileSystemEntity entity in list) {
    debugPrint('\u001b[31m ${entity.toString()} \u001b[0m');
    if (entity.path.endsWith('jpg')) files.add(entity.path);
  }
  return files;
}

Future<void> deleteDir() async {
  Directory directory = await getTemporaryDirectory();
  String path = '${directory.path}${Platform.pathSeparator}cache';
  var dir = Directory(path);
  if (dir.existsSync()) {
    dir.delete();
  }
}

///上傳
Future<bool> dioUpload(context, image) async {
  final pd = ProgressDialog(context: context);
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
  } finally {
    pd.close();
  }
  return false;
}
