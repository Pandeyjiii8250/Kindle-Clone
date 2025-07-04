// book.dart
import 'package:isar/isar.dart';
import 'highlight.dart';
import 'thought.dart';

part 'book.g.dart';

@Collection()
class Book {
  Id? id;

  @Index() // Example index on title
  late String title;

  late String coverTitle;
  late String author;

  late int lastPageRead;
  late int ttlPage;

  DateTime? lastRead;
  String filePath = '';

  // One-to-many relationships
  final highlights = IsarLinks<Highlight>();
  final thoughts = IsarLinks<Thought>();
}
