import 'package:flutter/material.dart';
import 'package:ollama_dart/ollama_dart.dart';

class AppViewmodel extends ChangeNotifier {
  String _baseUrl = "http://copiwin.com:11434/api";
  OllamaClient ollamaClient = OllamaClient();
  List<Model> _models = [];
  Model? _model;

  String get baseUrl => _baseUrl;
  List<Model> get models => _models;
  Model? get model => _model;

  AppViewmodel() {
    ollamaClient = OllamaClient(baseUrl: _baseUrl);
  }

  void setBaseUrl(String value) {
    _baseUrl = value;
    ollamaClient = OllamaClient(baseUrl: _baseUrl);
    notifyListeners();
  }

  void setModel(Model model) {
    _model = model;
    notifyListeners();
  }

  Future<void> fetchModels() async {
    try {
      final modelResponse = await ollamaClient.listModels();
      _models = modelResponse.models ?? [];
      notifyListeners();
    } catch (e) {
      //
    }
  }
}
