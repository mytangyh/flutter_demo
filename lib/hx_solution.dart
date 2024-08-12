import 'package:flutter/material.dart';

class SolutionPage extends StatelessWidget {
  final List<Map<String, String>> solutions = [
    {'title': 'BigData', 'description': 'Solution Description'},
    {'title': 'User Marketing', 'description': 'Solution Description'},
    {'title': 'Wealth Management', 'description': 'Solution Description'},
    {'title': 'Financial Data', 'description': 'Solution Description'},
  ];

  final List<Map<String, String>> aiSolutions = [
    {'title': 'Voice Transcription', 'description': 'Solution Description'},
    {'title': 'AI Follow-Up', 'description': 'Solution Description'},
    {'title': 'AI Mission', 'description': 'Solution Description'},
    {'title': 'AI Customer Service', 'description': 'Solution Description'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Solutions'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'General Solution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemCount: solutions.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SolutionDetailPage(
                          title: solutions[index]['title']!,
                          description: solutions[index]['description']!,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4,
                    child: Center(
                      child: Text(
                        solutions[index]['title']!,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 32),
            Text(
              'AI Intelligent Medical Assistance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemCount: aiSolutions.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SolutionDetailPage(
                          title: aiSolutions[index]['title']!,
                          description: aiSolutions[index]['description']!,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4,
                    child: Center(
                      child: Text(
                        aiSolutions[index]['title']!,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SolutionDetailPage extends StatelessWidget {
  final String title;
  final String description;

  SolutionDetailPage({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          description,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
