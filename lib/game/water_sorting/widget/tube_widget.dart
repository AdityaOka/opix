import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:opix/game/water_sorting/util/color_mapping.dart';
import 'package:opix/theme.dart';

/// Draws one tube of water, with an optional animated pour band on top.
class TubeWidget extends StatelessWidget {
  const TubeWidget({
    super.key,
    required this.colors,
    this.capacity = 4,
    this.width = 80,
    this.height = 260,
    this.staticCount,
    this.bandHeight = 0,
    this.bandColorId,
  });

  /// Color ids in the tube, from bottom to top.
  final List<int> colors;

  /// Max number of segments the tube can hold.
  final int capacity;

  /// Tube width in pixels.
  final double width;

  /// Tube height in pixels.
  final double height;

  /// How many segments to draw as the normal stack (bottom-up).
  /// Defaults to all of them. Lower this during a pour so the poured
  /// segments are hidden here and shown by [bandHeight] instead.
  final int? staticCount;

  /// Extra height of poured liquid drawn above the stack.
  /// Animate it up or down to show liquid moving between tubes.
  final double bandHeight;

  /// Color id of the pour band. Ignored when [bandHeight] is 0.
  final int? bandColorId;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _TubePainter(
          colors: colors,
          capacity: capacity,
          staticCount: staticCount ?? colors.length,
          bandHeight: bandHeight,
          bandColorId: bandColorId,
        ),
      ),
    );
  }
}

/// Paints the tube glass, lip, and liquid segments on a canvas.
class _TubePainter extends CustomPainter {
  _TubePainter({
    required this.colors,
    required this.capacity,
    required this.staticCount,
    required this.bandHeight,
    required this.bandColorId,
  });

  /// Color ids, bottom to top.
  final List<int> colors;

  /// Max number of segments the tube can hold.
  final int capacity;

  /// How many segments to draw as the normal stack.
  final int staticCount;

  /// Extra height of the pour band above the stack.
  final double bandHeight;

  /// Color id of the pour band.
  final int? bandColorId;

  /// Draws the tube: glass outline, lip, static liquid stack, and pour band.
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final double stroke = w * 0.045;
    final double pad = w * 0.08;

    final double left = pad;
    final double right = w - pad;
    final double bodyW = right - left;
    final double r = bodyW / 2;
    final double topR = bodyW * 0.10;
    final double lipH = bodyW * 0.13;
    final double lipOverhang = bodyW * 0.06;
    final double bodyTop = pad + lipH * 0.5;
    final double bottom = h - pad;

    // The glass: rounded top corners, rounded bottom, one closed path.
    final Path body = Path()
      ..moveTo(left, bodyTop + topR)
      ..quadraticBezierTo(left, bodyTop, left + topR, bodyTop)
      ..lineTo(right - topR, bodyTop)
      ..quadraticBezierTo(right, bodyTop, right, bodyTop + topR)
      ..lineTo(right, bottom - r)
      ..quadraticBezierTo(right, bottom, right - r, bottom)
      ..lineTo(left + r, bottom)
      ..quadraticBezierTo(left, bottom, left, bottom - r)
      ..close();

    canvas.save();
    canvas.clipPath(body);

    final double fillTop = bodyTop + lipH * 0.2;
    final double segment = (bottom - fillTop) / capacity;
    final int staticSegments = staticCount.clamp(0, capacity);
    final double totalLength = (staticSegments + bandHeight).clamp(
      0,
      capacity.toDouble(),
    );
    final double liquidTop = bottom - totalLength * segment;

    // Empty-glass tint, only above the liquid.
    if (liquidTop > bodyTop) {
      canvas.drawRect(
        Rect.fromLTRB(left, bodyTop, right, liquidTop),
        Paint()..color = Mocha.surface0.withValues(alpha: 0.5),
      );
    }

    // Liquid bands, bottom up. Slight overlap avoids a seam between colors.
    const double overlap = 0.5;
    for (int i = 0; i < staticSegments; i++) {
      final double segBottom = bottom - i * segment;
      final double segTop = segBottom - segment;
      canvas.drawRect(
        Rect.fromLTRB(left, segTop - overlap, right, segBottom + overlap),
        Paint()..color = colorForId(colors[i]),
      );
    }

    // The segment currently being poured in or out, drawn with a
    // continuous (non-integer) height so it grows/shrinks smoothly on top
    // of the static stack instead of snapping a whole segment at a time.
    if (bandHeight > 0 && bandColorId != null) {
      final double bandBottom = bottom - staticSegments * segment;
      final double bandTop = bandBottom - bandHeight * segment;
      canvas.drawRect(
        Rect.fromLTRB(left, bandTop - overlap, right, bandBottom + overlap),
        Paint()..color = colorForId(bandColorId!),
      );
    }

    canvas.restore();

    // Glass outline.
    canvas.drawPath(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeJoin = StrokeJoin.round
        ..color = Mocha.text.withValues(alpha: 0.6),
    );

    // The lip.
    final RRect lip = RRect.fromRectAndRadius(
      Rect.fromLTRB(left - lipOverhang, pad, right + lipOverhang, pad + lipH),
      Radius.circular(lipH / 2),
    );
    canvas.drawRRect(lip, Paint()..color = Mocha.text.withValues(alpha: 0.9));
  }

  /// Repaints only when something drawn on screen actually changed.
  @override
  bool shouldRepaint(_TubePainter old) =>
      old.capacity != capacity ||
      old.staticCount != staticCount ||
      old.bandHeight != bandHeight ||
      old.bandColorId != bandColorId ||
      !listEquals(old.colors, colors);
}
