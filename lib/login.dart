import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<bool> loginResponse() async {
    var map = {
      'username': usernameController.text,
      'password': passwordController.text
    };
    var url = Uri.parse('http://192.168.0.238/okhttp/api/values/Login');
    var response = await http.post(url, body: map);
    if (response.statusCode == 200) {
      debugPrint('Response body: ${response.body}');
    }
    return false;
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
                      const snackBar =
                          SnackBar(content: Text("User Name is empty"));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      return;
                    }
                    if (passwordController.text.isEmpty) {
                      const snackBar =
                          SnackBar(content: Text("Password is empty"));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      return;
                    }
                    var response = loginResponse();
                    bool isLoginSuccess = false;
                    response.then((value) => isLoginSuccess = value);
                    if (isLoginSuccess) {
                      const snackBar = SnackBar(content: Text("登入成功"));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    } else {
                      const snackBar = SnackBar(content: Text("登入失敗"));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
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
                  },
                )
              ],
            ),
          ],
        ));
  }
}