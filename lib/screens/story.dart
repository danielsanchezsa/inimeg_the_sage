// Story Screen while I develop the connection to the Gemini API
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class Story extends StatefulWidget {
  const Story({super.key});

  @override
  State<Story> createState() => _StoryState();
}

class _StoryState extends State<Story> {
  final gemini = Gemini.instance;
  final String systemInstructions =
      "Tell me a story in which I am the main character, and make it interactive, so that every time you tell me about the story you give me two or three options that would lead me to different story outcomes. The theme of the story should be \"space\".";
  final List<Text> _responses = [];

  void streamGenerateContent() {
    gemini.streamGenerateContent(systemInstructions).listen((value) {
      updateText(value.output as String);
    }).onError((e) {
      updateText("Error: $e");
    });
  }

  void updateText(String text) {
    setState(() {
      _responses.add(Text(text));
    });
  }

  @override
  void initState() {
    streamGenerateContent();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        children: [
          const Text("Story"),
          _responses.isEmpty
              ? const CircularProgressIndicator()
              : Column(
                  children: _responses,
                ),
        ],
      ),
    ));
  }
}
