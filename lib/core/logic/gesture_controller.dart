import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/models/board.dart';

/// Convierte el ángulo del puntero en una dirección de matriz (dRow, dCol)
  /// Divide el círculo en 8 rebanadas de 45 grados cada una.
  List<int> _getSnappedDirection(double angle) {
  // Convertir a grados para facilitar lectura mental (opcional, se puede hacer en radianes)
  double degrees = angle * 180 / pi;

  // Ajustar rotación para que 0 grados esté centrado en el ESTE
  // Los sectores son de 45 grados, así que offset de 22.5
  if (degrees < 0) degrees += 360;

  // Mapeo aproximado de zonas
  // 0: Este (0, 1)
  // 1: Sur-Este (1, 1)
  // 2: Sur (1, 0)
  // ... etc
  
  // Este (337.5 a 22.5)
  if (degrees >= 337.5 || degrees < 22.5) return [0, 1];
  // Sur-Este (22.5 a 67.5)
  if (degrees >= 22.5 && degrees < 67.5) return [1, 1];
  // Sur (67.5 a 112.5)
  if (degrees >= 67.5 && degrees < 112.5) return [1, 0];
  // Sur-Oeste (112.5 a 157.5)
  if (degrees >= 112.5 && degrees < 157.5) return [1, -1];
  // Oeste (157.5 a 202.5)
  if (degrees >= 157.5 && degrees < 202.5) return [0, -1];
  // Nor-Oeste (202.5 a 247.5)
  if (degrees >= 202.5 && degrees < 247.5) return [-1, -1];
  // Norte (247.5 a 292.5)
  if (degrees >= 247.5 && degrees < 292.5) return [-1, 0];
  // Nor-Este (292.5 a 337.5)
  if (degrees >= 292.5 && degrees < 337.5) return [-1, 1];

  return [0, 0]; // Fallback
}

  /// Sincroniza el tablero llamando a selectCell solo cuando es necesario

  List<int> _updateSelectionLine(Board board, dynamic startCell, int dr, int dc, int steps) {
  
  // 1. Calculamos cuántas celdas DEBERÍAMOS tener seleccionadas en total
  // (1 por la celda inicial + los pasos calculados)
  int targetLength = steps + 1;
  int currentLength = board.selectedCells.length;

  // CASO A: Avanzando (El usuario alarga la selección)
  if (targetLength > currentLength) {
    // Iteramos desde donde nos quedamos hasta donde deberíamos estar.
    // Esto rellena los huecos si el usuario mueve el dedo muy rápido.
    for (int i = currentLength; i < targetLength; i++) {
      int nextR = startCell.row + (dr * i);
      int nextC = startCell.col + (dc * i);

      // Verificamos límites por seguridad antes de llamar a tu lógica
      if (nextR >= 0 && nextR < board.row && 
          nextC >= 0 && nextC < board.col) {
        
        // AQUÍ ESTÁ LA INTEGRACIÓN:
        // Llamamos a tu método existente. Él se encarga de notifyListeners, etc.
        return([nextR, nextC]);
      }
    }
  } 
  return([]);
}

  //
  List<int>? _getCellFromPosition(Offset localPosition, Board board, Size? lastSize) {
    final size = lastSize;
    if (size == null) return null;
    final cellW = size.width / board.col;
    final cellH = size.height / board.row;
    int c = (localPosition.dx / cellW).floor();
    int r = (localPosition.dy / cellH).floor();
    if (r < 0 || r >= board.row || c < 0 || c >= board.col) return null;
    return [r, c];
  }

  List<int> onPanStart(DragStartDetails details,Board board, Size? lastSize) {
    board.selectedCells.clear();
    final cell = _getCellFromPosition(details.localPosition, board, lastSize);
    if (cell != null) {
      final r = cell[0];
      final c = cell[1];
      return([r, c]);
    }
  return([]);
  }

  // Devuelve la celda a seleccionar o deseleccionar según el movimiento del dedo, o null si no hay cambios
  List<int> onPanUpdate(DragUpdateDetails details, Board board, Size? lastSize) {
  // Si no hay celdas seleccionadas aún, no tenemos una dirección fija, así que solo intentamos seleccionar la celda bajo el dedo (sin restricciones de dirección) 
  if (board.selectedCells.isEmpty || lastSize == null) return [];

  // Obtenemos la celda bajo el dedo y calculamos la dirección del movimiento
  final cell = _getCellFromPosition(details.localPosition, board, lastSize);
  // Si no hay celda bajo el dedo, no hacemos nada
  if (cell == null) return [];
  final int r = cell[0];
  final int c = cell[1];

  // Si la celda ya está seleccionada, no hacemos nada (esto evita que el usuario "salte" celdas y luego vuelva a ellas para corregir su dirección)
  if (board.isCellSelected(r, c)) return [];

  // Obtenemos la última celda seleccionada para calcular la dirección del movimiento
  final last = board.selectedCells.last;
  int dr = r - last.row;
  int dc = c - last.col;
  // Si el movimiento es demasiado grande (el usuario saltó varias celdas), no hacemos nada. Esto también ayuda a evitar problemas si el usuario mueve el dedo muy rápido.
  if (dr.abs() > 1 || dc.abs() > 1) return [];

  // Si ya tenemos al menos 2 celdas seleccionadas, bloqueamos la dirección para evitar que el usuario cambie de opinión a mitad de camino. Solo permitimos deshacer el último paso (revertir la dirección) para corregir errores.
  if (board.selectedCells.length > 1) {
    final first = board.selectedCells.first;
    int lockDr = board.selectedCells[1].row - first.row;
    int lockDc = board.selectedCells[1].col - first.col;
    lockDr = lockDr.clamp(-1, 1);
    lockDc = lockDc.clamp(-1, 1);
    if (dr != lockDr || dc != lockDc) {
      if (!(dr == -lockDr && dc == -lockDc)) return [];
    }
  }

  return [r, c];
}

