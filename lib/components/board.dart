import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/painter/board_painter.dart';
import 'package:flutter_application_1/core/painter/game_painter.dart';

class Board extends StatefulWidget {
  const Board({super.key});

  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board> {
  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.9,
      heightFactor: 0.9,
      child: AbsorbPointer(
        absorbing: true,
        child: GestureDetector(
          child: CustomPaint(
            painter: BoardPainter(),
            foregroundPainter: GamePainter(),
          ),
        )
      )
    );

  }
}