import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'book_row.dart';
import 'models/book.dart';

/// Represents a book/PDF item in the library.
class BookModel {
  final String coverTitle;
  final String title;
  final String author;
  final String? progressText;
  final double? progressValue;
  final String? highlightsNotes;
  final String? filePath; // If this book is loaded from a PDF file.

  BookModel({
    required this.coverTitle,
    required this.title,
    required this.author,
    this.progressText,
    this.progressValue,
    this.highlightsNotes,
    this.filePath,
  });
}

class BookLibraryPage extends StatefulWidget {
  const BookLibraryPage({super.key});

  @override
  State<BookLibraryPage> createState() => _BookLibraryPageState();
}

class _BookLibraryPageState extends State<BookLibraryPage> {

  // A list that contains both default books and newly uploaded PDFs
  final List<Book> _books = [
    Book()
      ..coverTitle = 'Pride\nCover'
      ..title = 'Pride and Prejudice'
      ..author = 'Jane Austen'
      ..progress = 0.4,
    Book()
      ..coverTitle = 'Moby\nCover'
      ..title = 'Moby-Dick'
      ..author = 'Herman Melville'
      ..progress = 0.33,
    Book()
      ..coverTitle = 'Gatsby\nCover'
      ..title = 'The Great Gatsby'
      ..author = 'F. Scott Fitzgerald'
      ..progress = 0.33,
    Book()
      ..coverTitle = 'Mock-\nCover'
      ..title = 'To Kill a Mockingbird'
      ..author = 'Harper Lee'
      ..progress = 0.33
  ];

  @override
  void initState() {
    super.initState();

    loadInitialBooks();
  }

  void loadInitialBooks() async {
    final Directory dir = await getApplicationDocumentsDirectory();

    final List<Book> pdfFiles = [];
    // List all files and filter by .pdf extension
    final List<FileSystemEntity> files = dir.listSync(recursive: true)
        .where((file) => file.path.toLowerCase().endsWith('.pdf'))
        .toList();

    for (final file in files) {
      final stat = await File(file.path).stat();

      pdfFiles.add(Book()
        ..coverTitle = file.uri.pathSegments.last
        ..title = file.uri.pathSegments.last
        ..author = "IDK"
        ..progress = 0.0
      );
    }

    setState(() {
      _books.addAll(pdfFiles);
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

        // Once saved, create a new BookModel for it
        final newBook = Book()
          ..coverTitle = 'PDF'
          ..title = fileName
          ..author = 'Uploaded PDF'
          ..filePath = newFilePath
          ..progress = 0.0;

        setState(() {
          _books.add(newBook);
          print('Book added: $newBook');
        });

        // Display a quick notification
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF saved at $newFilePath')),
        );
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
                  const Text(
                    'Book Library',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _pickAndSavePdf(),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Render the list of books, including newly added PDFs
              for (final book in _books) BookRow(book: book),
            ],
          ),
        ),
      ),
    );
  }
}
