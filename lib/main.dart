import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inimeg_the_sage/screens/story.dart';
import 'package:inimeg_the_sage/screens/themes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    // Set landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    return MaterialApp(
      title: 'Inimeg the Sage',
      theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.black, brightness: Brightness.dark)),
      initialRoute: "/",
      routes: {
        "/": (context) => const MyHomePage(title: 'Inimeg The Sage'),
        "/themes": (context) => Themes(),
        "/story": (context) => const Story(
              theme: "space",
            ),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Inimeg The Sage',
                style: TextStyle(fontSize: 30),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Inimeg is a wise sage who loves to tell stories. Choose a theme for the story, and Inimeg will embark on a journey to tell you a story based on the theme you choose, while generating choices for you to make, and take the story in the direction you want.",
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/themes");
                },
                child: const Text('Choose a story theme!'),
              ),
            ],
          ),
        ));
  }
}
