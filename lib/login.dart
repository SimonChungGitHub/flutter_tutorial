import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_tutorial/main.dart';
import 'package:http/http.dart' as http;
import 'package:nfc_manager/nfc_manager.dart';
import 'CustomDropdownButton2.dart';
import 'device_info.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  ValueNotifier<dynamic> result = ValueNotifier("");
  String? selectedValue;
  final List<String> items = [
    'Item1234567890',
    'Item2',
    'Item3',
    'Item4',
    'Item5',
    'Item6',
    'Item7',
    'Item8',
  ];

  @override
  void initState() {
    super.initState();
    usernameController.text = "simon";
    passwordController.text = "1212";
    nfc();
  }

  @override
  void dispose() {
    super.dispose();
    NfcManager.instance.stopSession();
  }

  void nfc() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (isAvailable) {
      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          debugPrint(tag.data.toString());
          var identifier = tag.data["nfca"]["identifier"];
          result.value = identifierToHex(identifier);
          var response = loginResponse();
          response.then((value) => showMsg(value));
        },
      );
    }
  }

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
    debugPrint(id);
    return id;
  }

  Future<bool> loginResponse() async {
    try {
      var map = {
        "username": usernameController.text,
        "password": passwordController.text,
        "tag": result.value,
      };
      var url = Uri.parse('http://192.168.0.238/okhttp/api/values/Login');
      var response = await http
          .post(url, body: jsonEncode(map))
          .timeout(const Duration(seconds: 2));
      if (response.statusCode == 200) {
        return json.decode(response.body)['result'];
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return false;
  }

  Future<void> showMsg(var isLoginSuccess) async {
    try {
      if (isLoginSuccess) {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return const Home();
        }));
        // runApp(const Home());
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
                      setState(() {
                        selectedValue = value;
                      });
                    })),
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
