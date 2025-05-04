import 'package:flutter/material.dart';
import 'splash_screen.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      // Remove scaffoldBackgroundColor to avoid conflicts
    ),
    home: SplashScreen(),
  ));
}