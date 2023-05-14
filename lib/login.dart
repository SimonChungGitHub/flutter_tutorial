import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nfc_manager/nfc_manager.dart';

import 'devide_info.dart';
import 'image_picker.dart';
import 'nfc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  ValueNotifier<dynamic> result = ValueNotifier("");


  @override
  void initState() {
    nfc();
  }


  @override
  void dispose() {
    super.dispose();
    // await FlutterNfcKit.finish();
    NfcManager.instance.stopSession();
  }

  void nfc() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (isAvailable) {
      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          debugPrint(tag.data["nfca"]["identifier"].toString());
        },
      );
    }
  }

  // void nfc() async {
  //   try {
  //     var availability = await FlutterNfcKit.nfcAvailability;
  //     if (availability == NFCAvailability.available) {
  //       // timeout only works on Android, while the latter two messages are only for iOS
  //       var tag = await FlutterNfcKit.poll(
  //           timeout: const Duration(seconds: 10),
  //           iosMultipleTagMessage: "Multiple tags found!",
  //           iosAlertMessage: "Scan your tag");
  //       result.value = tag.id;
  //       debugPrint(tag.id);
  //       var response = loginResponse();
  //       response.then((value) => showMsg(value));
  //     }
  //   } catch (e) {
  //     debugPrint(e.toString());
  //     await FlutterNfcKit.finish();
  //     nfc();
  //   } finally {}
  // }

  Future<bool> loginResponse() async {
    try {
      var map = {
        "username": usernameController.text,
        "password": passwordController.text,
        "tag": result.value,
      };
      var url = Uri.parse('http://192.168.0.238/okhttp/api/values/Login');
      var response = await http.post(url, body: jsonEncode(map));
      if (response.statusCode == 200) return json.decode(response.body)['result'];
    } catch (e) {
      debugPrint(e.toString());
    }
    return false;
  }

  Future<void> showMsg(var isLoginSuccess) async {
    try {
      if (isLoginSuccess) {
        runApp(const ImagePickerPage());
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("登入失敗")));
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                child: const Text(
                  'Sign in',
                  style: TextStyle(fontSize: 20),
                )),
            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'User Name',
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: TextField(
                obscureText: true,
                controller: passwordController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                //forgot password screen
              },
              child: const Text(
                'Forgot Password',
              ),
            ),
            Container(
                height: 50,
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: ElevatedButton(
                  child: const Text('Login'),
                  onPressed: () {
                    if (usernameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("User Name is empty")));
                      return;
                    }
                    if (passwordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Password is empty")));
                      return;
                    }
                    var response = loginResponse();
                    response.then((value) => showMsg(value));
                  },
                )),
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
        ));
  }
}
