import 'package:flutter/material.dart';
import 'package:mai/view_models/app_viewmodel.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool loading = false;

  @override
  void initState() {
    loadModels();
    super.initState();
  }

  Future<void> loadModels() async {
    setState(() {
      loading = true;
    });
    await context.read<AppViewmodel>().fetchModels();
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appViewmodel = context.watch<AppViewmodel>();

    return Scaffold(
      appBar: AppBar(
        title: Text("Mai"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, "/settings");
            },
            icon: Icon(Icons.settings),
          ),
          if (loading) CircularProgressIndicator(),
        ],
      ),
      body: RefreshIndicator(
        child: ListView.builder(
          itemCount: appViewmodel.models.length,
          itemBuilder: (context, indiex) {
            return Container(
              margin: EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(appViewmodel.models[indiex].model ?? ""),
                onTap: () {
                  appViewmodel.setModel(appViewmodel.models[indiex]);
                  Navigator.pushNamed(context, "/chat");
                },
              ),
            );
          },
        ),
        onRefresh: () async {
          await appViewmodel.fetchModels();
        },
      ),
    );
  }
}
