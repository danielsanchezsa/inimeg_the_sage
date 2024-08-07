import 'package:flutter/material.dart';
import 'package:inimeg_the_sage/screens/story.dart';

class Themes extends StatelessWidget {
  Themes({super.key});

  final List<Map<String, dynamic>> themes = [
    {"name": "Space 🚀", "key": "space", "color": Colors.blueGrey},
    {"name": "Medieval 🏰", "key": "medieval", "color": Colors.brown},
    {"name": "Fantasy 🧚‍♂️", "key": "fantasy", "color": Colors.purple},
    {"name": "Action 🔫", "key": "action", "color": Colors.red},
    {"name": "Adventure 🗺️", "key": "adventure", "color": Colors.green},
    {"name": "Mythology 🏺", "key": "mythology", "color": Colors.orange},
    {"name": "Magic 🪄", "key": "magic", "color": Colors.indigo},
    {"name": "Horror 🧟", "key": "horror", "color": Colors.black},
    {"name": "Sci-Fi 🤖", "key": "scifi", "color": Colors.teal},
    {"name": "Romance 💖", "key": "romance", "color": Colors.pink},
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = screenWidth * 0.4;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Theme'),
      ),
      body: Center(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                "Choose a theme for the story",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                childAspectRatio: (buttonWidth / 80), // Adjust height as needed
                padding:
                    const EdgeInsets.symmetric(horizontal: 38.0, vertical: 8.0),
                children: themes.map((theme) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(buttonWidth, 50),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Story(
                              theme: theme["name"] as String,
                              color: theme["color"] as Color,
                              themeKey: theme["key"] as String,
                            ),
                          ),
                        );
                      },
                      child: Text(theme["name"] as String),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
