import 'package:flutter/material.dart';
import 'hx_account.dart';
import 'hx_home.dart';
import 'hx_news.dart';
import 'hx_solution.dart';
import 'navi.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
      navigatorObservers: [MyNavigatorObserver()],
    );
  }
}

class MyNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    print('Page entered: ${route.settings.name}');
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    print('Page exited: ${route.settings.name}');
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    SolutionPage(),
    NewsPage(),
    AccountPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _logUserAction('Exiting ${_getTabName(_selectedIndex)}');
      _selectedIndex = index;
      _logUserAction('Entering ${_getTabName(_selectedIndex)}');
    });
  }

  // 返回当前选中标签页的名称
  String _getTabName(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Solution';
      case 2:
        return 'News';
      case 3:
        return 'Account';
      default:
        return 'Unknown';
    }
  }

  // 日志记录函数
  void _logUserAction(String action) {
    final DateTime now = DateTime.now();
    final String timestamp = now.toIso8601String();
    print('[$timestamp] User action: $action');
    // 在这里可以扩展，例如将日志发送到服务器或保存到本地文件中
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build),
            label: 'Solution',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: 'News',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
