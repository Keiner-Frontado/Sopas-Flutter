import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/logic/gesture_controller.dart';
import 'package:flutter_application_1/core/logic/game.dart';
import 'package:flutter_application_1/components/board_painter.dart';
import 'package:flutter_application_1/components/game_painter.dart';

class BoardCanva extends StatefulWidget {
  final Game game;
  final ValueChanged< Map<String, dynamic> > handler;
  /// When false, all user interaction is ignored (used for turn enforcement).
  final bool allowInteraction;
  const BoardCanva({
    super.key,
    required this.game,
    required this.handler,
    this.allowInteraction = true,
  });

  @override
  State<BoardCanva> createState() => _BoardState();
}

class _BoardState extends State<BoardCanva> {
  late final BoardPainter painter;
  late final GamePainter gamePainter;
  Size? lastSize;

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
    if (!widget.allowInteraction) return;
    final position = onPanStart(e, widget.game.board, lastSize);
    // ignore: avoid_print
    if (position.length == 2){
      widget.game.board.selectCell(position[0], position[1]);
      widget.game.notify();
      _notify({'type': 'select_cell', 'content' : position});
    }
  }

  void _handlePanUpdate(DragUpdateDetails e) {
    if (!widget.allowInteraction) return;
    final position = onPanUpdate(e, widget.game.board, lastSize);
    
    if (position.length == 2){
      widget.game.board.selectCell(position[0], position[1]);
      widget.game.notify();
      _notify({'type': 'select_cell', 'content' : position});
    }
  }

  void _handlePanEnd(DragEndDetails e) {
    if (!widget.allowInteraction) return;
    bool wordFound = false;
    try{
      wordFound = widget.game.board.foundWord(widget.game.currentPlayer.id);
    }catch (e){
      // ignore: avoid_print
      print('$e');
    }
    if (wordFound) {
      _notify({'type': 'found_word', 'finderId': widget.game.currentPlayer.id});
      // auto finish turn after a successful word
      // update local state immediately (host / same device)
      widget.game.finishTurn();
      _notify({'type': 'finish_turn'});
    } else {
      widget.game.board.deselectCells();
      _notify({'type': 'deselect_cells'});
    }
    widget.game.notify();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        lastSize = Size(constraints.maxWidth, constraints.maxHeight);
        return SizedBox.expand(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanStart: _handlePanStart,
            onPanUpdate: _handlePanUpdate,
            onPanEnd: _handlePanEnd,
            child: CustomPaint(
              painter: painter,
              foregroundPainter: gamePainter,
            ),
          ),
        );
      },
    );
  }
}