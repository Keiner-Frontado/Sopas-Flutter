import 'package:flutter/material.dart';

class GamePainter extends CustomPainter {
  final List<dynamic> gameData;
  const GamePainter({
    this.gameData = const [],
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Aquí va la lógica para pintar el juego sobre el tablero
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke;


    // Dibuja un círculo rojo en el centro del canvas
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      (size.width > size.height ? size.height : size.width)/2.2,
      paint
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

}