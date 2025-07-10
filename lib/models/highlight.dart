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

  /// Normalized rectangles representing the highlight positions on the page.
  /// Stored relative to the page size so highlights can be redrawn later.
  List<HighlightArea> rects = [];
}

@embedded
class HighlightArea {
  late double left;
  late double top;
  late double width;
  late double height;
  late String text;
}
