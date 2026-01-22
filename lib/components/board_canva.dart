import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/logic/gesture_controller.dart';
import 'package:flutter_application_1/core/logic/game.dart';
import 'package:flutter_application_1/components/board_painter.dart';
import 'package:flutter_application_1/components/game_painter.dart';

class BoardCanva extends StatefulWidget {
  final Game game;

  const BoardCanva({super.key, required this.game});

  @override
  State<BoardCanva> createState() => _BoardState();
}

class _BoardState extends State<BoardCanva> {
  late final BoardPainter painter;
  late final GamePainter gamePainter;

  @override
  void initState() {
    super.initState();
    painter = BoardPainter(game: widget.game);
    gamePainter = GamePainter(game: widget.game);
  }

  void _handlePanStart(DragStartDetails e) {
    onPanStart(e, widget.game, gamePainter.lastSize);
    widget.game.notify();
  }

  void _handlePanUpdate(DragUpdateDetails e) {
    onPanUpdate(e, widget.game, gamePainter.lastSize);
    widget.game.notify();
  }

  void _handlePanEnd(DragEndDetails e) {
    onPanEnd(e, widget.game);
    widget.game.notify();
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