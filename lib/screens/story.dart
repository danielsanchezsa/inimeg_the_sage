import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;

class Story extends StatefulWidget {
  final String theme;
  final String themeKey;
  final Color color;

  const Story(
      {super.key,
      required this.theme,
      required this.color,
      required this.themeKey});

  @override
  State<Story> createState() => _StoryState();
}

class _StoryState extends State<Story> {
  late GenerativeModel model;
  late var chat;
  String rawResponse = "";
  final List<String> _choices = [];
  String storyText = "";
  String imageURL = "";
  bool generatingStory = true;
  bool generatingImage = true;
  bool imageError = false;
  final ScrollController _scrollController = ScrollController();

  void initializeModel() async {
    await dotenv.load(fileName: ".env");
    String geminiApiKey = dotenv.env["GEMINI_API_KEY"] as String;
    model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: geminiApiKey);
    int interactions = 5;
    String initialPrompt =
        "Tell me a story in which I am the main character, and make it interactive, so that every time you tell me about the story you give me three choices that would lead me to different story outcomes. Make sure that the story only lasts for about $interactions interactions (choices) and that it always comes to an end, even if it has to be abrupt. The theme of the story should be \"${widget.theme}\". Respond in raw JSON only, so, start your response with \"{\" character and end it with \"}\", with three keys: \"story\", \"choices\", and \"imagePrompt\"; where \"story\" stores the string with the story text, \"choices\" contains an array of the choices as strings, and \"imagePrompt\" that is a prompt to generate an image. Make sure that the story is not repeating itself.";
    chat = model.startChat(
      history: [Content.text(initialPrompt)],
    );
    var response = await chat.sendMessage(Content.text(""));
    setState(() {
      rawResponse = response.text as String;
    });
    parseJSON();
  }

  void parseJSON() {
    final Map<String, dynamic> response =
        jsonDecode(rawResponse) as Map<String, dynamic>;
    final String imagePrompt = response["imagePrompt"] as String;
    createImage(imagePrompt);
    final String story = response["story"] as String;
    final choices = response["choices"];
    setState(() {
      _choices.clear();
      for (String choice in choices) {
        _choices.add(choice);
      }
      storyText = story;
      generatingStory = false;
    });
  }

  void createImage(String prompt) async {
    setState(() {
      generatingImage = true;
      imageError = false;
    });
    final String apiKey = dotenv.env["OPENAI_API_KEY"] as String;
    const String url = "https://api.openai.com/v1/images/generations";
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode(
          {"prompt": prompt, "n": 1, "size": "1792x1024", "model": "dall-e-3"}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;
      final imageURL = data["data"][0]["url"] as String;
      setState(() {
        this.imageURL = imageURL;
        generatingImage = false;
      });
    } else {
      print("Failed to generate image: ${response.body}");
      setState(() {
        generatingImage = false;
        imageError = true;
      });
    }
  }

  void selectChoice(String choice) async {
    _scrollController.animateTo(
      120.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
    setState(() {
      generatingStory = true;
      generatingImage = true;
    });
    rawResponse = "";
    var content = Content.text(choice);
    var response = await chat.sendMessage(content);
    setState(() {
      rawResponse = response.text;
    });
    parseJSON();
  }

  @override
  void initState() {
    super.initState();
    initializeModel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            title: Text(
              "${widget.theme} story by Inimeg",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            foregroundColor: widget.color.computeLuminance() > 0.5
                ? widget.color
                : Colors.white,
            floating: true,
            snap: true,
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.only(bottom: 30.0),
                  child: Column(
                    children: [
                      Image.asset(
                        "assets/images/inimeg_${widget.themeKey}.png",
                        height: 400.0,
                      ),
                      const SizedBox(height: 10),
                      generatingStory
                          ? const Text("Generating story...")
                          : const SizedBox(),
                      storyText.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 100.0, vertical: 30.0),
                              child: Text(
                                storyText,
                                style: const TextStyle(fontSize: 20),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : const SizedBox(),
                      imageURL.isNotEmpty && generatingImage
                          ? const Padding(
                              padding: EdgeInsets.only(bottom: 8.0),
                              child: Text("Generating next image..."),
                            )
                          : const SizedBox(),
                      imageError
                          ? const Padding(
                              padding: EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                  "Failed to generate image, please proceed with the story."),
                            )
                          : const SizedBox(),
                      imageURL.isNotEmpty
                          ? Image.network(
                              imageURL,
                              height: 400.0,
                            )
                          : const Text("Generating image..."),
                    ],
                  ),
                ),
                _choices.isEmpty
                    ? const SizedBox()
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                            ..._choices.map((choice) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
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
                                )),
                            const SizedBox(
                              height: 20.0,
                            )
                          ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
