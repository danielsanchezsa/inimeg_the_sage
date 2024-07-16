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
    {"name": "Superhero", "key": "superhero"},
    {"name": "Western", "key": "western"},
    {"name": "Cyberpunk", "key": "cyberpunk"},
    {"name": "Post-apocalyptic", "key": "post-apocalyptic"},
    {"name": "Historical", "key": "historical"},
    {"name": "Steampunk", "key": "steampunk"},
    {"name": "Pirate", "key": "pirate"},
    {"name": "Fairytale", "key": "fairytale"},
    {"name": "Dystopian", "key": "dystopian"},
    {"name": "Detective", "key": "detective"},
    {"name": "Thriller", "key": "thriller"},
    {"name": "Action", "key": "action"},
    {"name": "Adventure", "key": "adventure"},
    {"name": "Apocalyptic", "key": "apocalyptic"},
    {"name": "Zombie", "key": "zombie"},
    {"name": "Vampire", "key": "vampire"},
    {"name": "Werewolf", "key": "werewolf"},
    {"name": "Alien", "key": "alien"},
    {"name": "Time travel", "key": "time-travel"},
    {"name": "Alternate history", "key": "alternate-history"},
    {"name": "Fairy", "key": "fairy"},
    {"name": "Mythology", "key": "mythology"},
    {"name": "Magic", "key": "magic"},
    {"name": "Supernatural", "key": "supernatural"},
    {"name": "Paranormal", "key": "paranormal"},
    {"name": "Urban fantasy", "key": "urban-fantasy"},
    {"name": "Epic fantasy", "key": "epic-fantasy"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Themes"),
      ),
      body: Center(
        child: ListView(
          children: themes.map((theme) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              Story(theme: theme["key"] as String)));
                },
                child: Text(theme["name"] as String),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
