import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'book_library_page.dart';
import 'providers/book_provider.dart';
import 'providers/highlight_provider.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BookProvider()),
        ChangeNotifierProvider(create: (_) => HighlightProvider()),
      ],
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
      theme: AppTheme.theme,
      // Use BookLibraryPage as your home screen
      home: const BookLibraryPage(),
    );
  }
}
