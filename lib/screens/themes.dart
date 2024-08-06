import 'package:flutter/material.dart';
import 'package:inimeg_the_sage/screens/story.dart';

/// Temporary screen that shows themes to pass as a prop to the Story screen
class Themes extends StatelessWidget {
  Themes({super.key});

  final List<Map<String, dynamic>> themes = [
    {"name": "Space", "key": "space"},
    {"name": "Medieval", "key": "medieval"},
    {"name": "Fantasy", "key": "fantasy"},
    {"name": "Mystery", "key": "mystery"},
    {"name": "Historical", "key": "historical"},
    {"name": "Pirate", "key": "pirate"},
    {"name": "Fairytale", "key": "fairytale"},
    {"name": "Dystopian", "key": "dystopian"},
    {"name": "Detective", "key": "detective"},
    {"name": "Thriller", "key": "thriller"},
    {"name": "Action", "key": "action"},
    {"name": "Adventure", "key": "adventure"},
    {"name": "Zombie", "key": "zombie"},
    {"name": "Vampire", "key": "vampire"},
    {"name": "Werewolf", "key": "werewolf"},
    {"name": "Alien", "key": "alien"},
    {"name": "Time travel", "key": "time-travel"},
    {"name": "Alternate history", "key": "alternate-history"},
    {"name": "Mythology", "key": "mythology"},
    {"name": "Magic", "key": "magic"},
    {"name": "Supernatural", "key": "supernatural"},
    {"name": "Paranormal", "key": "paranormal"},
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = screenWidth * 0.3;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Themes"),
      ),
      body: Center(
        child: ListView(children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              "Choose a theme for the story:",
              textAlign: TextAlign.center,
            ),
          ),
          ...themes.map((theme) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 2.0,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(buttonWidth, 50),
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Story(theme: theme["key"] as String)));
                  },
                  child: Text(theme["name"] as String),
                ),
              ),
            );
          })
        ]),
      ),
    );
  }
}
