import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/app_view.dart';
import 'package:flutter_application_1/components/board_canva.dart';
import 'package:flutter_application_1/components/chip_row.dart';
import 'package:flutter_application_1/core/constants/styles.dart';
import 'package:flutter_application_1/core/logic/game.dart';

class SingleplayerScreen extends StatefulWidget {
  const SingleplayerScreen({super.key});

  @override
  State<SingleplayerScreen> createState() => _SingleplayerScreen();
}

class _SingleplayerScreen extends State<SingleplayerScreen> {
  
  late Game? game;

  Widget _setTitle(){
    if (game == null) return Text("UN JUGADOR", style: Styles.titleText);
    return Text(
      game!.board.getThemeName(),
      style: Styles.titleText
    );
  }

  Widget _setSubtitle() {
    
    if (game != null) {
      return ListenableBuilder(
        listenable: game!,
        builder:(context, child){
          return Column (
          children: [
            ChipRow(
            buttonTexts: game!.board.theme.words
                .where((w) => !game!.board.foundWords.contains(w))
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
    if (game != null){
      return ElevatedButton(
        onPressed: () =>
          setState(() => game= null),

        child: Text("Reiniciar Juego"),
      );
    }
    return null;
  }

  Widget _setChild(){

    if (game != null) return BoardCanva(
      game: game!,
      handler: (data){ 
        try{
          game!.updateData(data);
        } catch (e){print("$e");}
        } );
    
    return ElevatedButton(
      onPressed: () =>
        setState(() => _createBoard()),

      child: Text("Iniciar Juego"),
    );
  }

  void _createBoard() {
    game = Game(data: {'size': 10});
  }

  @override
  void initState() {
    super.initState();
    game = null;
  }

  @override
  Widget build(BuildContext context) {
    return AppView(
      title: _setTitle(),
      subtitle: _setSubtitle(),
      footer: _setFooter(),
      height: 0.75,
      child: _setChild(),
    );
  }
}