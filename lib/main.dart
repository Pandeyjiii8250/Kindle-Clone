import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'book_library_page.dart';
import 'providers/book_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => BookProvider(),
      child: const MainApp(),
    ),
  );
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
