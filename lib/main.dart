import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tutorial/device_info.dart';
import 'package:flutter_tutorial/image_zoomer.dart';
import 'package:flutter_tutorial/login/login.dart';
import 'package:flutter_tutorial/utils.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

import 'CustomDropdownButton2.dart';
import 'config.dart';
import 'global_data.dart';
import 'image_picker.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  static const String _title = 'Flutter Tutorial';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: _title,
      home: Home(),
      debugShowCheckedModeBanner: false,
    );
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

  final Image _image = Image.asset("assets/test.jpg");
  String tempPath = '/storage/sdcard0/DCIM/Camera/20230301_221800.jpg';

  @override
  void initState() {
    super.initState();
    if (!isLogin) runApp(const Login());
    _enableNFC();
    checkPermission();
  }

  void checkPermission() async {
    var camera = await Permission.camera.status;
    if (camera.isDenied) {
      await Permission.camera.request();
    }

    var photos = await Permission.photos.status;
    var videos = await Permission.videos.status;
    if (photos.isDenied || videos.isDenied) {
      await [
        Permission.photos,
        Permission.videos,
      ].request();
    }

    var audio = await Permission.audio.status;
    if (audio.isDenied) {
      await Permission.audio.request();
    }
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
      var dio = Dio();
      ProgressDialog pd = ProgressDialog(context: context);
      pd.show(max: 100, msg: 'File Uploading...');
      FormData formData = FormData.fromMap(
          {"dept": "temp", "file": await MultipartFile.fromFile(tempPath)});
      final response = await dio.post(
        fileUploadURL,
        data: formData,
        onSendProgress: (int sent, int total) {
          int progress = (((sent / total) * 100).toInt());
          pd.update(value: progress);
        },
      );
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
          backgroundColor: const Color(0xff764abc),
        ),
        drawer: SizedBox(
          width: MediaQuery.of(context).size.width * 0.6,
          child: Drawer(
            child: ListView(
              // Important: Remove any padding from the ListView.
              padding: EdgeInsets.zero,
              children: [
                const UserAccountsDrawerHeader(
                  decoration: BoxDecoration(color: Color(0xff764abc)),
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
                  title: const Text('Home'),
                  onTap: () {
                    Navigator.pop(context);
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
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
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
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
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
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
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
        ),
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
            Container(
                padding: const EdgeInsets.all(10),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2(
                    isExpanded: true,
                    hint: const Row(
                      children: [
                        Icon(
                          Icons.list,
                          size: 16,
                          color: Colors.black12,
                        ),
                        Expanded(
                          child: Text(
                            'Select Item',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    items: items
                        .map((item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(
                                item,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ))
                        .toList(),
                    value: selectedValue,
                    onChanged: (value) {
                      setState(() {
                        selectedValue = value as String;
                        selectItemController.text = value;
                      });
                    },
                    buttonStyleData: ButtonStyleData(
                      height: 50,
                      width: 160,
                      padding: const EdgeInsets.only(left: 14, right: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: Colors.black26,
                        ),
                        color: Colors.white,
                      ),
                      elevation: 2,
                    ),
                    iconStyleData: const IconStyleData(
                      icon: Icon(
                        Icons.arrow_forward_ios_outlined,
                      ),
                      iconSize: 14,
                      iconEnabledColor: Colors.white,
                      iconDisabledColor: Colors.grey,
                    ),
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: 200,
                      width: 200,
                      padding: null,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white,
                      ),
                      elevation: 8,
                      offset: const Offset(0, 0),
                      scrollbarTheme: ScrollbarThemeData(
                        radius: const Radius.circular(40),
                        thickness: MaterialStateProperty.all<double>(6),
                        thumbVisibility: MaterialStateProperty.all<bool>(true),
                      ),
                    ),
                    menuItemStyleData: const MenuItemStyleData(
                      height: 40,
                      padding: EdgeInsets.only(left: 10, right: 10),
                    ),
                  ),
                )),
            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: selectItemController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'selected item',
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'tag value',
                ),
              ),
            ),
            Container(
                height: 50,
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: ElevatedButton(
                  child: const Text('dio upload'),
                  onPressed: () {
                    dioUpload();
                  },
                )),
            Container(
              padding: const EdgeInsets.all(10),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10), // Image border
                  child: GestureDetector(
                    onTap: () {
                      showImageViewer(context, _image.image,
                          swipeDismissible: true, doubleTapZoomable: true);
                    }, // Image tapped
                    child: Image(
                        image: _image.image,
                        fit: BoxFit.fill,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: SizedBox.fromSize(
                              size: MediaQuery.of(context).size,
                              child: const CircularProgressIndicator(
                                backgroundColor: Colors.grey,
                                valueColor: AlwaysStoppedAnimation(Colors.blue),
                              ),
                            ),
                          );
                        },
                        frameBuilder:
                            (context, child, frame, wasSynchronouslyLoaded) {
                          if (wasSynchronouslyLoaded) return child;
                          return AnimatedOpacity(
                            opacity: frame == null ? 0 : 1,
                            duration: const Duration(seconds: 1),
                            curve: Curves.easeIn,
                            child: child,
                          );
                        }),
                  )),
            ),
          ],
        ));
  }
}
