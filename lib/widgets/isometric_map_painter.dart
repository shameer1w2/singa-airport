import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/models.dart';

class IsometricMapPainter extends CustomPainter {
  final bool isRouteActive;
  final double blockOpacity;
  final List<MapBlock> blocks;
  final List<Offset> routePoints;
  final String? selectedBlockId;

  const IsometricMapPainter({
    required this.isRouteActive,
    required this.blockOpacity,
    required this.blocks,
    required this.routePoints,
    this.selectedBlockId,
  });

  // ── Isometric projection ────────────────────────────────────────
  Offset _iso(double x, double y, double z) {
    return Offset((x - y) * 0.866, (x + y) * 0.5 - z);
  }

  // ── Darken a colour by [amount] ────────────────────────────────
  Color _darken(Color c, double amount) {
    final h = HSLColor.fromColor(c);
    return h.withLightness((h.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF12141C),
    );

    // Centre the view
    canvas.translate(
      (size.width / 2).floorToDouble(),
      (size.height / 2.8 + 60).floorToDouble(),
    );

    // ── Faint isometric grid ──────────────────────────────────────
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1;
    for (double i = -800; i <= 800; i += 40) {
      canvas.drawLine(_iso(i, -800, 0), _iso(i, 800, 0), gridPaint);
      canvas.drawLine(_iso(-800, i, 0), _iso(800, i, 0), gridPaint);
    }

    // ── Airplane silhouettes in background ───────────────────────
    _drawAirplanes(canvas);

    // (No pre-block floor shadow - it causes artifacts on building faces)

    // ── Route drawn at FLOOR (z=0) before blocks ──────────────────
    // Blocks will paint OVER the route — it only shows in corridor gaps
    if (isRouteActive && routePoints.isNotEmpty) {
      _drawRoute(canvas, routePoints);
    }

    // ── Blocks (painter's algorithm: back-to-front) ───────────────
    final sorted = List<MapBlock>.from(blocks)
      ..sort((a, b) => (a.x + a.y).compareTo(b.x + b.y));

    for (final block in sorted) {
      if (block.id == selectedBlockId) {
        _drawGlow(canvas, block);
      }
      _drawBlock(canvas, block);
    }

    // ── POI icons on top of every block ──────────────────────────
    for (final block in sorted) {
      _drawPoiIcon(canvas, block);
    }

    // ── "You are here" radar + oval ring (always on top) ─────────
    _drawLocationMarker(canvas);
  }

