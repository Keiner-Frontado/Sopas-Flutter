
import 'package:flutter_application_1/core/game/board.dart';
import 'package:flutter_application_1/core/game/player.dart';
import 'package:flutter_application_1/core/game/word_search_themes.dart';

class Game {

  Player p1,p2;
  late Board board;
  late Player currentPlayer;

  Game(this.p1, this.p2, int size) {

    
    board = Board(
    row: size > 7 ? size : 7,
    col: size > 7 ? size : 7,
    theme: Themes.selectTheme()
    );

    startGame();

  }

  void finishTurn(){
    board.deselectCells();
    currentPlayer.finishTurn();
    currentPlayer = currentPlayer == p1 ? p2 : p1;
  }

  void startGame() {
    currentPlayer = p1;
    
  }

}