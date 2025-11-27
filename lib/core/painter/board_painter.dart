import 'package:flutter/material.dart';

class BoardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Aquí va la lógica para pintar el tablero
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    // Dibuja un rectángulo azul que cubre todo el canvas
    canvas.drawRect(
      Rect.fromLTWH(
        0, 0,
        size.width, size.height),
        paint
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}