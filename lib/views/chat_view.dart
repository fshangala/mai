import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:mai/view_models/app_viewmodel.dart';
import 'package:mai/view_models/chat_viewmodel.dart';
import 'package:ollama_dart/ollama_dart.dart';
import 'package:provider/provider.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<StatefulWidget> createState() => ChatViewState();
}

class ChatViewState extends State<ChatView> {
  TextEditingController messageController = TextEditingController(text: "");

  final promptController = TextEditingController(text: "");

  @override
  Widget build(BuildContext context) {
    final appViewmodel = context.watch<AppViewmodel>();
    final chatViewmodel = context.watch<ChatViewmodel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(appViewmodel.model?.model ?? ""),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed("/");
            },
            icon: Icon(Icons.home),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed("/settings");
            },
            icon: Icon(Icons.settings),
            tooltip: "Settings",
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          spacing: 8.0,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: chatViewmodel.messages.length,
                itemBuilder: (context, index) {
                  final message = chatViewmodel.messages[index];
                  if (message.role == MessageRole.tool ||
                      message.content == "") {
                    return Text("");
                  }
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment:
                        message.role == MessageRole.user
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (message.role == MessageRole.assistant)
                            CircleAvatar(child: Icon(Icons.computer)),
                          // if (message.role == MessageRole.tool)
                          //   CircleAvatar(child: Icon(Icons.data_object)),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 8.0,
                            crossAxisAlignment:
                                message.role == MessageRole.user
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                            children: [
                              // if (message.thinking != null)
                              //   Container(
                              //     constraints: BoxConstraints(
                              //       maxWidth:
                              //           MediaQuery.of(context).size.width * 0.8,
                              //     ),
                              //     decoration: BoxDecoration(
                              //       borderRadius: BorderRadius.circular(8.0),
                              //     ),
                              //     margin: EdgeInsets.all(8.0),
                              //     child: MarkdownBody(data: message.thinking!),
                              //   ),
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.8,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                margin: EdgeInsets.all(8.0),
                                child: Card(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: MarkdownBody(data: message.content),
                                  ),
                                ),
                              ),
                              Text(DateTime.now().toIso8601String()),
                            ],
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
              spacing: 8.0,
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
                          chatViewmodel.errorMessage != null
                              ? Row(
                                spacing: 8.0,
                                children: [
                                  Expanded(
                                    child: Text(
                                      chatViewmodel.errorMessage ?? "",
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      chatViewmodel.clearErrorMessage();
                                    },
                                    icon: Icon(Icons.close, color: Colors.red),
                                  ),
                                ],
                              )
                              : null,
                    ),
                  ),
                ),
                chatViewmodel.loading
                    ? CircularProgressIndicator()
                    : IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () {
                        chatViewmodel.sendMessage(
                          Message(
                            role: MessageRole.user,
                            content: messageController.text,
                          ),
                        );
                        messageController.clear();
                      },
                    ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
