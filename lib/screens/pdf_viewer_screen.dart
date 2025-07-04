import 'package:flutter/material.dart';
import 'package:kindle_clone_v2/models/book.dart';
import 'package:kindle_clone_v2/models/highlight.dart';
import 'package:kindle_clone_v2/repositories/book_repository.dart';
import 'package:provider/provider.dart';
import 'package:kindle_clone_v2/screens/read_notes_page.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:flutter/services.dart';
import 'package:kindle_clone_v2/providers/book_provider.dart';

class PDFViewerScreen extends StatefulWidget {
  final Book bookDetail; // Can also be a URL
  final int? initialPage;

  const PDFViewerScreen({
    super.key,
    required this.bookDetail,
    this.initialPage,
  });

  @override
  _PDFViewerScreenState createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  String _currentSelection = '';
  final PdfViewerController _controller = PdfViewerController();
  final BookRepository _repository = BookRepository.instance;
  List<Highlight> _highlights = [];
  List<PdfTextRanges> _selectedRanges = [];

  @override
  void initState() {
    super.initState();
    _loadHighlights();
    widget.bookDetail.lastRead = DateTime.now();
    context.read<BookProvider>().updateBook(widget.bookDetail);
  }

  Future<void> _loadHighlights() async {
    if (widget.bookDetail.id != null) {
      final items = await _repository.getHighlightsForBook(widget.bookDetail);
      setState(() {
        _highlights = items;
      });
    }
  }

  Future<void> _addHighlight(int pageNumber, List<HighlightArea> rects) async {
    final highlight =
        Highlight()
          ..pageNumber = pageNumber
          ..highlightText = _currentSelection
          ..color = '#FFFF00'
          ..timestamp = DateTime.now()
          ..rects = rects;
    await _repository.addHighlight(widget.bookDetail, highlight);
    setState(() {
      _highlights.add(highlight);
    });
  }

  void _onHighlightTap(Highlight highlight) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.copy),
                  title: const Text('Copy'),
                  onTap: () => Navigator.pop(context, 'copy'),
                ),
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Remove'),
                  onTap: () => Navigator.pop(context, 'remove'),
                ),
                ListTile(
                  leading: const Icon(Icons.add_comment),
                  title: const Text('Add Comment'),
                  onTap: () => Navigator.pop(context, 'add'),
                ),
                ListTile(
                  leading: const Icon(Icons.notes),
                  title: const Text('Read Comment'),
                  onTap: () => Navigator.pop(context, 'read'),
                ),
              ],
            ),
          ),
    );
    if (result == 'copy') {
      await Clipboard.setData(ClipboardData(text: highlight.highlightText));
    } else if (result == 'remove') {
      await _repository.deleteHighlight(highlight);
      setState(() {
        _highlights.removeWhere((h) => h.id == highlight.id);
      });
    } else if (result == 'add') {
      final controller = TextEditingController();
      final note = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        builder: (ctx) {
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: controller,
                  autofocus: true,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: 'Add your notes here...',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () =>
                          Navigator.pop(ctx, controller.text.trim()),
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
      if (note != null && note.isNotEmpty) {
        highlight.notes = [...highlight.notes, note];
        await _repository.updateHighlight(highlight);
        setState(() {});
      }
    } else if (result == 'read') {
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReadNotesPage(highlight: highlight),
          ),
        );
      }
    }
  }

  Widget _contextMenuBuilder(
    BuildContext context,
    SelectableRegionState selectableRegionState,
    PdfPage page,
    Rect pageRect,
  ) {
    final List<ContextMenuButtonItem> items = [
      ...selectableRegionState.contextMenuButtonItems,
      ContextMenuButtonItem(
        label: 'Highlight',
        onPressed: () {
          debugPrint('Highlighted text: $_currentSelection');
          List<HighlightArea> rects = [];
          for (var range in _selectedRanges) {
            final singleRect = range.bounds.toRect(
              page: page,
              scaledPageSize: pageRect.size,
            );
            rects.add(
              HighlightArea()
                ..left = singleRect.left / pageRect.width
                ..top = singleRect.top / pageRect.height
                ..width = singleRect.width / pageRect.width
                ..height = singleRect.height / pageRect.height,
            );
          }
          _addHighlight(page.pageNumber, rects);
          selectableRegionState.hideToolbar();
          selectableRegionState.clearSelection();
        },
      ),
    ];

    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: selectableRegionState.contextMenuAnchors,
      buttonItems: items,
    );
  }

  void _onTextSelectionChange(List<PdfTextRanges> selections) {
    setState(() {
      _selectedRanges = selections;
    });

    if (selections.isEmpty) {
      _currentSelection = '';
    } else {
      final buffer = StringBuffer();
      for (final range in selections) {
        debugPrint('Selected on page ${range.pageNumber}: ${range.text}');
        buffer.write(range.text);
      }
      _currentSelection = buffer.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.bookDetail.title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: PdfViewer.file(
        controller: _controller,
        widget.bookDetail.filePath,
        initialPageNumber: widget.initialPage ?? 1,
        params: PdfViewerParams(
          enableTextSelection: true,
          perPageSelectableRegionInjector: (context, child, page, pageRect) {
            return Stack(
              children: [
                SelectionArea(
                  contextMenuBuilder:
                      (context, selectableRegionState) => _contextMenuBuilder(
                        context,
                        selectableRegionState,
                        page,
                        pageRect,
                      ),
                  child: child,
                ),
                ..._highlights
                    .where((h) => h.pageNumber == page.pageNumber)
                    .expand(
                      (h) => h.rects.map(
                        (r) => Positioned.fromRect(
                          rect: Rect.fromLTWH(
                            r.left * pageRect.width,
                            r.top * pageRect.height,
                            r.width * pageRect.width,
                            r.height * pageRect.height,
                          ),
                          child: GestureDetector(
                            onTap: () => _onHighlightTap(h),
                            child: Container(
                              color: Colors.yellow.withOpacity(0.4),
                            ),
                          ),
                        ),
                      ),
                    ),
              ],
            );
          },
          onTextSelectionChange: _onTextSelectionChange,
          onPageChanged: (page) async {
            if (page != null) {
              if (page > widget.bookDetail.lastPageRead) {
                widget.bookDetail.lastPageRead = page;
                //This should update ttl page once foe each book...
                if (widget.bookDetail.ttlPage != _controller.pageCount) {
                  widget.bookDetail.ttlPage = _controller.pageCount;
                }
                context.read<BookProvider>().updateBook(widget.bookDetail);
              }
            }
          },
        ),
      ),
    );
  }
}
