import 'dart:io';
import 'dart:typed_data';

import 'package:camera_camera/camera_camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tutorial/device_info.dart';
import 'package:flutter_tutorial/image_zoomer.dart';
import 'package:flutter_tutorial/login/login.dart';
import 'package:flutter_tutorial/utils.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:image_watermark/image_watermark.dart';
import 'package:intl/intl.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:yaml/yaml.dart';

import 'CustomDropdownButton2.dart';
import 'config.dart';
import 'example/animation.dart';
import 'example/dialog.dart';
import 'global_data.dart';
import 'image_picker.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  static const String _title = 'Flutter Tutorial';

  @override
  Widget build(BuildContext context) {
    loadAsset(context);
    return const MaterialApp(
      title: _title,
      home: Home(),
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

  // final Image _image = Image.asset("assets/test.jpg");
  String tempPath = '/storage/sdcard0/DCIM/Camera/20230301_221800.jpg';
  XFile? xFile;
  File? image;
  File? thumbnail;
  final picker = ImagePicker();

  var picScale = 1.0;
  var dx = 1.0;
  var dy = 1.0;
  var _lastOffset = Offset(0, 0);
  var screenWidth = 500;
  var screenHeight = 1000;
  var width = 500.0;

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

  void dioUpload() async {
    try {
      if (image == null) return;
      var dio = Dio();
      ProgressDialog pd = ProgressDialog(context: context);
      pd.show(max: 100, msg: 'File Uploading...');
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
      debugPrint('--------${response.data.toString()}');
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      Navigator.of(context);
    }
  }

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
          centerTitle: true,
          title: const Text(
            'Home',
          ),
          backgroundColor: Colors.blue,
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
            //dioUpload
            Container(
                height: 50,
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: ElevatedButton(
                  child: const Text('dio upload'),
                  onPressed: () => dioUpload(),
                )),
            Container(
              height: 50,
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child:
                  ElevatedButton(child: const Text('dialog'), onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                          return const DialogExample();
                        }));

                  }),
            ),
            Container(
              height: 50,
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child:
              ElevatedButton(child: const Text('動畫'), onPressed: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) {
                      return const AnimationDialog();
                    }));

              }),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => CameraCamera(
                                    onFile: (file) {
                                      debugPrint(
                                          '\u001b[31m take photo finish!! \u001b[0m');
                                      Navigator.pop(context);
                                      image = file;
                                      // watermark(image).then((value) {
                                      //   setState(() {
                                      //     ScaffoldMessenger.of(context)
                                      //         .showSnackBar(SnackBar(
                                      //             content: Text(file.path)));
                                      //   });
                                      // });
                                    },
                                  )));
                    },
                    child: const Text('camera_camera')),
                TextButton(
                    onPressed: () {
                      picker
                          .pickImage(source: ImageSource.camera)
                          .then((value) {
                        debugPrint('\u001b[31m 拍照完成 ${value!.path} \u001b[0m');
                        File file = File(value.path);

                        String filename =
                            '${DateFormat('yyyyMMdd_HHmmss_SSS').format(DateTime.now())}.jpg';
                        String newPath = '${file.parent.path}/$filename';
                        file.rename(newPath).then((value) {
                          debugPrint('\u001b[31m rename 完成 $newPath \u001b[0m');
                          image = value;
                          setState(() {
                            String path =
                                '${file.parent.path}/${filename.replaceAll('.jpg', '_thumbnail.jpg')}';
                            thumbnail = File(path);
                            img.Image? i =
                                img.decodeImage(image!.readAsBytesSync());
                            img.Image? thumbnail00 =
                                img.copyResize(i!, width: 256);
                            File(thumbnail!.path)
                                .writeAsBytesSync(img.encodePng(thumbnail00));
                          });
                        });
                      });
                    },
                    child: const Text('img_pick')),
                TextButton(
                    onPressed: () {
                      if (image == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("沒有照片可上傳")));
                      } else {
                        dioUpload();
                        dioUploadThumbnail();
                      }
                    },
                    child: const Text('dio_upload')),
              ],
            ),
            Container(
              child: image == null ? null : showImage(image),
            )
          ],
        ));
  }

  Future<void> watermark(file) async {
    Uint8List imgBytes = file.readAsBytesSync();

    final topLeft = await ImageWatermark.addTextWatermark(
      imgBytes: imgBytes,
      watermarkText: 'watermarkText\naaaaaaaa\nbbbbbbbbbbb',
      dstX: 50,
      dstY: 150,
      color: Colors.green,
    );

    final topRight = await ImageWatermark.addTextWatermark(
      imgBytes: topLeft,
      watermarkText: 'watermarkText\naaaaaaaa\nbbbbbbbbbbb',
      dstX: 500,
      dstY: 150,
      color: Colors.green,
    );

    final bottomLeft = await ImageWatermark.addTextWatermark(
      imgBytes: topRight,
      watermarkText: 'watermarkText\naaaaaaaa\nbbbbbbbbbbb',
      dstX: 50,
      dstY: 1150,
      color: Colors.green,
    );

    final bottomRight = await ImageWatermark.addTextWatermark(
      imgBytes: bottomLeft,
      watermarkText: 'watermarkText\naaaaaaaa\nbbbbbbbbbbb',
      dstX: 500,
      dstY: 1150,
      color: Colors.green,
    );

    File(file.path).writeAsBytesSync(bottomRight);
  }

  Widget showImage00(file) {
    if (file == null) {
      return Container();
    } else {
      return Container(
        padding: const EdgeInsets.all(10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10), // Image border
          child: InteractiveViewer(
            panEnabled: true,
            minScale: 1.0,
            boundaryMargin: const EdgeInsets.all(40.0),
            child: Image.file(file),
          ),
        ),
      );
    }
  }

  Widget showImage02(file) {
    return GestureDetector(
      child: Transform.translate(
          offset: Offset(dx, dy),
          child: Transform.scale(
              scale: picScale,
              child: Image(
                image: Image.file(file, width: width).image,
              ))),
      onScaleUpdate: (ScaleUpdateDetails e) {
        setState(() {
          //缩放倍数在0.8到10倍之间
          width = 200 * e.scale.clamp(0.8, 1.02);
          debugPrint('\u001b[31m  ===================== \u001b[0m');
        });
      },
    );
  }

  Widget showImage(file) {
    return GestureDetector(
        child: Transform.translate(
            offset: Offset(dx, dy),
            child: Transform.scale(
                scale: picScale,
                child: Image(
                  image: Image.file(file).image,
                ))),
        // 在这里监听手势处理
        onScaleStart: (d) {
          // 缩放事件开始前现在这个事件中获取初始坐标
          _lastOffset = d.focalPoint;
          debugPrint('\u001b[31m  ==========Start=========== \u001b[0m');
        },

        // 监听缩放事件和拖拽
        onScaleUpdate: (ScaleUpdateDetails details) {
          debugPrint('\u001b[31m  ==========Update=========== \u001b[0m');
          // 这里的0.98和1.02控制details.scale的最大最小值，从而控制缩放速度
          double tempScale = picScale * details.scale.clamp(0.98, 1.52);
          double tempDx = dx + details.focalPoint.dx - _lastOffset.dx;
          double tempDy = dy + details.focalPoint.dy - _lastOffset.dy;
          // 这里是缩放和拖拽的处理，属于算法层面的东西，我算法不行，写得很乱
          // 大概情况就是控制缩放区间为[0.7,3.5]，拖拽和缩放时控制图片的位置，不能消失在屏幕，然后还有双指水平滑动会触发缩放的bug解决
          if (tempScale <= 3.5 && tempScale >= 1) {
            if (tempDx.abs() < screenWidth * (tempScale - 1) / 2) {
              dx = tempDx;
            } else {
              dx = dx > 0
                  ? screenWidth * (tempScale - 1) / 2 - 1
                  : -(screenWidth * (tempScale - 1) / 2 - 1);
            }
            if (tempDy.abs() < screenHeight * (tempScale - 1) / 2) {
              dy = tempDy;
            } else {
              dy = dy > 0
                  ? screenHeight * (tempScale - 1) / 2 - 1
                  : -(screenHeight * (tempScale - 1) / 2 - 1);
            }
            // details.verticalScale是多指操作时相对垂直平分线移动的距离比例，可用于检测多指平行滑动
            if ((1 - details.verticalScale).abs() > 0.28) {
              picScale = tempScale;
            }
          }
          // 可以缩小到比原图小，但是不能移动
          if (tempScale < 1 &&
              tempScale >= 0.7 &&
              (1 - details.verticalScale).abs() > 0.28) {
            picScale = tempScale;
          }
          _lastOffset = details.focalPoint;
          setState(() {}); // **注意dx，dy和scale都是声明在state里的，一定要setState才会生效**
        },
        // 监听移动事件， 由于onScaleUpdate已经包含了移动，在有onScaleUpdate的情况下不能监听下面两个事件
        // onHorizontalDragUpdate: dragEvent,
        // onVerticalDragUpdate: dragEvent,
        // 双击事件，处理为还原
        onDoubleTap: () {
          setState(() {
            picScale = 1.0;
            dx = 0.0;
            dy = 0.0;
          });
        });
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
              title: const Text('camera'),
              onTap: () {
//todo
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (_) => CameraCamera(
                //               onFile: (file) {
                //                 Navigator.pop(context);
                //                 setState(() {
                //                   ScaffoldMessenger.of(context)
                //                       .showSnackBar(SnackBar(
                //                           content: Text(file.path)));
                //                 });
                //               },
                //             )));
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.app_registration,
              ),
              title: const Text('NFC Register'),
              onTap: () {
                Navigator.pop(context);
                // Navigator.push(context,
                //     MaterialPageRoute(builder: (context) {
                //       return const ImagePickerPage();
                //     })).then((value) => setState(() {}));
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.qr_code,
              ),
              title: const Text('QR Code Scanner'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const ImagePickerPage();
                }));
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.zoom_out_map,
              ),
              title: const Text('Image Zoom'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const ImageZoom();
                }));
              },
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
