import 'dart:math';
import 'package:flutter_application_1/core/constants/game_themes.dart';

class Cell {
  final int row, col;
  String letter;
  bool isSelected;
  bool isUsed;
  // Constructor para crear una celda con su posición, letra y estados iniciales.
  Cell({
    required this.row,
    required this.col,
    required this.letter,
    this.isSelected = false,
    this.isUsed = false,
  });

  // Convierte el objeto a un Mapa que JSON pueda entender
  Map<String, dynamic> toJson() => {
    'row': row,
    'col': col,
    'letter': letter,
    'isSelected': isSelected,
    'isUsed': isUsed,
  };

  // Crea una instancia de Cell a partir de un Mapa (JSON)
  factory Cell.fromJson(Map<String, dynamic> json) {
    return Cell(
      row: json['row'],
      col: json['col'],
      letter: json['letter'],
      isSelected: json['isSelected'],
      isUsed: json['isUsed'],
    );
  }

  Cell copy() {
    return Cell(
      row: row,
      col: col,
      letter: letter,
      isSelected: isSelected,
      isUsed: isUsed,
    );
  }

}

class Board {
  final int row;
  final int col;
  late Theme theme;
  late List<List<Cell>> board;
  Map<String, int> foundWords = {};
  List<Cell> selectedCells = [];
  String selectedWord = '';
  // Guarda el estado previo de isSelected para celdas (clave 'r:c')
  final Map<String, bool> prevIsSelected = {};

  // El constructor ahora acepta un tablero pre-creado opcionalmente
  // para facilitar la creación de un Board a partir de JSON sin perder la lógica de inicialización
  Board({required this.row, required this.col, required this.theme, board}) {
    if ( board != null) {this.board = board;} else {createBoard();}
  }
  


  String getThemeName(){
    return theme.theme;
  }

