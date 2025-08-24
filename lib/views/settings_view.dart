import 'package:flutter/material.dart';
import 'package:mai/view_models/app_viewmodel.dart';
import 'package:provider/provider.dart';

class SettingsView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SettingsViewState();
}

class SettingsViewState extends State<SettingsView> {
  final baseUrlController = TextEditingController(text: "");

  @override
  void initState() {
    super.initState();
    final appViewModel = context.read<AppViewmodel>();
    baseUrlController.value = TextEditingValue(text: appViewModel.baseUrl);
  }

  @override
  void dispose() {
    baseUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Container(
              margin: EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: TextField(
                controller: baseUrlController,
                decoration: InputDecoration(
                  icon: Icon(Icons.cloud),
                  labelText: "Base URL",
                  helperText: "Ollama server API base URL",
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: TextButton.icon(
                onPressed: save,
                label: Text('Save'),
                icon: Icon(Icons.save),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void save() {
    final appViewModel = context.read<AppViewmodel>();
    appViewModel.setBaseUrl(baseUrlController.text);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Settings saved.")));
  }
}
