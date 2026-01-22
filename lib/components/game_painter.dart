import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/logic/game.dart';

class GamePainter extends CustomPainter {
  final Game game;

  GamePainter({required this.game}) : super(repaint: game);

  Size? lastSize;


  @override
  void paint(Canvas canvas, Size size) {
    lastSize = size;
    final board = game.board;
    if (board.selectedCells.isEmpty) return;

    final cellW = size.width / board.col;
    final cellH = size.height / board.row;

    final points = board.selectedCells
      .map((cell) => Offset(cell.col * cellW + cellW / 2, cell.row * cellH + cellH / 2))
      .toList();

    if (points.length > 1) {
      final linePaint = Paint()
        ..color = Colors.blueAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.bevel;

      final path = Path();
      path.moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}