import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart' as freehand;

class FreehandCanvas extends StatefulWidget {
  const FreehandCanvas({
    super.key,
    this.height,
    this.background,
    this.showToolbar = true,
    this.hintText,
  });

  final double? height;
  final Widget? background;
  final bool showToolbar;
  final String? hintText;

  @override
  State<FreehandCanvas> createState() => _FreehandCanvasState();
}

class _FreehandCanvasState extends State<FreehandCanvas> {
  final _strokes = <List<freehand.PointVector>>[];
  List<freehand.PointVector> _currentStroke = [];

  void _startStroke(Offset position) {
    setState(() {
      _currentStroke = [freehand.PointVector.fromOffset(offset: position)];
      _strokes.add(_currentStroke);
    });
  }

  void _extendStroke(Offset position) {
    if (_currentStroke.isEmpty) {
      _startStroke(position);
      return;
    }
    setState(() {
      _currentStroke.add(freehand.PointVector.fromOffset(offset: position));
    });
  }

  void _endStroke() {
    setState(() {
      _currentStroke = [];
    });
  }

  void _clear() {
    setState(() {
      _strokes.clear();
      _currentStroke = [];
    });
  }

  void _undo() {
    if (_strokes.isEmpty) return;
    setState(() {
      _strokes.removeLast();
      _currentStroke = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final cardRadius = BorderRadius.circular(18);

    final canvas = LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onPanStart: (details) => _startStroke(details.localPosition),
          onPanUpdate: (details) => _extendStroke(details.localPosition),
          onPanEnd: (_) => _endStroke(),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: cardRadius,
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: ClipRRect(
              borderRadius: cardRadius,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (widget.background != null)
                    ColoredBox(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceVariant
                          .withOpacity(0.45),
                      child: widget.background,
                    ),
                  CustomPaint(
                    painter: _FreehandPainter(strokes: _strokes),
                    child: Container(
                      color: widget.background == null
                          ? Theme.of(context).colorScheme.surface
                          : Colors.transparent,
                    ),
                  ),
                  if (widget.hintText != null && _strokes.isEmpty)
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          widget.hintText!,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showToolbar)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                FilledButton.tonalIcon(
                  onPressed: _undo,
                  icon: const Icon(Icons.undo),
                  label: const Text('되돌리기'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _clear,
                  icon: const Icon(Icons.delete_sweep),
                  label: const Text('모두 지우기'),
                ),
                const Spacer(),
                Icon(
                  Icons.gesture,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        SizedBox(
          height: widget.height ?? 320,
          child: canvas,
        ),
      ],
    );
  }
}

class _FreehandPainter extends CustomPainter {
  _FreehandPainter({required this.strokes});

  final List<List<freehand.PointVector>> strokes;
  static final _options = freehand.StrokeOptions(
    size: 8,
    thinning: 0.7,
    smoothing: 0.6,
    streamline: 0.5,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final baseColor = const Color(0xFF1A1A1A);
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = baseColor.withOpacity(0.9);
    for (final stroke in strokes) {
      final outline = freehand.getStroke(stroke, options: _options);
      if (outline.isEmpty) continue;
      final path = Path()..addPolygon(outline, true);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FreehandPainter oldDelegate) => true;
}
