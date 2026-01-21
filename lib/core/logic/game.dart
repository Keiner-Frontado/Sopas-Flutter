
import 'package:flutter_application_1/core/constants/game_themes.dart';
import 'package:flutter_application_1/core/models/board.dart';
import 'package:flutter_application_1/core/models/player.dart';

class Game {

  late Player p1,p2;
  late Board board;
  late Player currentPlayer;

  Game(String mode, List<List<Cell>> board, Theme theme) {
    if (mode == 'single') {
      p1 = Player(id: 1, name: "Jugador 1", isAI: false);
      p2 = Player(id: 2, name: "IA", isAI: true);
    } else if (mode == 'server') {

      p1 = Player(id: 1, name: "Jugador 1", isAI: false);
      p2 = Player(id: 2, name: "Jugador 2", isAI: false);
    } else if (mode == 'client') {
      
      p1 = Player(id: 2, name: "Jugador 2", isAI: false);
      p2 = Player(id: 1, name: "Jugador 1", isAI: false);
    }

    this.board = Board(
      row: board.length,
      col: board[0].length,
      theme: theme,
      board: board
    );

    startGame();

  }

  void finishTurn(){
    board.deselectCells();
    currentPlayer = currentPlayer == p1 ? p2 : p1;
  }

  void startGame() {
    currentPlayer = p1;
  }

}