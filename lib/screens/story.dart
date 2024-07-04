// Story Screen while I develop the connection to the Gemini API
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'dart:convert';

class Story extends StatefulWidget {
  const Story({super.key});

  // TODO (1): Pasar el argumento de la pantalla de temas para ponerlo en las instrucciones

  /// System instructions for the model to initiate the story.
  final String kSystemInstructions =
      "Tell me a story in which I am the main character, and make it interactive, so that every time you tell me about the story you give me three choices that would lead me to different story outcomes. The theme of the story should be \"space\". \nRespond in a JSON format only, with two keys: \"story\" and \"choices\", where \"story\" simply stores the string with the story text, so whatever you are telling the user, and \"choices\" contains keys \"text\" and \"id\", so that I can parse this JSON in my code and render the story choices as buttons.";

  @override
  State<Story> createState() => _StoryState();
}

class _StoryState extends State<Story> {
  final gemini = Gemini.instance;
  final List<Text> _responses = [];
  String rawResponse = "";
  final List<String> _choices = [];
  String storyText = "";

  void streamGenerateContent() {
    gemini.streamGenerateContent(widget.kSystemInstructions).listen((value) {
      updateText(value.output as String);
    }).onError((e) {
      updateText("Error: $e");
    });
  }

  void updateText(String text) {
    // No es óptimo, pero es suficiente para este ejemplo
    // TODO (2): Mejorar el manejo de la respuesta de gemini para limpiar JSON, ejecutar la limpieza solo una vez
    if (text.contains("```json")) {
      text = text.replaceAll("```json", "");
    } else if (text.contains("```")) {
      text = text.replaceAll("```", "");
    }
    setState(() {
      _responses.add(Text(text));
      rawResponse += text;
    });
  }

  void parseJSON() {
    if (rawResponse.isNotEmpty) {
      final Map<String, dynamic> response =
          jsonDecode(rawResponse) as Map<String, dynamic>;
      final String story = response["story"] as String;
      final List<dynamic> choices = response["choices"] as List<dynamic>;
      for (var choice in choices) {
        setState(() {
          _choices.add(choice["text"] as String);
        });
      }
      setState(() {
        storyText = story;
      });
    }
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
      child: ListView(
        children: [
          ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Back")),
          ElevatedButton(
              onPressed: () => print(rawResponse),
              child: const Text("Print Raw Response")),
          ElevatedButton(onPressed: parseJSON, child: const Text("Parse JSON")),
          const Text("Story"),
          _responses.isEmpty
              ? const CircularProgressIndicator()
              : storyText.isNotEmpty
                  ? Text(storyText)
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: _responses,
                    ),
          _choices.isEmpty
              ? const Text("Choices")
              : Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: _choices
                      .map((choice) => ElevatedButton(
                            onPressed: () => print(choice),
                            child: Text(choice),
                          ))
                      .toList(),
                ),
        ],
      ),
    ));
  }
}
