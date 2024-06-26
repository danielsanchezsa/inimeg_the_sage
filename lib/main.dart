import 'package:flutter/material.dart';
import "package:flutter_dotenv/flutter_dotenv.dart";
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:inimeg_the_sage/screens/story.dart';

Future main() async {
  await dotenv.load(fileName: ".env");
  String geminiApiKey = dotenv.env["GEMINI_API_KEY"] as String;
  // Gemini.init(apiKey: "AIzaSyDiSCoD0eIMBA96TPxlgANdzzKo1JHX86s");
  Gemini.init(apiKey: geminiApiKey);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inimeg the Sage',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: "/",
      routes: {
        "/": (context) => const MyHomePage(title: 'Inimeg The Sage!!!'),
        "/story": (context) => const Story(),
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
                'Inimeg The Sage!!',
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/story");
                },
                child: const Text('Go to Story'),
              ),
            ],
          ),
        ));
  }
}
