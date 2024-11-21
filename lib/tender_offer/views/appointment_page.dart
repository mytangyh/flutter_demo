import 'package:flutter/material.dart';

class AppointmentPage extends StatelessWidget {
  const AppointmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('预约收购'),
      ),
      body: ListView(
        children: _buildListItems(context),
      ),
    );
  }

  List<Widget> _buildListItems(BuildContext context) {
    final items = [
      _ListItem(
        title: '预受要约',
        onTap: () => Navigator.pushNamed(context, '/accept'),
      ),
      _ListItem(
        title: '解除要约',
        onTap: () => Navigator.pushNamed(context, '/withdraw'),
      ),
    ];

    return items.expand((item) => [
      item,
      const Divider(height: 1),
    ]).toList();
  }
}

class _ListItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _ListItem({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
} 