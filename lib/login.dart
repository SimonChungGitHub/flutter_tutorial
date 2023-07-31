import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_tutorial/main.dart';
import 'package:flutter_tutorial/utils.dart';
import 'package:http/http.dart' as http;
import 'package:nfc_manager/nfc_manager.dart';
import 'config.dart';
import 'custom_loading.dart';
import 'global_data.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);
  static const String _title = 'Login';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        navigatorObservers: [FlutterSmartDialog.observer],
        builder: FlutterSmartDialog.init(),
        title: _title,
        home: const Scaffold(body: LoginPage()));
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ValueNotifier<dynamic> _tagID = ValueNotifier("");
  FocusNode myFocusNode = FocusNode();
  bool isAvailableNFC = false;
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    _enableNFC();
  }

  @override
  void dispose() {
    super.dispose();
    if (isAvailableNFC) NfcManager.instance.stopSession();
    myFocusNode.dispose();
  }

  void _enableNFC() async {
    isAvailableNFC = await NfcManager.instance.isAvailable();
    if (isAvailableNFC) {
      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          var identifier = tag.data['nfca']['identifier'];
          _tagID.value = identifierToHex(identifier);
          debugPrint('\u001b[31m${tag.data}============\u001b[0m');
          debugPrint('\u001b[31m${_tagID.value}\u001b[0m');
          _startLogin();
        },
      );
    }
  }

  void _startLogin() {
    // checkPermission().then((value) => {
    //       if (value)
    //         {
    //           _loginResponse().then((value) {
    //             try {
    //               var isLoginSuccess = value['result'];
    //               if (isLoginSuccess) {
    //                 isLogin = true;
    //                 runApp(const MyApp());
    //               } else {
    //                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //                     content: Text(value['errorMessage'].toString())));
    //               }
    //             } catch (e) {
    //               debugPrint(e.toString());
    //             }
    //           })
    //         }
    //     });

    _loginResponse().then((value) {
      try {
        var isLoginSuccess = value['result'];
        if (isLoginSuccess) {
          isLogin = true;
          runApp(const MyApp());
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(value['errorMessage'].toString())));
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    });
  }

  Future<Map> _loginResponse() async {
    try {
      SmartDialog.showLoading(
        animationType: SmartAnimationType.scale,
        builder: (_) => const CustomLoading(type: 5),
      );
      await Future.delayed(const Duration(seconds: 2));
      var map = {
        'username': _usernameController.text,
        'password': _passwordController.text,
        'tag': _tagID.value,
      };
      debugPrint('\u001b[31m${map.toString()}\u001b[0m');
      var url = Uri.parse(loginURL);
      var response = await http
          .post(url, body: jsonEncode(map))
          .timeout(const Duration(seconds: 5));
      var code = response.statusCode;
      if (code == 200) {
        var result = json.decode(response.body)['result'];
        if (result) {
          return {'result': true};
        } else {
          if (_tagID.value.toString().isNotEmpty) {
            return {'result': false, 'errorMessage': '登入失敗：NFC 標籤錯誤'};
          } else {
            return {'result': false, 'errorMessage': '登入失敗：帳號密碼錯誤'};
          }
        }
      } else {
        return {'result': false, 'errorMessage': '登入失敗： code $code'};
      }
    } catch (e) {
      debugPrint(e.toString());
      return {'result': false, 'errorMessage': '登入失敗： $e'};
    } finally {
      SmartDialog.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          alignment: Alignment.bottomLeft,
            child:ListView(
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
                padding: const EdgeInsets.fromLTRB(10, 80, 10, 0),
                child: const Text(
                  'Fill name and pwd to login',
                  style: TextStyle(fontSize: 15),
                )),
            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'UserName',
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: TextField(
                obscureText: _passwordVisible,
                controller: _passwordController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    onPressed: () {
                      setState(() => _passwordVisible = !_passwordVisible);
                    },
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                //todo forgot password screen
              },
              child: const Text(
                'Forgot Password',
              ),
            ),
            Container(
                height: 50,
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: ElevatedButton(
                  focusNode: myFocusNode,
                  child: const Text('Login'),
                  onPressed: () {
                    if (_usernameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Fill UserName')));
                      return;
                    }
                    if (_passwordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Fill Password')));
                      return;
                    }
                    _startLogin();
                    myFocusNode.requestFocus();
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
                    //todo signup screen
                  },
                )
              ],
            ),
          ],
        )));
  }
}
