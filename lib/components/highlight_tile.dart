import 'package:flutter/material.dart';

import '../models/highlight.dart';

class HighlightTile extends StatefulWidget {
  final Highlight highlight;
  final VoidCallback onOpen;

  const HighlightTile({super.key, required this.highlight, required this.onOpen});

  @override
  State<HighlightTile> createState() => _HighlightTileState();
}

class _HighlightTileState extends State<HighlightTile> {
  bool _expanded = false;

  String _transformHighlight(String text) {
    return text.replaceAll('\r', '').replaceAll('\n', ' ');
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.highlight;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            crossAxisAlignment:
                _expanded
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: widget.onOpen,
                  child: Text(
                    _transformHighlight(h.highlightText),
                    textAlign: TextAlign.justify,
                    maxLines: _expanded ? null : 1,
                    overflow:
                        _expanded
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                icon: Icon(
                  size: 30,
                  _expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
                onPressed: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Page ${h.pageNumber}',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
        if (_expanded && h.notes.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  h.notes
                      .map(
                        (n) => Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // const Text('\u2022 '),
                            Expanded(
                              child: Text(
                                n,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.black54),
                                textAlign: TextAlign.justify,
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
            ),
          ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Divider(height: 1, thickness: 0.5),
        ),
      ],
    );
  }
}
