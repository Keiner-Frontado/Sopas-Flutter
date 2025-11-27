import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/game/board.dart';

class BoardPainter extends CustomPainter {
  
  Board board;

  BoardPainter({required this.board});

  @override
  void paint(Canvas canvas, Size size) {
    // Aquí va la lógica para pintar el tablero
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    double cellWidth = size.width / board.col;
    double cellHeight = size.height / board.row;

    // Dibuja un rectángulo azul que cubre todo el canvas
    canvas.drawRect(
      Rect.fromLTWH(
        0, 0,
        size.width, size.height),
        paint
    );

    for (final cell in board.board.expand((e) => e)) {
      final cellPaint = Paint()
        ..color = cell.isSelected ? Colors.yellow : Colors.white
        ..style = PaintingStyle.fill;

      double left = cell.col * cellWidth;
      double top = cell.row * cellHeight;

      // Dibuja cada celda
      canvas.drawRect(
        Rect.fromLTWH(
          left, top,
          cellWidth, cellHeight),
          cellPaint
      );

      // Dibuja la letra de la celda
      final textPainter = TextPainter(
        text: TextSpan(
          text: cell.letter,
          style: TextStyle(
            color: Colors.black,
            fontSize: cellHeight * 0.6,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          left + (cellWidth - textPainter.width) / 2,
          top + (cellHeight - textPainter.height) / 2,
        ),
      );
    }


    
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}