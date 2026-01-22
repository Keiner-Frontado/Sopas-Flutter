
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/core/constants/game_themes.dart';
import 'package:flutter_application_1/core/models/board.dart';
import 'package:flutter_application_1/core/models/player.dart';

class Game extends ChangeNotifier {

  late Player p1,p2;
  late Board board;
  late Player currentPlayer;

  Game({required Map data}) {
    if (data['players'] != null){
      p1 = Player.fromJson(data['players']['p1']);
      p2 = Player.fromJson(data['players']['p2']);
    } else {
      p1 = Player(id: 1,name: 'Jugador 1');
      p2 = Player(id: 2,name: 'Jugador 2');
    }
    if(data['board'] != null){ board = data['board']; } else {
      // Crear un nuevo tablero si no hay datos
      board = Board(
        row: data['size'] > 7 ? data['size'] : 7,
        col: data['size'] > 7 ? data['size'] : 7,
        theme: Themes.selectTheme()
      );
    }


    startGame();

  }

  /// Notify listeners (convenience wrapper)
  void notify() => notifyListeners();

  Map<String, dynamic> toJson() => {
    'players': {
      'p1': p1.toJson(),
      'p2': p2.toJson(),
      'currentPlayer': currentPlayer.toJson(),
    },
    'board': board.board.map((row) => row.map((c) => c.toJson()).toList()).toList(),
  };

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      data: json,      
    );
  }

  void finishTurn(){
    board.deselectCells();
    currentPlayer = currentPlayer == p1 ? p2 : p1;
    notifyListeners();
  }

  void startGame() {
    currentPlayer = p1;
  }

}