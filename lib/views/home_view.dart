import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:ollama_dart/ollama_dart.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _client = OllamaClient(baseUrl: "http://copiwin.com:11434/api");
  List<Message> messages = [];
  String? errorMessage;
  TextEditingController messageController = TextEditingController(text: "");
  ScrollController scrollController = ScrollController();

  bool loading = false;

  Future<void> sendMessage() async {
    setState(() {
      loading = true;
      messages.add(
        Message(role: MessageRole.user, content: messageController.text),
      );
    });

    final stream = _client.generateChatCompletionStream(
      request: GenerateChatCompletionRequest(
        model: "amy",
        messages: messages,
        think: false,
      ),
    );

    String text = "";
    int i = messages.length;
    stream.listen(
      (response) {
        if (text.isEmpty) {
          setState(() {
            messages.add(Message(role: MessageRole.assistant, content: text));
          });
        }
        text += response.message.content;
        setState(() {
          if (!loading) {
            loading = true;
          }
          messages[i] = Message(role: MessageRole.assistant, content: text);
        });
      },
      onError: (e) {
        setState(() {
          loading = false;
          errorMessage = e.message;
          messages.removeLast();
        });
      },
      onDone: () {
        setState(() {
          loading = false;
          messageController.clear();
        });
      },
    );
  }

  final promptController = TextEditingController(text: "");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Amy")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          spacing: 8.0,
          children: [
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment:
                        message.role == MessageRole.user
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (message.role == MessageRole.assistant)
                            CircleAvatar(child: Icon(Icons.computer)),
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.8,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            margin: EdgeInsets.all(8.0),
                            child: Card(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: MarkdownBody(
                                  data: messages[index].content,
                                ),
                              ),
                            ),
                          ),
                          if (message.role == MessageRole.user)
                            CircleAvatar(child: Icon(Icons.person)),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    maxLines: 5,
                    minLines: 1,
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message",
                      error:
                          errorMessage != null
                              ? Row(
                                children: [
                                  Expanded(child: Text(errorMessage ?? "")),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        errorMessage = null;
                                      });
                                    },
                                    icon: Icon(Icons.close, color: Colors.red),
                                  ),
                                ],
                              )
                              : null,
                    ),
                  ),
                ),
                loading
                    ? CircularProgressIndicator()
                    : IconButton(
                      icon: Icon(Icons.send),
                      onPressed: sendMessage,
                    ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
