import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/favorite-stores'),
              child: const Text('View Favorite Stores'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/store-distance'),
              child: const Text('Calculate Store Distance'),
            ),
          ],
        ),
      ),
    );
  }
}