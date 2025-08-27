import 'package:flutter/material.dart';
import 'package:mai/view_models/app_viewmodel.dart';
import 'package:ollama_dart/ollama_dart.dart';

class ChatViewmodel extends ChangeNotifier {
  AppViewmodel _appViewmodel;
  List<Message> _messages = [];
  String? _errorMessage;
  bool _loading = false;

  ChatViewmodel({required AppViewmodel appViewmodel})
    : _appViewmodel = appViewmodel {
    _onCreate();
    _appViewmodel.addListener(_onCreate);
  }

  List<Message> get messages => _messages;
  String? get errorMessage => _errorMessage;
  bool get loading => _loading;

  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  void _onCreate() async {
    clearErrorMessage();
    clearMessages();
  }

  DateTime getDate() {
    return DateTime.now();
  }

  Future<void> sendMessage(Message message) async {
    _messages.add(message);
    _loading = true;
    notifyListeners();

    final stream = _appViewmodel.ollamaClient.generateChatCompletionStream(
      request: GenerateChatCompletionRequest(
        model: _appViewmodel.model!.model!,
        messages: messages,
        tools: [
          Tool(
            type: ToolType.function,
            function: ToolFunction(
              name: "get_date",
              description: "Get the current date and time.",
              parameters: {},
            ),
          ),
        ],
        think: true,
      ),
    );

    String text = "";
    String think = "";
    int i = messages.length;
    bool init = true;
    stream.listen(
      (response) {
        if (init) {
          _messages.add(
            Message(
              role: MessageRole.assistant,
              content: text,
              thinking: think,
            ),
          );
          init = false;
          notifyListeners();
        }
        if (response.message.thinking != null) {
          think += response.message.thinking ?? "";
        }
        if (response.message.content.isNotEmpty) {
          text += response.message.content;
        }
        if (response.message.toolCalls != null) {
          response.message.toolCalls!.forEach((toolCall) async {
            switch (toolCall.function!.name) {
              case "get_date":
                var date = getDate();
                await sendMessage(
                  Message(
                    role: MessageRole.tool,
                    content: date.toIso8601String(),
                  ),
                );
                break;
              default:
            }
          });
        }
        if (!loading) {
          _loading = true;
        }
        _messages[i] = Message(
          role: MessageRole.assistant,
          content: text,
          thinking: think,
        );
        notifyListeners();
      },
      onError: (e) {
        _loading = false;
        _errorMessage = e.message;
        _messages.removeLast();
        notifyListeners();
      },
      onDone: () {
        _loading = false;
        notifyListeners();
      },
    );
  }
}
