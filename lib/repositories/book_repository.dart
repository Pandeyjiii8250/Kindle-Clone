import 'dart:io';

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/book.dart';
import '../models/highlight.dart';
import '../models/thought.dart';

class BookRepository {
  BookRepository._();

  static final BookRepository instance = BookRepository._();

  Future<Isar>? _db;

  /// Returns the open Isar instance. Initializes it if necessary.
  Future<Isar> get _isar async {
    _db ??= _initDb();
    return _db!;
  }

  Future<Isar> _initDb() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    return Isar.open([
      BookSchema,
      HighlightSchema,
      ThoughtSchema,
    ], directory: dir.path);
  }

  /// Fetch all books stored in the database.
  Future<List<Book>> getAllBooks() async {
    final isar = await _isar;
    return isar.books.where().findAll();
  }

  /// Persist a new [book] to the database.
  Future<void> addBook(Book book) async {
    final isar = await _isar;
    await isar.writeTxn(() async {
      await isar.books.put(book);
    });
  }

  /// Persist a new highlight annotation for the given [book].
  Future<void> addHighlight(Book book, Highlight highlight) async {
    final isar = await _isar;
    await isar.writeTxn(() async {
      highlight.book.value = book;
      await isar.highlights.put(highlight);
      await highlight.book.save();
      book.highlights.add(highlight);
      await book.highlights.save();
    });
  }

  /// Get highlight annotations associated with [book].
  Future<List<Highlight>> getHighlights(Book book) async {
    final isar = await _isar;
    if (book.id == null) return [];
    return isar.highlights
        .filter()
        .book((q) => q.idEqualTo(book.id!))
        .findAll();
  }
}
