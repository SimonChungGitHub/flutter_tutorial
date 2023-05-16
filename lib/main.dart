import 'package:flutter/material.dart';
import 'package:flutter_tutorial/device_info.dart';
import 'package:flutter_tutorial/login.dart';

import 'image_picker.dart';

void main() => runApp(
    const MyApp());

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
            child:Drawer(
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
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return const Home();
                      }));
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.app_registration,
                    ),
                    title: const Text('NFC Register'),
                    onTap: () {
                      Navigator.of(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return const ImagePickerPage();
                      }));
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.qr_code,
                    ),
                    title: const Text('QR Code Scanner'),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
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
          body: const Center(
            child: Text("this is home page"),
          ),
        ));
  }
}