  void createBoard() {
    // Si no se pasa un tema, usa uno seleccionado aleatoriamente desde `Themes`

    // Inicializa la matriz vacía con cadenas vacías
    board = List.generate( row, (r) => List.generate(col, (c) => Cell(row: r, col: c, letter: '')) );

    final rnd = Random();
    final dirs = [
      [1, 0],
      [-1, 0],
      [0, 1],
      [0, -1],
      [1, 1],
      [1, -1],
      [-1, 1],
      [-1, -1],
    ];
    try{
      for (final word in theme.words) {
        
        if (word.isEmpty) continue;

        bool placed = false;

        // Intentos máximos para colocar una palabra
        for (int attempt = 0; attempt < 500 && !placed; attempt++) {
          final dir = dirs[rnd.nextInt(dirs.length)];
          final startRow = rnd.nextInt(row);
          final startCol = rnd.nextInt(col);

          int r = startRow;
          int c = startCol;
          int i;

          // Verificar si la palabra cabe en la posición y dirección seleccionadas
          for (i = 0; i < word.length; i++) {
            if (r < 0 || r >= row || c < 0 || c >= col) break;
            if (board[r][c].letter != '' && board[r][c].letter != word[i]) break;
            r += dir[0];
            c += dir[1];
          }

          if (i == word.length) {
            // Colocar la palabra en el tablero
            r = startRow;
            c = startCol;
            for (int j = 0; j < word.length; j++) {
              board[r][c].letter = word[j];
              r += dir[0];
              c += dir[1];
            }
            placed = true;
          }
        }

        if (!placed) {
          throw Exception('No se pudo colocar la palabra "$word" en el tablero tras múltiples intentos.');
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
      theme = Themes.selectTheme();
      createBoard();
      return;
    }
    // Rellenar espacios vacíos con letras aleatorias
    const letters = 'abcdefghijklmnopqrstuvwxyz';
    for (int r = 0; r < row; r++) {
      for (int c = 0; c < col; c++) {
        if (board[r][c].letter == '') {
          board[r][c].letter = letters[rnd.nextInt(letters.length)];
        }
      }
    }
  }

  bool isCellSelected(int r, int c) {
    return selectedCells.any((cell) => cell.row == r && cell.col == c);
  }

  Cell getCell(int r, int c) {
    if (r < 0 || r >= row || c < 0 || c >= col) {
      throw Exception('Coordenadas de celda inválidas: ($r, $c).');
    }
    return board[r][c];
  }

  void selectCell(int r, int c) {
    if (r < 0 || r >= row || c < 0 || c >= col) {
      throw Exception('Coordenadas de celda inválidas: ($r, $c).');
    }
    final key = '$r:$c';
    // Guardar estado previo antes de cambiar
    prevIsSelected[key] = board[r][c].isSelected;
    selectedCells.add(board[r][c].copy());
    selectedWord += board[r][c].letter;
    board[r][c].isSelected = true;
  }

  int foundWord([int? playerId]) {
    
    final List<bool> prevIsUsed = [];
    int modified = 0;
    // Validar la palabra seleccionada y actualizar el estado del tablero si es correcta, o revertir cualquier cambio si no lo es.
    try {
      
      if (!theme.words.contains(selectedWord)) {
        throw Exception('La palabra "$selectedWord" no está en la lista de palabras del tema.');
      }
      if (foundWords.containsKey(selectedWord)) {
        throw Exception('La palabra "$selectedWord" ya ha sido encontrada.');
      }

      

      for(final (i, cell) in selectedCells.indexed) {

      final r = cell.row;
      final c = cell.col;

      if (r < 0 || r >= row || c < 0 || c >= col) {
        throw Exception('Coordenadas de celda inválidas: ($r, $c).');
      }

      if (board[r][c].letter != selectedWord[i]) {
        throw Exception('La letra en la celda ($r, $c) no coincide con la palabra "$selectedWord".');
      }

      // Guardar estado anterior antes de modificar
      prevIsUsed.add(board[r][c].isUsed);
      board[r][c].isUsed = true;
      modified++;
      }

    foundWords[selectedWord] = playerId ?? 1;
    // ignore: 
    final pts = selectedWord.length; // Aquí podrías implementar una lógica de puntuación más compleja basada en la longitud de la palabra, letras utilizadas, etc.
    // ignore: avoid_print
    print('Palabra encontrada: "$selectedWord" por el jugador ${playerId ?? 1} que vale $pts puntos.');
    return selectedWord.length;
    } catch (e) {
      // Restaurar los estados isUsed de las celdas que ya se modificaron
      for (final (j, cell) in selectedCells.take(modified).indexed) {
        final rr = cell.row;
        final cc = cell.col;
        if (rr < 0 || rr >= row || cc < 0 || cc >= col) continue;
        board[rr][cc].isUsed = prevIsUsed[j];
      }
      rethrow;

    } finally {
      deselectCells();
    }
  }

  bool isfinished() {
    return (foundWords.length == theme.words.length);
  }

  void deselectCells(){
    // Siempre deseleccionar las celdas recibidas
      for (final cell in selectedCells) {
        final r = cell.row;
        final c = cell.col;
        if (r < 0 || r >= row || c < 0 || c >= col) continue;
        board[r][c].isSelected = false;
      }
      selectedCells.clear();
      selectedWord = '';
      prevIsSelected.clear();
  }
  // Este método se puede usar para actualizar la selección de celdas desde fuera del Board, por ejemplo al recibir un update de otro jugador en modo multijugador
  updateSelectedCells(List<Cell> selectedCells) {
    this.selectedCells = selectedCells;
  }

  Map<String, dynamic> toJson() {
    return {
      'board': board.map((row) => row.map((c) => c.toJson()).toList()).toList(),
      'theme': theme.toJson(),
      'foundWords': foundWords.entries.map((e) => {'word': e.key, 'player': e.value}).toList(),
    };
  }
  // Crea un Board a partir de un JSON serializado (matriz de celdas y opcional tema)
  factory Board.fromJson(Map<String, dynamic> json) {
    
    final rawBoard = json['board'] as List?;
    if (rawBoard == null) {
      throw Exception('Board.fromJson: no se encontró la clave "board"');
    }

    final matrix = rawBoard.map((row) {
      return (row as List).map((cellData) {
        return Cell.fromJson(cellData as Map<String, dynamic>);
      }).toList();
    }).toList();

    final int rows = matrix.length;
    final int cols = rows > 0 ? matrix[0].length : 0;

    Theme theme;
    if (json['theme'] != null) {
      theme = Theme.fromJson(json['theme'] as Map<String, dynamic>); 
    }else{
      throw Exception('Board.fromJson: no se encontró la clave "theme"');
    }

    // El constructor de Board se encarga de asignar la matriz y el tema correctamente, sin llamar a createBoard()
    final boardObj = Board(row: rows, col: cols, theme: theme, board: matrix);
    if (json['foundWords'] != null) {
      try {
        boardObj.foundWords = Map.fromEntries(
          (json['foundWords'] as List).map((e) => MapEntry(e['word'] as String, e['player'] as int))
        );
      } catch (_) {}
    }
    return boardObj;
  }

  printBoard() {

    // ignore: avoid_print
    print(theme.theme);
    for (var row in board) {
      // ignore: avoid_print
      print(row.join(' '));
    }
  }
}

// int main() {
//   final players = [Player(name: "Alice"), Player(name: "Bob")];
//   final board = Board(players, row: 10, col: 10);
//   board.printBoard();
//   return 0;
// }