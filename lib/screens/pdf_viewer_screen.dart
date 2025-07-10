import 'package:flutter/material.dart';
import 'package:kindle_clone_v2/models/book.dart';
import 'package:kindle_clone_v2/models/highlight.dart';
import 'package:kindle_clone_v2/providers/highlight_provider.dart';
import 'package:kindle_clone_v2/utils/pdf_viewer_helper.dart';
import 'package:provider/provider.dart';
import 'package:kindle_clone_v2/screens/read_notes_page.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:flutter/services.dart';
import 'package:kindle_clone_v2/providers/book_provider.dart';

import '../components/highlighted_text_overlay.dart';

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
  List<PdfTextRanges> _selectedRanges = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HighlightProvider>().loadHighlights(widget.bookDetail);
    });
    widget.bookDetail.lastRead = DateTime.now();
    context.read<BookProvider>().updateBook(widget.bookDetail);
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
        onPressed:
            () =>
                _onHighlightButtonPress(page, pageRect, selectableRegionState),
      ),
    ];

    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: selectableRegionState.contextMenuAnchors,
      buttonItems: items,
    );
  }

  void _onHighlightButtonPress(
    PdfPage page,
    Rect pageRect,
    SelectableRegionState selectableRegionState,
  ) {
    debugPrint('Highlighted text: $_currentSelection');

    List<HighlightArea> rects = [];

    for (var pdfTextRanges in _selectedRanges) {
      for (var range in pdfTextRanges.ranges) {
        final match = range.toTextRangeWithFragments(pdfTextRanges.pageText);
        if (match != null) {
          for (final fragment in match.fragments) {
            final rect = fragment.bounds.toRect(
              page: page,
              scaledPageSize: pageRect.size,
            );

            rects.add(
              HighlightArea()
                ..left = rect.left / pageRect.width
                ..top = rect.top / pageRect.height
                ..width = rect.width / pageRect.width
                ..height = rect.height / pageRect.height
                ..text = fragment.text,
            );
          }
        }
      }
    }

    _addHighlight(page.pageNumber, rects);
    selectableRegionState.hideToolbar();
    selectableRegionState.clearSelection();
  }

  Future<void> _addHighlight(int pageNumber, List<HighlightArea> rects) async {
    final highlight =
        Highlight()
          ..pageNumber = pageNumber
          ..highlightText = _currentSelection
          ..color = '#FFFF00'
          ..timestamp = DateTime.now()
          ..rects = rects;

    await context.read<HighlightProvider>().addHighlight(
      widget.bookDetail,
      highlight,
    );
  }

  void _onTextSelectionChange(List<PdfTextRanges> selections) {
    final buffer = StringBuffer();
    // if selections empty than selected text is empty
    for (final range in selections) {
      debugPrint('Selected on page ${range.pageNumber}: ${range.text}');
      buffer.write(range.text);
    }

    setState(() {
      _selectedRanges = selections;
      _currentSelection = buffer.toString();
    });
  }

  void _onPageChange(int? page) {
    if (page != null && page > widget.bookDetail.lastPageRead) {
      widget.bookDetail.lastPageRead = page;
      //This should update ttl page once foe each book...
      if (widget.bookDetail.ttlPage != _controller.pageCount) {
        widget.bookDetail.ttlPage = _controller.pageCount;
      }
      context.read<BookProvider>().updateBook(widget.bookDetail);
    }
  }

  void _onHighlightTap(Highlight highlight) async {
    final result = await PdfViewerHelper.showHighlightedTextOptions(context);
    switch (result) {
      case 'copy':
        await Clipboard.setData(ClipboardData(text: highlight.highlightText));
        break;

      case 'remove':
        await context.read<HighlightProvider>().deleteHighlight(
          widget.bookDetail,
          highlight,
        );
        break;

      case 'read':
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReadNotesPage(highlight: highlight),
            ),
          );
        }
        break;

      case 'add':
        final note = await PdfViewerHelper.showNotesInput(context);
        if (note != null && note.isNotEmpty) {
          highlight.notes = [...highlight.notes, note];
          await context.read<HighlightProvider>().updateHighlight(
            widget.bookDetail,
            highlight,
          );
        }
        break;

      default:
        debugPrint('Unknown option: $result');
        break;
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
                ...context
                    .watch<HighlightProvider>()
                    .highlightsFor(widget.bookDetail)
                    .where((h) => h.pageNumber == page.pageNumber)
                    .expand(
                      (h) => h.rects.map(
                        (r) => HighlightedTextOverlay(
                          highlight: h,
                          pageRect: pageRect,
                          area: r,
                          onHighlightTap: _onHighlightTap,
                        ),
                      ),
                    ),
              ],
            );
          },
          onTextSelectionChange: _onTextSelectionChange,
          onPageChanged: _onPageChange,
        ),
      ),
    );
  }
}
