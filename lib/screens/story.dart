import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class Story extends StatefulWidget {
  final String theme;
  final Color color;

  const Story({super.key, required this.theme, required this.color});

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
  String imagePrompt = "";

  void initializeModel() async {
    await dotenv.load(fileName: ".env");
    String geminiApiKey = dotenv.env["GEMINI_API_KEY"] as String;
    model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: geminiApiKey);
    int interactions = 5;
// TODO: implementar conexión de imagen
    String initialPrompt =
        "Tell me a story in which I am the main character, and make it interactive, so that every time you tell me about the story you give me three choices that would lead me to different story outcomes. Make sure that the story only lasts for about $interactions interactions. The theme of the story should be \"${widget.theme}\". Respond in raw JSON only, so, start your response with \"{\" character and end it with \"}\", with three keys: \"story\", \"choices\", and \"imagePrompt\"; where \"story\" stores the string with the story text, \"choices\" contains an array of the choices as strings, and \"imagePrompt\" that is a prompt to generate an image. Make sure that the story is not repeating itself.";
    chat = model.startChat(
      history: [Content.text(initialPrompt)],
    );
    var response = await chat.sendMessage(Content.text(""));
    setState(() {
      rawResponse = response.text as String;
    });
    parseJSON();
  }

  void setLoading(bool loading) {
    setState(() {
      isLoading = loading;
    });
  }

  void parseJSON() {
    final Map<String, dynamic> response =
        jsonDecode(rawResponse) as Map<String, dynamic>;
    final String story = response["story"] as String;
    final choices = response["choices"]; // NO PONER EXPLICIT TYPE PORQUE TRUENA
    final String imagePrompt = response["imagePrompt"] as String;
    setState(() {
      _choices.clear();
      for (String choice in choices) {
        _choices.add(choice);
      }
      storyText = story;
      this.imagePrompt = imagePrompt;
      isLoading = false;
    });
    print(imagePrompt);
  }

  void selectChoice(String choice) async {
    setLoading(true);
    rawResponse = "";
    var content = Content.text(choice);
    var response = await chat.sendMessage(content);
    setState(() {
      rawResponse = response.text;
    });
    parseJSON();
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
      appBar: AppBar(
        title: Text("Inimeg The Sage @ ${widget.theme}"),
        backgroundColor: widget.color,
        foregroundColor:
            widget.color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 30.0),
          child: ListView(
            children: [
              isLoading
                  ? Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Center(
                          child: CircularProgressIndicator(
                        color: widget.color,
                      )),
                    )
                  : storyText.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 100.0, vertical: 30.0),
                          child: Text(
                            storyText,
                            style: const TextStyle(fontSize: 20),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Center(
                              child: CircularProgressIndicator(
                            color: widget.color,
                          )),
                        ),
              _choices.isEmpty
                  ? const SizedBox()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: _choices
                          .map((choice) => Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor:
                                        widget.color.computeLuminance() > 0.5
                                            ? Colors.black
                                            : Colors.white,
                                    backgroundColor: widget.color,
                                  ),
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
