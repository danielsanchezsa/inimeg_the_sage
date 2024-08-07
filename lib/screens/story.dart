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
  bool isLoading = false;
  String _imageURL = "";

  void initializeModel() async {
    await dotenv.load(fileName: ".env");
    String geminiApiKey = dotenv.env["GEMINI_API_KEY"] as String;
    model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: geminiApiKey);
    int interactions = 5;
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
      isLoading = false;
    });
  }

  void createImage(String prompt) async {
    // final String apiKey = dotenv.env["OPENAI_API_KEY"] as String;
    // const String url = "https://api.openai.com/v1/images/generations";
    // final response = await http.post(
    //   Uri.parse(url),
    //   headers: {
    //     'Content-Type': 'application/json',
    //     'Authorization': 'Bearer $apiKey',
    //   },
    //   body: jsonEncode(
    //       {"prompt": prompt, "n": 1, "size": "1792x1024", "model": "dall-e-3"}),
    // );

    // if (response.statusCode == 200) {
    //   final Map<String, dynamic> data =
    //       jsonDecode(response.body) as Map<String, dynamic>;
    //   final imageURL = data["data"][0]["url"] as String;
    //   setState(() {
    //     _imageURL = imageURL;
    //   });
    // } else {
    //   print("Failed to generate image: ${response.body}");
    // }
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text("${widget.theme} story by Inimeg"),
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
                  child: isLoading
                      ? _imageURL.isNotEmpty
                          ? Image.network(
                              _imageURL,
                              fit: BoxFit.cover,
                              height: 400.0,
                            )
                          : Image.asset(
                              "assets/images/inimeg_${widget.themeKey}.png",
                              height: 400.0,
                            )
                      : storyText.isNotEmpty
                          ? Column(
                              children: [
                                const SizedBox(height: 10),
                                _imageURL.isNotEmpty
                                    ? Image.network(
                                        _imageURL,
                                        fit: BoxFit.cover,
                                        height: 400.0,
                                      )
                                    : Image.asset(
                                        "assets/images/inimeg_${widget.themeKey}.png",
                                        height: 400.0,
                                      ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 100.0, vertical: 30.0),
                                  child: Text(
                                    storyText,
                                    style: const TextStyle(fontSize: 20),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            )
                          : Center(
                              child: Padding(
                                padding: const EdgeInsets.all(100.0),
                                child: CircularProgressIndicator(
                                  color: widget.color,
                                ),
                              ),
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
