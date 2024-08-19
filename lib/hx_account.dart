import 'package:flutter/material.dart';

import 'hx_home.dart';
import 'hx_market.dart';

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String pageId = "00004";
  String pageName = "AccountPage";
  bool _isSignedIn = false; // 初始状态为未登录
  TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _toggleSignInState() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSignedIn = !_isSignedIn;
        if (_isSignedIn) {
          // HithinkTracking.loginAccount(_emailController.text);
        } else {
          // HithinkTracking.logoutAccount();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Email',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                readOnly: _isSignedIn,
                // 登录后禁止编辑邮箱
                style:
                    TextStyle(color: _isSignedIn ? Colors.grey : Colors.black),
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    hintText: 'Enter your email'),
                validator: (value) {
                  if (!_isSignedIn && (value == null || value.isEmpty)) {
                    return 'Email cannot be empty';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // HithinkTracking.doClick(pageId, pageName,
                  //     elementModuleName: "0001",
                  //     elementName: "LoginButton",
                  //     extendParam: {
                  //       'clientTime': DateTime.timestamp().toString()
                  //     }
                  // );

                  _toggleSignInState();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text(_isSignedIn ? 'Sign Out Email' : 'Sign In Email'),
              ),
              SizedBox(height: 16),
              if (_isSignedIn)
                ElevatedButton(
                  onPressed: () {
                    // HithinkTracking.doClick(pageId, pageName,
                    //     elementModuleName: "0001",
                    //     elementName: "LoginButton",
                    //     extendParam: {
                    //       'clientTime': DateTime.timestamp().toString()
                    //     }
                    // );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InviteCodePage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text('GoTo'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
