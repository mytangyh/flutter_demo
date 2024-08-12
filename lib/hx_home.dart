import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> banners = [
    {
      'title': 'Banner 1',
      'details': 'Details for Banner 1',
    },
    {
      'title': 'Banner 2',
      'details': 'Details for Banner 2',
    },
  ];

  final List<Map<String, String>> items = [
    {
      'title': 'Big Data Marketing',
      'description': 'Based on the AARRR user lifecycle management model, it provides ...',
      'details': 'Based on the AARRR user lifecycle management model, it provides Internet operators with tools for data analysis and refined operation support...'
    },
    {
      'title': 'Smart Investment Assistant',
      'description': 'Based on the AARRR user lifecycle management model, it provides ...',
      'details': 'Based on the AARRR user lifecycle management model, it provides Internet operators with tools for data analysis and refined operation support...'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Column(
        children: <Widget>[
          // 滑动 Banner
          Container(
            height: 200,
            child: PageView.builder(
              controller: _pageController,
              itemCount: banners.length,
              onPageChanged: (int index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPage(
                          title: banners[index]['title']!,
                          details: banners[index]['details']!,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        banners[index]['title']!,
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Page indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(banners.length, (index) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 4),
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index
                      ? Colors.black
                      : Colors.black54,
                ),
              );
            }),
          ),
          // 卡片列表
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPage(
                          title: items[index]['title']!,
                          details: items[index]['details']!,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(items[index]['title']!),
                      subtitle: Text(items[index]['description']!),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final String title;
  final String details;

  DetailPage({required this.title, required this.details});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          details,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
