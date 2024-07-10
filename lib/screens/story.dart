import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'dart:convert';

class Story extends StatefulWidget {
  final String theme;
  const Story({super.key, required this.theme});

  @override
  State<Story> createState() => _StoryState();
}

class _StoryState extends State<Story> {
  final gemini = Gemini.instance;
  String rawResponse = "";
  final List<String> _choices = [];
  String storyText = "";
  bool isLoading = false;
  final List<Content> conversationHistory = [];

  void streamGenerateContent(List<Content> conversation) {
    setState(() {
      isLoading = true;
    });

    gemini.chat(conversation).then((value) {
      print(value?.output);
      updateText(value?.output ?? 'No output');
    }).catchError((e) {
      updateText("Error: $e");
    });
  }

  void updateText(String text) {
    rawResponse += text;
    if (isResponseComplete(rawResponse)) {
      parseJSON();
    }
  }

  bool isResponseComplete(String response) {
    return response.trim().endsWith('}');
  }

  void parseJSON() {
    if (rawResponse.isNotEmpty) {
      final Map<String, dynamic> response =
          jsonDecode(rawResponse) as Map<String, dynamic>;
      final String story = response["story"] as String;
      final List<dynamic> choices = response["choices"] as List<dynamic>;
      setState(() {
        _choices.clear();
        for (var choice in choices) {
          _choices.add(choice["text"] as String);
        }
        storyText = story;
        isLoading = false;
      });
    }
  }

  void selectChoice(String choice) {
    rawResponse = "";
    // Update conversation history with user's choice
    conversationHistory
        .add(Content(parts: [Parts(text: choice)], role: 'user'));

    // Prepare new instructions for the model
    List<Content> conversation = List.from(conversationHistory);
    conversation.add(Content(parts: [
      Parts(
          text:
              "Continue the story based on the choice: \"$choice\". Remember to provide three choices for the next step.")
    ], role: 'model'));

    streamGenerateContent(conversation);
  }

  @override
  void initState() {
    super.initState();
    // Initial instructions for the story
    String initialPrompt =
        "Tell me a story in which I am the main character, and make it interactive, so that every time you tell me about the story you give me three choices that would lead me to different story outcomes. The theme of the story should be \"${widget.theme}\". Respond in raw JSON only, so, start your response with \"{\" character and end it with \"}\", with two keys: \"story\" and \"choices\", where \"story\" stores the string with the story text, and \"choices\" contains keys \"text\" and \"id\".";

    conversationHistory
        .add(Content(parts: [Parts(text: initialPrompt)], role: 'user'));
    streamGenerateContent(conversationHistory);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: ListView(
            children: [
              SizedBox(
                width: 200.0,
                child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Back")),
              ),
              isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : storyText.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(100.0),
                          child: Text(
                            storyText,
                            style: const TextStyle(fontSize: 20),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : const Text("Loading..."),
              _choices.isEmpty
                  ? const SizedBox()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: _choices
                          .map((choice) => Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: ElevatedButton(
                                  onPressed: () => selectChoice(choice),
                                  child: Text(choice),
                                ),
                              ))
                          .toList(),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
