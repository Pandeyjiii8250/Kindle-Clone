import 'dart:io';

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/book.dart';
import '../models/highlight.dart';
import '../models/thought.dart';
import '../models/book_annotation.dart';

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
      BookAnnotationSchema,
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

  /// Persist a new annotation for the given [book].
  Future<void> addAnnotation(Book book, BookAnnotation annotation) async {
    final isar = await _isar;
    await isar.writeTxn(() async {
      annotation.book.value = book;
      await isar.bookAnnotations.put(annotation);
      await annotation.book.save();
      book.annotations.add(annotation);
      await book.annotations.save();
    });
  }

  /// Get annotations associated with [book].
  Future<List<BookAnnotation>> getAnnotations(Book book) async {
    final isar = await _isar;
    if (book.id == null) return [];
    return isar.bookAnnotations
        .filter()
        .book((q) => q.idEqualTo(book.id!))
        .findAll();
  }
}
