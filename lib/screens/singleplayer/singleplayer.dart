import 'package:flutter/material.dart';

import 'package:flutter_application_1/components/board.dart';

class SingleplayerScreen extends StatefulWidget {
  const SingleplayerScreen({super.key});

  @override
  State<SingleplayerScreen> createState() => _SingleplayerScreenState();
}

class _SingleplayerScreenState extends State<SingleplayerScreen> {
  @override
  Widget build(BuildContext context) {
    
    return Board();
    // return AppView(
    //   title: "Modo Un Jugador",
    //   subtitle: "Bienvenido al modo un jugador",
    //   child: [
    //     Board()
    //   ]
    // );
  }
}