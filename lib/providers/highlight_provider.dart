import 'package:flutter/foundation.dart';

import '../models/book.dart';
import '../models/highlight.dart';
import '../repositories/book_repository.dart';

class HighlightProvider extends ChangeNotifier {
  final BookRepository _repository = BookRepository.instance;

  final Map<int, List<Highlight>> _byBook = {};

  List<Highlight> highlightsFor(Book book) {
    final id = book.id;
    if (id == null) return const [];
    return List.unmodifiable(_byBook[id] ?? []);
  }

  Future<void> loadHighlights(Book book) async {
    final id = book.id;
    if (id == null) return;
    final items = await _repository.getHighlightsForBook(book);
    _byBook[id] = items;
    notifyListeners();
  }

  Future<void> addHighlight(Book book, Highlight highlight) async {
    await _repository.addHighlight(book, highlight);
    final id = book.id;
    if (id != null) {
      final list = _byBook.putIfAbsent(id, () => []);
      list.add(highlight);
      notifyListeners();
    }
  }

  Future<void> updateHighlight(Book book, Highlight highlight) async {
    await _repository.updateHighlight(highlight);
    final id = book.id;
    if (id != null) {
      final list = _byBook[id];
      if (list != null) {
        final index = list.indexWhere((h) => h.id == highlight.id);
        if (index != -1) {
          list[index] = highlight;
          notifyListeners();
        }
      }
    }
  }

  Future<void> deleteHighlight(Book book, Highlight highlight) async {
    await _repository.deleteHighlight(highlight);
    final id = book.id;
    if (id != null) {
      final list = _byBook[id];
      if (list != null) {
        list.removeWhere((h) => h.id == highlight.id);
        notifyListeners();
      }
    }
  }
}
