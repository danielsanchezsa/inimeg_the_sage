import 'package:flutter/material.dart';
import 'dart:convert';
import "package:flutter_dotenv/flutter_dotenv.dart";
import 'package:google_generative_ai/google_generative_ai.dart';

class Story extends StatefulWidget {
  final String theme;
  const Story({super.key, required this.theme});

  @override
  State<Story> createState() => _StoryState();
}

class _StoryState extends State<Story> {
  late GenerativeModel model;
  late var chat;
  String rawResponse = "";
  final List<String> _choices = [];
  String storyText = "";
  bool isLoading = false;
  final List<Content> conversationHistory = [];

  void initializeModel() async {
    await dotenv.load(fileName: ".env");
    String geminiApiKey = dotenv.env["GEMINI_API_KEY"] as String;
    // The Gemini 1.5 models are versatile and work with most use cases
    model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: geminiApiKey);
    // Initial instructions for the story
    String initialPrompt =
        "Tell me a story in which I am the main character, and make it interactive, so that every time you tell me about the story you give me three choices that would lead me to different story outcomes. Make sure that the story only lasts for about 5 interactions. The theme of the story should be \"${widget.theme}\". Respond in raw JSON only, so, start your response with \"{\" character and end it with \"}\", with two keys: \"story\" and \"choices\", where \"story\" stores the string with the story text, and \"choices\" contains keys \"text\" and \"id\". Make every story to last for at least 10 turns, and make sure that the story is not repeating itself.";
    chat = model.startChat(
      history: [Content.text(initialPrompt)],
    );
    var response = await chat.sendMessage(Content.text(""));
    updateText(response.text);
  }

  void setLoading(bool loading) {
    setState(() {
      isLoading = loading;
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

  void selectChoice(String choice) async {
    setLoading(true);
    rawResponse = "";
    // Update conversation history with user's choice
    var content = Content.text(choice);
    var response = await chat.sendMessage(content);
    updateText(response.text);
    setLoading(false);
  }

  @override
  void initState() {
    super.initState();
    initializeModel();
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
              Text(
                "Theme: ${widget.theme}",
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
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
