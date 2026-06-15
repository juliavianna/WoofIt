import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() => runApp(const WoofItApp());

class WoofItApp extends StatelessWidget {
  const WoofItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WoofIt Cliente',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}