
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/core/constants/game_themes.dart';
import 'package:flutter_application_1/core/models/board.dart';
import 'package:flutter_application_1/core/models/player.dart';

class Game extends ChangeNotifier {

  late Player p1,p2;
  late Board board;
  late Player currentPlayer;

  Game({required Map data}) {
    // load players if provided, otherwise use defaults
    if (data['players'] != null) {
      p1 = Player.fromJson(data['players']['p1']);
      p2 = Player.fromJson(data['players']['p2']);
    } else {
      p1 = Player(id: 1, name: 'Jugador 1');
      p2 = Player(id: 2, name: 'Jugador 2');
    }

    // board either comes from payload or is generated
    if (data['board'] != null) {
      board = Board.fromJson(data['board']);
    } else {
      // Crear un nuevo tablero si no hay datos
      board = Board(
        row: data['size'] > 7 ? data['size'] : 7,
        col: data['size'] > 7 ? data['size'] : 7,
        theme: Themes.selectTheme(),
      );
      // ignore: avoid_print
      print("\n\nRANDOM BOARD\n\n");
    }

    // determine current player if payload includes it otherwise start fresh
    if (data['players'] != null && data['currentPlayer'] != null) {
      try {
        final cp = Player.fromJson(data['currentPlayer']);
        currentPlayer = cp.id == p1.id ? p1 : p2;
      } catch (_) {
        // fall back to starting player
        startGame();
      }
    } else {
      startGame();
    }
  }

  /// Notify listeners (convenience wrapper)
  void notify() => notifyListeners();

  Map<String, dynamic> toJson() => {
    'players': {
      'p1': p1.toJson(),
      'p2': p2.toJson(),
      'currentPlayer': currentPlayer.toJson(),
    },
    'board': board.toJson(),
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

  void updateBoard(Board newBoard){
    board = newBoard;
    notify();
  }

  void updateData(Map data){
           // Manejo de tipos específicos de mensaje desde el cliente
        final type = data['type'];

        if (type == 'select_cell') {
          // Espera { type: 'select_cell', content: [<int>, <int>] }
          try {
            final List<dynamic> content = data['content'];
            final int r = content[0];
            final int c = content[1];

              board.selectCell(r, c);
              // Disparar notificación para que el listener propague la actualización
          }catch (e){
            throw Exception('Error procesando select_cell: $e');
          }
        }

        if (type == 'found_word'){
          try{
            board.foundWord(currentPlayer.id);
          }catch(e){
            throw Exception('Error procesando found_word: $e');
          }
        }

        if (type == 'finish_turn') {
          try{
            finishTurn();
          }catch(e){
            throw Exception('Error procesando finish_turn: $e');
          }
        }
        notify();
  }

  void startGame() {
    currentPlayer = p1;
  }

}