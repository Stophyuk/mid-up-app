import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart' as freehand;

class FreehandCanvas extends StatefulWidget {
  const FreehandCanvas({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: GestureDetector(
            onPanStart: (details) => _startStroke(details.localPosition),
            onPanUpdate: (details) => _extendStroke(details.localPosition),
            onPanEnd: (_) => _endStroke(),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CustomPaint(
                  painter: _FreehandPainter(strokes: _strokes),
                  child: Container(
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.tonal(
          onPressed: _clear,
          child: const Text('지우기'),
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
      ..color = baseColor.withValues(alpha: 0.9);
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
