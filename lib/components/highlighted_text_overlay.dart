import 'package:flutter/material.dart';
import 'package:kindle_clone_v2/models/highlight.dart';

class HighlightedTextOverlay extends StatelessWidget {
  final Highlight highlight;
  final Rect pageRect;
  final HighlightArea area;
  final void Function(Highlight) onHighlightTap;

  const HighlightedTextOverlay({
    super.key,
    required this.pageRect,
    required this.area,
    required this.onHighlightTap,
    required this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    print(area.height);
    return Stack(
      children: [
        Positioned.fromRect(
          rect: Rect.fromLTWH(
            area.left * pageRect.width,
            area.top * pageRect.height,
            area.width * pageRect.width,
            area.height * pageRect.height,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.yellow,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        Positioned(
          left: area.left * pageRect.width,
          top: area.top * pageRect.height,
          child: GestureDetector(
            onTap: () => onHighlightTap(highlight),
            child: Material(
              color: Colors.transparent,
              child: Text(
                area.text,
                style: TextStyle(
                  color: Colors.black,
                  backgroundColor: Colors.yellow,
                  fontSize: area.height*400,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
