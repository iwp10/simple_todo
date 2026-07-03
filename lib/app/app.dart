import 'package:flutter/material.dart';
import 'package:simple_todo/feature/splash/presentation/splash_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Simple Todo',
      home: SplashPage(),
    );
  }
}
