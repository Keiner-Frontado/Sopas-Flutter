import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/logic/gesture_controller.dart';
import 'package:flutter_application_1/core/models/board.dart';
import 'package:flutter_application_1/components/board_painter.dart';
import 'package:flutter_application_1/components/game_painter.dart';

class BoardCanva extends StatefulWidget {
  final Board board;

  const BoardCanva({super.key, required this.board});

  @override
  State<BoardCanva> createState() => _BoardState();
}

class _BoardState extends State<BoardCanva> {
  late final BoardPainter painter;
  late final GamePainter gamePainter;

  @override
  void initState() {
    super.initState();
    painter = BoardPainter(board: widget.board);
    gamePainter = GamePainter(board: widget.board);
  }

  void _handlePanStart(DragStartDetails e) {
    onPanStart(e, widget.board, gamePainter.lastSize);
    widget.board.notify();
  }

  void _handlePanUpdate(DragUpdateDetails e) {
    onPanUpdate(e, widget.board, gamePainter.lastSize);
    widget.board.notify();
  }

  void _handlePanEnd(DragEndDetails e) {
    onPanEnd(e, widget.board);
    widget.board.notify();
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.95,
      heightFactor: 0.95,
      child: GestureDetector(
        onPanStart: _handlePanStart,
        onPanUpdate: _handlePanUpdate,
        onPanEnd: _handlePanEnd,
        child: CustomPaint(
          painter: painter,
          foregroundPainter: gamePainter,
        ),
      ),
    );
  }
}