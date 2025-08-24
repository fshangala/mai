import 'package:flutter/material.dart';
import 'package:mai/views/home_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(seedColor: Colors.deepOrange);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme,
        appBarTheme: AppBarTheme(backgroundColor: colorScheme.inversePrimary),
      ),
      initialRoute: "/",
      routes: {"/": (context) => MyHomePage()},
    );
  }
}