  void _drawRoute(Canvas canvas, List<Offset> pts) {
    final path = Path();
    // z=0: flat on the floor — blocks drawn after will cover it
    final s = _iso(pts.first.dx, pts.first.dy, 0);
    path.moveTo(s.dx, s.dy);
    for (int i = 1; i < pts.length; i++) {
      final p = _iso(pts[i].dx, pts[i].dy, 0);
      path.lineTo(p.dx, p.dy);
    }

    // Dark amber outline (wide) — gives 3D tube illusion
    canvas.drawPath(path, Paint()
      ..color = const Color(0xFFAD7B00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round);

    // Bright golden fill line on top
    canvas.drawPath(path, Paint()
      ..color = const Color(0xFFF4CE4F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round);

    // Start circle (origin — yellow ring will overlay this)
    final startPt = _iso(pts.first.dx, pts.first.dy, 0);
    canvas.drawCircle(startPt, 9, Paint()..color = const Color(0xFFAD7B00));
    canvas.drawCircle(startPt, 6, Paint()..color = const Color(0xFFF4CE4F));

    // End circle (destination marker)
    final endPt = _iso(pts.last.dx, pts.last.dy, 0);
    canvas.drawCircle(endPt, 12, Paint()..color = const Color(0xFFAD7B00));
    canvas.drawCircle(endPt, 8, Paint()..color = const Color(0xFFF4CE4F));
  }



  void _drawBlock(ui.Canvas canvas, MapBlock block) {
    bool isSelected = block.id == selectedBlockId;
    
    // If selected, use a bright yellow, otherwise use block's color
    final baseColor = isSelected 
        ? const Color(0xFFF4CE4F)
        : Color(int.parse(block.colorHex, radix: 16) | 0xFF000000);
        
    final color = blockOpacity < 1.0
        ? baseColor.withValues(alpha: blockOpacity)
        : baseColor;

    final x = block.x, y = block.y, w = block.width, h = block.height, e = block.elevation;

    final p100 = _iso(x + w, y, 0);
    final p010 = _iso(x, y + h, 0);
    final p110 = _iso(x + w, y + h, 0);
    final p001 = _iso(x, y, e);
    final p101 = _iso(x + w, y, e);
    final p011 = _iso(x, y + h, e);
    final p111 = _iso(x + w, y + h, e);

    if (e > 0) {
      // Right face
      canvas.drawPath(
        Path()..moveTo(p100.dx, p100.dy)..lineTo(p110.dx, p110.dy)..lineTo(p111.dx, p111.dy)..lineTo(p101.dx, p101.dy)..close(),
        Paint()..color = isSelected ? _darken(color, 0.05) : _darken(color, 0.08),
      );
      // Left face
      canvas.drawPath(
        Path()..moveTo(p010.dx, p010.dy)..lineTo(p110.dx, p110.dy)..lineTo(p111.dx, p111.dy)..lineTo(p011.dx, p011.dy)..close(),
        Paint()..color = isSelected ? _darken(color, 0.15) : _darken(color, 0.22),
      );
    }

    // Top face
    canvas.drawPath(
      Path()..moveTo(p001.dx, p001.dy)..lineTo(p101.dx, p101.dy)..lineTo(p111.dx, p111.dy)..lineTo(p011.dx, p011.dy)..close(),
      Paint()..color = color,
    );

    // Outline / Edge highlight
    if (isSelected) {
      final outlinePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      // Draw top edge white highlight
      canvas.drawPath(
        Path()..moveTo(p001.dx, p001.dy)..lineTo(p101.dx, p101.dy)..lineTo(p111.dx, p111.dy)..lineTo(p011.dx, p011.dy)..close(),
        outlinePaint,
      );
      
      // Draw vertical edge highlights
      final verticalPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawLine(p110, p111, verticalPaint);
      canvas.drawLine(p100, p101, verticalPaint);
      canvas.drawLine(p010, p011, verticalPaint);
    } else {
      // Normal edge highlight
      canvas.drawPath(
        Path()..moveTo(p001.dx, p001.dy)..lineTo(p101.dx, p101.dy)..lineTo(p111.dx, p111.dy)..lineTo(p011.dx, p011.dy)..close(),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.04)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5,
      );
    }
  }

  void _drawGlow(ui.Canvas canvas, MapBlock block) {
    final x = block.x, y = block.y, w = block.width, h = block.height;
    final centerFloor = _iso(x + w / 2, y + h / 2, 0);

    for (int i = 0; i < 4; i++) {
        final radius = (math.max(w, h) * 0.7) + (i * 20);
        final opacity = 0.4 - (i * 0.1);
        canvas.drawOval(
          Rect.fromCenter(
            center: centerFloor,
            width: radius * 2 * 0.866 * 2.2,
            height: radius * 1.5,
          ),
          Paint()
            ..color = const Color(0xFFF4CE4F).withValues(alpha: opacity)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25),
        );
    }
  }

