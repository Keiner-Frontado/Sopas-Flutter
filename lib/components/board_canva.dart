import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/logic/gesture_controller.dart';
import 'package:flutter_application_1/core/logic/game.dart';
import 'package:flutter_application_1/components/board_painter.dart';
import 'package:flutter_application_1/components/game_painter.dart';

class BoardCanva extends StatefulWidget {
  final Game game;
  final ValueChanged< Map<String, dynamic> > handler;
  const BoardCanva({super.key, required this.game, required this.handler});

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

  void _notify(data) {
  // enviar un mapa con la info que quieras
  widget.handler.call(data);

}

  void _handlePanStart(DragStartDetails e) {
    final position = onPanStart(e, widget.game.board, gamePainter.lastSize);
    // ignore: avoid_print
    if (position.length == 2){
      widget.game.board.selectCell(position[0], position[1]);
      widget.game.notify();
      _notify({'type': 'select_cell', 'content' : position});
    }
  }

  void _handlePanUpdate(DragUpdateDetails e) {
    final position = onPanUpdate(e, widget.game.board, gamePainter.lastSize);
    
    if (position.length == 2){
      widget.game.board.selectCell(position[0], position[1]);
      widget.game.notify();
      _notify({'type': 'select_cell', 'content' : position});
    }
  }

  void _handlePanEnd(DragEndDetails e) {
    try{
    widget.game.board.foundWord();
    }catch (e){
      // ignore: avoid_print
      print('$e');
    }
    widget.game.notify();
    _notify({'type': 'found_word'});
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