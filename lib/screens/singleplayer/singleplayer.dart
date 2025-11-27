import 'package:flutter/material.dart' hide Theme;
import 'package:flutter_application_1/components/board_canva.dart';
import 'package:flutter_application_1/core/game/board.dart';

class SinglePlayerScreen extends StatelessWidget {
  final Board board;
  const SinglePlayerScreen({super.key, required this.board});

  @override
  Widget build(BuildContext context) {

    return LayoutBuilder(
      builder: (builder, constraints) {
        final width = constraints.maxWidth * 0.25;  // 60% del ancho del padre
        final height = constraints.maxHeight * 0.25;
        return SizedBox(
          width: width,
          height: height,
          child: BoardCanva(
            board: board,
          )
        );
        } 
    );
    
  }
}