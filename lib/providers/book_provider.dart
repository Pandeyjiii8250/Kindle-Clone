import 'package:flutter/foundation.dart';

import '../models/book.dart';
import '../repositories/book_repository.dart';

class BookProvider extends ChangeNotifier {
  BookProvider();

  final BookRepository _repository = BookRepository.instance;

  List<Book> _books = [];
  List<Book> get books => List.unmodifiable(_books);

  void _sortBooks() {
    _books.sort((a, b) {
      final aTime = a.lastRead ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.lastRead ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
  }

  /// Load books from the repository into memory.
  Future<void> loadBooks() async {
    _books = await _repository.getAllBooks();
    _sortBooks();
    notifyListeners();
  }

  /// Add [book] to the repository and local cache.
  Future<void> addBook(Book book) async {
    await _repository.addBook(book);
    _books.add(book);
    _sortBooks();
    notifyListeners();
  }

  /// Update [book] in the repository and local cache.
  Future<void> updateBook(Book book) async {
    await _repository.updateBook(book);
    final index = _books.indexWhere((b) => b.id == book.id);
    if (index != -1) {
      _books[index] = book;
    }
    _sortBooks();
    notifyListeners();
  }

  /// Delete [book] from the repository and local cache.
  Future<void> deleteBook(Book book) async {
    await _repository.deleteBook(book);
    _books.removeWhere((b) => b.id == book.id);
    notifyListeners();
  }
}
