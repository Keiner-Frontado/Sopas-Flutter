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

  List<int> onPanUpdate(DragUpdateDetails details, Board board, Size? lastSize) {
  // 1. Validaciones iniciales
  if (board.selectedCells.isEmpty) return;
  if (lastSize == null) return;
  // Obtenemos la celda de INICIO (el ancla)
  final startCell = board.selectedCells.first;
  
  // Necesitamos el centro en pixeles de la celda inicial para usarlo como pivote
  // Suponiendo que tienes una función o variables para esto:
  final cellWidth = lastSize.width / board.col;
  final cellHeight = lastSize.height / board.row;
  
  final Offset startCenterPx = Offset(
    (startCell.col * cellWidth) + (cellWidth / 2),
    (startCell.row * cellHeight) + (cellHeight / 2)
  );

  // 2. Vector del movimiento (Dedo actual - Centro de celda inicial)
  final double dx = details.localPosition.dx - startCenterPx.dx;
  final double dy = details.localPosition.dy - startCenterPx.dy;
  
  // Distancia del arrastre desde el centro
  final double distance = sqrt(dx * dx + dy * dy);

  // ZONA DE ACCIÓN (Deadzone):
  // Si no se ha alejado al menos un 75% del tamaño de una celda, no hacemos nada.
  // Esto previene jitter y movimientos falsos al inicio.
  if (distance < cellWidth * 0.75) {
    // Si volvimos al centro, podríamos querer dejar solo la inicial
    return([]);
  }

  // 3. Determinar la dirección deseada (Joystick de 8 direcciones)
  // atan2 devuelve radianes entre -pi y pi.
  double angle = atan2(dy, dx); 
  
  // Convertimos el ángulo a una dirección de rejilla (dr, dc)
  // (-1, -1), (-1, 0), etc.
  List<int> direction = _getSnappedDirection(angle);
  int dirRow = direction[0];
  int dirCol = direction[1];

  // 4. Lógica de Bloqueo de Dirección
  // Si ya tenemos una línea formada (más de 1 celda), debemos respetar esa dirección
  if (board.selectedCells.length > 1) {
    final secondCell = board.selectedCells[1];
    int lockedDr = secondCell.row - startCell.row;
    int lockedDc = secondCell.col - startCell.col;

    // Normalizamos para obtener solo la dirección (-1, 0, 1)
    lockedDr = lockedDr.clamp(-1, 1);
    lockedDc = lockedDc.clamp(-1, 1);

    // Si la nueva dirección detectada por el joystick NO coincide con la bloqueada
    // Y tampoco es la dirección opuesta (por si quiere retroceder), ignoramos.
    if (dirRow != lockedDr || dirCol != lockedDc) {
      // Caso especial: El usuario está retrocediendo hacia la celda inicial.
      // Permitimos que el algoritmo recalcule basado en la proyección.
      // Pero si cambia drásticamente de ángulo (ej. de horizontal a vertical), retornamos.
      return([]); 
    }
  }

  // 5. Proyección: ¿Cuántas celdas deberíamos seleccionar en esa dirección?
  // En lugar de ver dónde está el dedo, proyectamos el vector sobre la rejilla.
  // Esto "linealiza" el movimiento perfectamente.
  
  // Proyección de la distancia sobre el eje principal del movimiento
  // Si es diagonal, la celda es más larga (hipotenusa), ajustamos por sqrt(2) aprox 1.41
  double stepSize = (dirRow != 0 && dirCol != 0) 
      ? (cellWidth * 1.414) 
      : cellWidth;
      
  // Cantidad de pasos (celdas) estimados desde el origen
  int steps = (distance / stepSize).round();

  // 6. Aplicar selección
  // Reconstruimos la lista desde 0 hasta 'steps' en la dirección calculada
  final update = _updateSelectionLine(board, startCell, dirRow, dirCol, steps);
  return(update);
}

