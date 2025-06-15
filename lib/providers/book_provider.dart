import 'package:flutter/foundation.dart';

import '../models/book.dart';
import '../repositories/book_repository.dart';

class BookProvider extends ChangeNotifier {
  BookProvider();

  final BookRepository _repository = BookRepository.instance;

  List<Book> _books = [];
  List<Book> get books => List.unmodifiable(_books);

  /// Load books from the repository into memory.
  Future<void> loadBooks() async {
    _books = await _repository.getAllBooks();
    notifyListeners();
  }

  /// Add [book] to the repository and local cache.
  Future<void> addBook(Book book) async {
    await _repository.addBook(book);
    _books.add(book);
    notifyListeners();
  }
}
