import 'dart:io';

import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tutorial/device_info.dart';
import 'package:flutter_tutorial/example/custom_camera.dart';
import 'package:flutter_tutorial/example/take_photo.dart';
import 'package:flutter_tutorial/login.dart';
import 'package:flutter_tutorial/utils.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:stamp_image/stamp_image.dart';
import 'package:yaml/yaml.dart';

import 'CustomDropdownButton2.dart';
import 'config.dart';
import 'example/animation.dart';
import 'example/date_time_picker.dart';
import 'example/dialog.dart';
import 'gallery_view/gallery_view.dart';
import 'global_data.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  static const String _title = 'Flutter Tutorial';

  @override
  Widget build(BuildContext context) {
    loadAsset(context);
    return MaterialApp(
      title: _title,
      theme: ThemeData.dark(),
      home: const Home(),
      debugShowCheckedModeBanner: false,
    );
  }

  Future<void> loadAsset(BuildContext context) async {
    final yamlString =
        await DefaultAssetBundle.of(context).loadString('assets/config.yaml');
    final dynamic yamlMap = loadYaml(yamlString);
    debugPrint(yamlMap['loginURL']);
    debugPrint(yamlMap['fileUploadURL']);
    var list = yamlMap['items'].toString().split(',');
    debugPrint(list.toString());
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController selectItemController = TextEditingController();
  String? selectedValue;

  // String tempPath = '/storage/sdcard0/DCIM/Camera/20230301_221800.jpg';
  // XFile? xFile;

  final picker = ImagePicker();
  File? image;
  File? thumbnail;

  @override
  void initState() {
    super.initState();
    // if (!isLogin) runApp(const Login());
    _enableNFC();
    checkPermission();
  }

  void _enableNFC() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (isAvailable) {
      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          debugPrint(tag.data.toString());
          var identifier = tag.data["nfca"]["identifier"];
          usernameController.text = identifierToHex(identifier);
        },
      );
    }
  }

  // void dioUpload() async {
  //   try {
  //     if (image == null) return;
  //     var dio = Dio();
  //     ProgressDialog pd = ProgressDialog(context: context);
  //     pd.show(max: 100, msg: 'File Uploading...');
  //     FormData formData = FormData.fromMap(
  //         {"dept": "temp", "file": await MultipartFile.fromFile(image!.path)});
  //     final response = await dio.post(
  //       fileUploadURL,
  //       data: formData,
  //       onSendProgress: (int sent, int total) {
  //         int progress = (((sent / total) * 100).toInt());
  //         pd.update(value: progress);
  //       },
  //     );
  //     bool result = bool.parse(response.data.toString());
  //     if (result && image != null) {
  //       File(image!.path).deleteSync();
  //       image = null;
  //       setState(() {});
  //     }
  //     debugPrint('--------${response.data.toString()}');
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   } finally {
  //     Navigator.of(context);
  //   }
  // }

  void dioUploadThumbnail() async {
    try {
      if (thumbnail == null) return;
      var dio = Dio();
      ProgressDialog pd = ProgressDialog(context: context);
      pd.show(max: 100, msg: 'File Uploading...');
      FormData formData = FormData.fromMap({
        "dept": "temp",
        "file": await MultipartFile.fromFile(thumbnail!.path)
      });
      final response = await dio.post(
        fileUploadURL,
        data: formData,
        onSendProgress: (int sent, int total) {
          int progress = (((sent / total) * 100).toInt());
          pd.update(value: progress);
        },
      );
      bool result = bool.parse(response.data.toString());
      if (result && thumbnail != null) {
        File(thumbnail!.path).deleteSync();
        thumbnail = null;
        setState(() {});
      }
      debugPrint('--------${response.data.toString()}');
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      Navigator.of(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    _enableNFC();
    return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: const Text(
            'Home',
          ),
          backgroundColor: Colors.blue,
          actions: [
            IconButton(
              tooltip: '相機',
              icon: const Icon(
                Icons.camera_alt,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MaterialApp(
                      theme: ThemeData.dark(),
                      home: const CustomCamera(),
                    ),
                  ),
                );
              },
            ),
            IconButton(
                tooltip: '相簿',
                icon: const Icon(
                  Icons.photo,
                ),
                onPressed: () async {
                  setState(() {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const GalleryView()));
                  });
                }),
            PopupMenuButton<Text>(itemBuilder: (context) {
              return [
                const PopupMenuItem(
                  child: Text(
                    'camera',
                  ),
                ),
                const PopupMenuItem(
                  child: Text(
                    'setting',
                  ),
                ),
                const PopupMenuItem(
                  child: Text(
                    'aaaa',
                  ),
                ),
              ];
            }),
          ],
        ),
        drawer: drawerWidget(),
        body: ListView(
          children: <Widget>[
            Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(10),
                child: CustomDropdownButton2(
                    hint: 'Select Item',
                    dropdownItems: items,
                    value: selectedValue,
                    buttonWidth: 180,
                    buttonHeight: 50,
                    dropdownWidth: 200,
                    onChanged: (value) {
                      setState(() => selectedValue = value);
                    })),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ///一次拍照
                ElevatedButton(
                  child: const Text('一次拍照'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const TakePhotoExample()));
                  },
                ),

                ///dialog
                Container(
                  height: 50,
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: ElevatedButton(
                      child: const Text('dialog'),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const DialogExample()));
                      }),
                ),

                ///動畫 button
                Container(
                  height: 50,
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: ElevatedButton(
                      child: const Text('動畫'),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AnimationDialog()));
                      }),
                ),
              ],
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              ///DateTimePicker
              Container(
                height: 50,
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: ElevatedButton(
                  child: const Text('DateTimePicker'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const DateTimePickerExample()));
                  },
                ),
              ),
              ElevatedButton(
                  child: const Text('create dir'),
                  onPressed: () async {
                    await createDir();
                  }),

              ElevatedButton(
                  child: const Text('dir list'),
                  onPressed: () async {
                    await dirList();
                  }),
            ]),
          ],
        ));
  }

  Widget _watermarkItem() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateTime.now().toString(),
            style: const TextStyle(color: Colors.black, fontSize: 15),
          ),
          const SizedBox(height: 5),
          const Text(
            "Made By Stamp Image",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Future<File> _buildImage(file) async {
    String filename = DateFormat('yyyyMMdd_HHmmss_SSS').format(DateTime.now());
    String newPath = '${file.parent.path}/$filename.jpg';
    img.Image? srcImg = img.decodeImage(file!.readAsBytesSync());
    img.Image? destImg = img.copyResize(srcImg!, width: 256);
    File(newPath).writeAsBytesSync(img.encodePng(destImg));
    File newFile = File(newPath);
    return newFile;
  }

  Future<void> _dioUpload() async {
    try {
      // if (image == null) return;
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

  Widget drawerWidget() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.6,
      child: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              accountName: Text(
                "Simon Chung",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: Text(
                "chungjenching@gmail.com",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              currentAccountPicture: FlutterLogo(),
            ),
            ListTile(
              leading: const Icon(
                Icons.home,
              ),
              title: const Text('todo'),
              onTap: () {
//todo
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.app_registration,
              ),
              title: const Text('todo'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(
                Icons.perm_device_info,
              ),
              title: const Text('Device Info'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const DeviceInfo();
                }));
              },
            ),
            const AboutListTile(
              icon: Icon(
                Icons.info,
              ),
              applicationIcon: Icon(
                Icons.local_play,
              ),
              applicationName: 'Flutter App',
              applicationVersion: '1.0.0',
              applicationLegalese: '© 2023 Company',
              aboutBoxChildren: [
                Text('write something about this app'),
              ],
              child: Text('About app'),
            ),
            ListTile(
              leading: const Icon(
                Icons.logout,
              ),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                isLogin = false;
                runApp(const Login());
              },
            ),
          ],
        ),
      ),
    );
  }
}
