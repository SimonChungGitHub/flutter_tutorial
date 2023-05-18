import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tutorial/device_info.dart';
import 'package:flutter_tutorial/login.dart';
import 'package:flutter_tutorial/utils.dart';
import 'package:nfc_manager/nfc_manager.dart';

import 'config.dart';
import 'image_picker.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  static const String _title = 'Login';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Scaffold(
        appBar: AppBar(title: const Text(_title)),
        body: const LoginPage(),
      ),
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
  String testImagePath =
      '/data/user/0/com.example.flutter_tutorial/cache/scaled_20230501_235448.jpg';
  double progressValue = 0;

  @override
  void initState() {
    super.initState();
    nfc();
    progressValue = 0;
  }

  void nfc() async {
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
      FormData formData = FormData.fromMap({
        "dept": "temp",
        "file": await MultipartFile.fromFile(testImagePath)
      });
      final response = await dio.post(
        'http://192.168.0.238/okhttp/api/values/FileUpload',
        data: formData,
        onSendProgress: (int sent, int total) {
          setState(() {
            progressValue = sent / total;
            //todo progressbar start
            debugPrint('--------$sent / $total');
          });
        },
      );
      debugPrint('--------${response.data.toString()}');
    } catch (_) {
      debugPrint(_.toString());
    } finally {
      //todo progressbar close
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0x9f4376f8),
        ),
        home: Scaffold(
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
                      setState(() {});
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.app_registration,
                    ),
                    title: const Text('NFC Register'),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return const ImagePickerPage();
                      })).then((value) => setState(() {}));
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.qr_code,
                    ),
                    title: const Text('QR Code Scanner'),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return const ImagePickerPage();
                      }));
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.browse_gallery,
                    ),
                    title: const Text('Custom Gallery'),
                    onTap: () {
                      Navigator.pop(context);
                      runApp(const DeviceInfo());
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.perm_device_info,
                    ),
                    title: const Text('Device Info'),
                    onTap: () {
                      Navigator.pop(context);
                      runApp(const DeviceInfo());
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
                ],
              ),
            ),
          ),
          body: Padding(
              padding: const EdgeInsets.all(10),
              child: ListView(
                children: <Widget>[
                  Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(10),
                      child: const Text(
                        'Flutter Tutorial',
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                            fontSize: 30),
                      )),
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
                              thumbVisibility:
                                  MaterialStateProperty.all<bool>(true),
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
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: SizedBox(
                    height: 3,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation(Colors.blue),
                      value: progressValue,
                    ),
                  )),

                  TextButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return const ImagePickerPage();
                      })).then((value) => setState(() {
                            usernameController.text = "";
                          }));
                    },
                    child: const Text(
                      'Forgot Password',
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text('Does not have account?'),
                      TextButton(
                        child: const Text(
                          'Sign in',
                          style: TextStyle(fontSize: 20),
                        ),
                        onPressed: () {
                          //signup screen
                          runApp(const DeviceInfo());
                        },
                      )
                    ],
                  ),
                ],
              )),
        ));
  }
}
