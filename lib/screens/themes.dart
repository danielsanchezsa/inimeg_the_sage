import 'package:flutter/material.dart';
import 'package:inimeg_the_sage/screens/story.dart';

/// Temporary screen that shows themes to pass as a prop to the Story screen
class Themes extends StatelessWidget {
  Themes({super.key});

  final List<Map<String, dynamic>> themes = [
    {"name": "Space", "key": "space"},
    {"name": "Medieval", "key": "medieval"},
    {"name": "Fantasy", "key": "fantasy"},
    {"name": "Sci-fi", "key": "sci-fi"},
    {"name": "Horror", "key": "horror"},
    {"name": "Mystery", "key": "mystery"},
    {"name": "Romance", "key": "romance"},
    {"name": "Comedy", "key": "comedy"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Themes"),
      ),
      body: Center(
        child: Column(
          children: themes.map((theme) {
            return ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            Story(theme: theme["key"] as String)));
              },
              child: Text(theme["name"] as String),
            );
          }).toList(),
        ),
      ),
    );
  }
}
