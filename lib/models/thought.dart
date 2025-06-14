// thought.dart
import 'package:isar/isar.dart';
import 'book.dart';

part 'thought.g.dart';

@Collection()
class Thought {
  Id? id;

  final book = IsarLink<Book>();

  // Where in the book this thought refers to
  late int pageNumber;

  // Any number of user ideas or reflections
  List<String> ideas = [];
}
