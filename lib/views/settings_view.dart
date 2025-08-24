import 'package:flutter/material.dart';

class SettingsView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SettingsViewState();
}

class SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('Settings')));
  }
}
