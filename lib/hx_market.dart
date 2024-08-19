import 'package:flutter/material.dart';

class InviteCodePage extends StatefulWidget {
  @override
  _InviteCodePageState createState() => _InviteCodePageState();
}

class _InviteCodePageState extends State<InviteCodePage> {
  String inviteCode = '';
  String redemptionCode = '';
  String activationMessage = '';

  void getInviteCode() {
    // 模拟获取邀请码的操作
    setState(() {
      inviteCode = 'ABC123';  // 假设返回的邀请码
    });
  }

  void activateRedemptionCode() {
    // 模拟激活兑换码的操作
    if (redemptionCode == '123') {
      setState(() {
        activationMessage = '兑换码激活成功!';
      });
    } else {
      setState(() {
        activationMessage = '兑换码无效，请重试。';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Marketing Journey'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Invitation Code:', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: getInviteCode,
              child: Text('Get Invitation Code'),
            ),
            SizedBox(height: 8),
            Text(inviteCode.isNotEmpty ? 'Your invite code is: $inviteCode' : 'Please click the button to get the invitation code'),
            SizedBox(height: 20),
            Text('Activation Redemption Code:', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            TextField(
              onChanged: (value) {
                redemptionCode = value;
              },
              decoration: InputDecoration(
                labelText: 'Please enter the redemption code',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: activateRedemptionCode,
              child: Text('Activation Redemption Code'),
            ),
            SizedBox(height: 8),
            Text(activationMessage),
          ],
        ),
      ),
    );
  }
}
