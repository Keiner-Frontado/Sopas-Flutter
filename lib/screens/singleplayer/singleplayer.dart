import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/app_view.dart';
import 'package:flutter_application_1/components/board_canva.dart';
import 'package:flutter_application_1/components/chip_row.dart';
import 'package:flutter_application_1/core/constants/game_themes.dart';
import 'package:flutter_application_1/core/constants/styles.dart';
import 'package:flutter_application_1/core/models/board.dart';

class SingleplayerScreen extends StatefulWidget {
  const SingleplayerScreen({super.key});

  @override
  State<SingleplayerScreen> createState() => _SingleplayerScreen();
}

class _SingleplayerScreen extends State<SingleplayerScreen> {
  
  late Board? board;

  Widget _setTitle(){
    if (board == null) return Text("UN JUGADOR", style: Styles.titleText);
    return Text(
      board!.getThemeName(),
      style: Styles.titleText
    );
  }

  Widget _setSubtitle() {
    
    if (board != null) {
      return ListenableBuilder(
        listenable: board!,
        builder:(context, child){
          return Column (
          children: [
            ChipRow(
            buttonTexts: board!.theme.words
                .where((w) => !board!.foundWords.contains(w))
                .toList(),
            ),
          ]);
        }
      );
    } else {
      return Text(
        "Presiona el botón para iniciar el juego.",
        style: Styles.text
      );
    }
  }

  Widget? _setFooter(){
    if (board != null){
      return ElevatedButton(
        onPressed: () =>
          setState(() => board= null),

        child: Text("Reiniciar Juego"),
      );
    }
    return null;
  }

  Widget _setChild(){

    if (board != null) return BoardCanva(board: board!);
    
    return ElevatedButton(
      onPressed: () =>
        setState(() => _createBoard()),

      child: Text("Iniciar Juego"),
    );
  }

  void _createBoard() {
    board= Board(row: 10, col:10, theme: Themes.selectTheme());
  }

  @override
  void initState() {
    super.initState();
    board = null;
  }

  @override
  Widget build(BuildContext context) {
    return AppView(
      title: _setTitle(),
      subtitle: _setSubtitle(),
      footer: _setFooter(),
      child: _setChild(),
    );
  }
}