  void _drawPoiIcon(Canvas canvas, MapBlock block) {
    final centerTop = _iso(
      block.x + block.width / 2,
      block.y + block.height / 2,
      block.elevation,
    );

    if (block.label.isNotEmpty) {
      // Draw label text on the isometric top face
      final tp = TextPainter(
        text: TextSpan(
          text: block.label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.80),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: block.width * 0.85);

      // Draw emoji icon above labels for specific types
      String? emoji;
      if (block.label.toLowerCase().contains('gate')) emoji = '🛫';
      if (block.label.toLowerCase().contains('atm')) emoji = '🏧';
      if (block.label.toLowerCase().contains('duty free')) emoji = '🛍️';

      if (emoji != null) {
        final emojiPainter = TextPainter(
          text: TextSpan(text: emoji, style: const TextStyle(fontSize: 16)),
          textDirection: TextDirection.ltr,
        )..layout();
        emojiPainter.paint(canvas, centerTop + Offset(-emojiPainter.width / 2, -tp.height - 18));
      }

      canvas.save();
      canvas.translate(centerTop.dx, centerTop.dy);
      // Skew text to sit flat on isometric top face
      final skew = Matrix4.identity()
        ..rotateZ(-math.pi / 6)
        ..multiply(Matrix4.diagonal3Values(1.0, 0.6, 1.0));
      canvas.transform(skew.storage);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    } else {
      // Unlabelled small blocks: purple POI dot
      canvas.drawCircle(centerTop, 7, Paint()..color = Colors.white.withValues(alpha: 0.10));
      canvas.drawCircle(centerTop, 5, Paint()..color = const Color(0xFF2A2B33));
      canvas.drawCircle(centerTop, 2, Paint()..color = Colors.purpleAccent.withValues(alpha: 0.7));
    }
  }

  void _drawLocationMarker(Canvas canvas) {
    final center = _iso(0, 0, 4);

    // Radar sweep – dark grey cone
    final sweepPath = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(center.dx - 30, center.dy - 60)
      ..lineTo(center.dx + 30, center.dy - 60)
      ..close();
    canvas.drawPath(
      sweepPath,
      Paint()
        ..shader = ui.Gradient.radial(
          center,
          70,
          [Colors.grey.withValues(alpha: 0.35), Colors.transparent],
        ),
    );

    // Yellow oval ring
    canvas.drawOval(
      Rect.fromCenter(center: center, width: 34, height: 17),
      Paint()
        ..color = const Color(0xFFF4CE4F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5,
    );
  }

  void _drawAirplanes(Canvas canvas) {
    // Draw simple airplane silhouettes using Path
    final planePaint = Paint()..color = Colors.blueGrey.withValues(alpha: 0.22);

    final positions = [
      const Offset(-300, -350),
      const Offset(100, -420),
      const Offset(350, -280),
      const Offset(-80, -480),
      const Offset(250, -500),
    ];

    for (final pos in positions) {
      final pt = _iso(pos.dx, pos.dy, 0);
      canvas.save();
      canvas.translate(pt.dx, pt.dy);
      canvas.rotate(math.pi / 8);
      canvas.scale(1.4);
      _drawAircraftShape(canvas, planePaint);
      canvas.restore();
    }
  }

  void _drawAircraftShape(Canvas canvas, Paint paint) {
    // Simple triangular aircraft silhouette
    final body = Path()
      ..moveTo(0, -20)
      ..lineTo(4, 0)
      ..lineTo(0, 6)
      ..lineTo(-4, 0)
      ..close();

    // Wings
    final wings = Path()
      ..moveTo(-20, 2)
      ..lineTo(20, 2)
      ..lineTo(4, 8)
      ..lineTo(-4, 8)
      ..close();

    // Tail
    final tail = Path()
      ..moveTo(-8, 6)
      ..lineTo(8, 6)
      ..lineTo(4, 14)
      ..lineTo(-4, 14)
      ..close();

    canvas.drawPath(body, paint);
    canvas.drawPath(wings, paint);
    canvas.drawPath(tail, paint);
  }

  @override
  bool shouldRepaint(covariant IsometricMapPainter old) =>
      old.isRouteActive != isRouteActive ||
      old.blockOpacity != blockOpacity ||
      old.blocks != blocks ||
      old.selectedBlockId != selectedBlockId ||
      old.routePoints != routePoints;
}
