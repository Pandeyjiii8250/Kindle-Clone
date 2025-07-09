import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'book_row.dart';
import 'models/book.dart';
import 'providers/book_provider.dart';

class BookLibraryPage extends StatefulWidget {
  const BookLibraryPage({super.key});

  @override
  State<BookLibraryPage> createState() => _BookLibraryPageState();
}

class _BookLibraryPageState extends State<BookLibraryPage> {
  @override
  void initState() {
    super.initState();
    // Load books from the database when the page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookProvider>().loadBooks();
    });
  }

  /// Picks a PDF, saves it internally, and adds it to the books list
  Future<void> _pickAndSavePdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    print('File picker result: $result');

    if (result != null && result.files.isNotEmpty) {
      final filePath = result.files.first.path;
      final fileName = result.files.first.name;

      if (filePath != null) {
        // Read the file from the path
        final fileBytes = await File(filePath).readAsBytes();

        // Obtain the app's documents directory
        final directory = await getApplicationDocumentsDirectory();
        print('Documents directory: ${directory.path}');

        final newFilePath = '${directory.path}/$fileName';
        final file = File(newFilePath);

        // Write file to the app's documents directory
        await file.writeAsBytes(fileBytes);

        // Once saved, create a new Book for it
        final newBook =
            Book()
              ..coverTitle = 'PDF'
              ..title = fileName
              ..author = 'Unknown'
              ..filePath = newFilePath
              ..lastRead = DateTime.now();

        await context.read<BookProvider>().addBook(newBook);
        print('Book added: $newBook');

        // Display a quick notification
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('PDF saved')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: "Book Library" + plus button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Library',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _pickAndSavePdf(),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Render the list of books from the provider
              Builder(
                builder: (context) {
                  final books = context.watch<BookProvider>().books;
                  return Column(
                    children: List.generate(
                      books.length,
                      (index) => BookRow(book: books[index]),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
