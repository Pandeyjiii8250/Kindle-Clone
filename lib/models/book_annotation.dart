import 'package:isar/isar.dart';
import 'book.dart';

part 'book_annotation.g.dart';

@Collection()
class BookAnnotation {
  Id? id;

  final book = IsarLink<Book>();

  late int pageNumber;
  late String type;

  /// Serialized list of rectangle coordinates [left, top, width, height, ...]
  List<double> rects = [];

  String? content;
  String color = '#FFFF00';
  DateTime createdAt = DateTime.now();
}
