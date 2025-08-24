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

  Future<void> sendMessage(String messageContent) async {
    _messages.add(Message(role: MessageRole.user, content: messageContent));
    notifyListeners();

    final stream = _appViewmodel.ollamaClient.generateChatCompletionStream(
      request: GenerateChatCompletionRequest(
        model: _appViewmodel.model!.model!,
        messages: messages,
        think: false,
      ),
    );

    String text = "";
    int i = messages.length;
    stream.listen(
      (response) {
        if (text.isEmpty) {
          _messages.add(Message(role: MessageRole.assistant, content: text));
          notifyListeners();
        }
        text += response.message.content;
        if (!loading) {
          _loading = true;
        }
        _messages[i] = Message(role: MessageRole.assistant, content: text);
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
