import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NewsPage(),
    );
  }
}

class NewsPage extends StatelessWidget {
  final List<Map<String, String>> newsItems = [
    {"title": "news 1", "overview": "new1 overview"},
    {"title": "news 2", "overview": "new2 overview"},
    {"title": "news 3", "overview": "new3 overview"},
    {"title": "news 4", "overview": "new4 overview"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('News'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: newsItems.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: ListTile(
              title: Text(newsItems[index]["title"]!),
              subtitle: Text(newsItems[index]["overview"]!),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewsDetailPage(
                      title: newsItems[index]["title"]!,
                      content: "news details",  // 假设每个新闻的详细内容相同
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class NewsDetailPage extends StatelessWidget {
  final String title;
  final String content;

  NewsDetailPage({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(content),
      ),
    );
  }
}
