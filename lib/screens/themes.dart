import 'package:flutter/material.dart';
import 'package:inimeg_the_sage/screens/story.dart';

class Themes extends StatelessWidget {
  Themes({super.key});

  final List<Map<String, dynamic>> themes = [
    {"name": "Space", "key": "space", "color": Colors.blueGrey},
    {"name": "Medieval", "key": "medieval", "color": Colors.brown},
    {"name": "Fantasy ", "key": "fantasy", "color": Colors.purple},
    {"name": "Action", "key": "action", "color": Colors.red},
    {"name": "Adventure", "key": "adventure", "color": Colors.green},
    {"name": "Mythology", "key": "mythology", "color": Colors.orange},
    {"name": "Magic", "key": "magic", "color": Colors.indigo},
    {"name": "Horror", "key": "horror", "color": Colors.black},
    {"name": "Sci-Fi", "key": "scifi", "color": Colors.teal},
    {"name": "Romance", "key": "romance", "color": Colors.pink},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text('Select Theme'),
            floating: true,
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final theme = themes[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
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
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15.0),
                            child: Image.asset(
                              'assets/images/inimeg_${theme["key"]}.png',
                              height: 350,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            left: 10,
                            child: Container(
                              color: Colors.black54,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5.0, horizontal: 10.0),
                              child: Text(
                                theme["name"] as String,
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              childCount: themes.length,
            ),
          ),
        ],
      ),
    );
  }
}
