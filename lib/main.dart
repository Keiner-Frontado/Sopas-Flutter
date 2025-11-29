import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/layout.dart';
import 'package:flutter_application_1/core/constants/styles.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "App",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: Layout(),
      
    );
  }
}
