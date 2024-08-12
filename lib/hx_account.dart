import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Account Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AccountPage(),
    );
  }
}

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool _isSignedIn = false;  // 初始状态为未登录
  TextEditingController _emailController = TextEditingController();

  void _toggleSignInState() {
    setState(() {
      _isSignedIn = !_isSignedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: _emailController,
              readOnly: _isSignedIn,  // 登录后禁止编辑邮箱
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_isSignedIn) {
                  // 如果已经登录，则登出并清空邮箱输入框
                  _emailController.clear();
                }
                _toggleSignInState();
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text(_isSignedIn ? 'Sign Out Email' : 'Sign In Email'),
            ),
          ],
        ),
      ),
    );
  }
}
