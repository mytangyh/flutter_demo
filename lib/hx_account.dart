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

// 单例类，用于在内存中保存全局状态
class AppState {
  static final AppState _instance = AppState._internal();

  bool isSignedIn = false;
  String email = '';

  factory AppState() {
    return _instance;
  }

  AppState._internal();
}

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 加载全局状态
    _emailController.text = AppState().email;
  }

  void _toggleSignInState() {
    setState(() {
      AppState().isSignedIn = !AppState().isSignedIn;
      if (AppState().isSignedIn) {
        // 登录时保存邮箱
        AppState().email = _emailController.text;
      } else {
        // 登出时清除邮箱
        _emailController.clear();
        AppState().email = '';
      }
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
              readOnly: AppState().isSignedIn,  // 登录后禁止编辑邮箱
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _toggleSignInState,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text(AppState().isSignedIn ? 'Sign Out Email' : 'Sign In Email'),
            ),
          ],
        ),
      ),
    );
  }
}
