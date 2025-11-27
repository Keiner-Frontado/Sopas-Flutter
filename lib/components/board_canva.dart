import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/game/board.dart';
import 'package:flutter_application_1/core/painter/board_painter.dart';
import 'package:flutter_application_1/core/painter/game_painter.dart';

class BoardCanva extends StatefulWidget {
  final Board board;
  const BoardCanva({super.key, required this.board});

  @override
  State<BoardCanva> createState() => _BoardState();
}

class _BoardState extends State<BoardCanva> {
  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.95,
      heightFactor: 0.95,
      child: AbsorbPointer(
        absorbing: true,
        child: GestureDetector(
          child: CustomPaint(
            painter: BoardPainter(board: widget.board),
            foregroundPainter: GamePainter(),
          ),
        )
      )
    );

  }
}