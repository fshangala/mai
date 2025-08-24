import 'package:flutter/material.dart';
import 'package:mai/view_models/app_viewmodel.dart';
import 'package:mai/view_models/chat_viewmodel.dart';
import 'package:mai/views/chat_view.dart';
import 'package:mai/views/home_view.dart';
import 'package:mai/views/settings_view.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppViewmodel()),
        ChangeNotifierProvider(
          create:
              (context) =>
                  ChatViewmodel(appViewmodel: context.read<AppViewmodel>()),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.deepOrange,
      brightness: Brightness.dark,
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        appBarTheme: AppBarTheme(backgroundColor: colorScheme.inversePrimary),
      ),
      initialRoute: "/",
      routes: {
        "/": (context) => MyHomePage(),
        "/chat": (context) => ChatView(),
        "/settings": (context) => SettingsView(),
      },
    );
  }
}
