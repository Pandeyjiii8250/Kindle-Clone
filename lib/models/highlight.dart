// highlight.dart
import 'package:isar/isar.dart';
import 'book.dart'; // If you want to reference the Book type directly

part 'highlight.g.dart';

@Collection()
class Highlight {
  Id? id;

  // Link back to the Book this highlight belongs to
  final book = IsarLink<Book>();

  late int pageNumber;
  late String highlightText;

  // Each highlight can have multiple notes
  List<String> notes = [];

  // E.g., "yellow", "#FFFF00", etc.
  late String color;

  // Track creation or modification time
  late DateTime timestamp;
}
