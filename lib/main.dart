import 'package:flutter/material.dart';
import 'book_library_page.dart';
void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Book App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Use BookLibraryPage as your home screen
      home: const BookLibraryPage(),
    );
  }
}
