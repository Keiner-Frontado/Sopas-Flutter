import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/multiplayer/client.dart';
import 'package:flutter_application_1/screens/multiplayer/server.dart';

class MultiplayerScreen extends StatefulWidget {
  const MultiplayerScreen({super.key});

  @override
  State<MultiplayerScreen> createState() => _MultiplayerScreenState();
}

class _MultiplayerScreenState extends State<MultiplayerScreen> {
  int selected = 0;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,

      children: [
      (selected == 0)
    ? _showMenu()
    : (selected == 1)
    ? _showClient()
    : _showServer(),
    SizedBox(height: 20),
    (selected != 0) ? ElevatedButton(
        onPressed: () => {
          setState(() {
            selected = 0;
          })
        },
        child: const Text("Volver al menú")
      ) : Text("")
    ]

    );
  }

  Widget _showMenu() {
    return 
        Column(
        spacing: 20,
        children: [
          ElevatedButton(onPressed: () => {
            setState(() {
            selected = 2;
            })},
            child: const Text("Crear partida")
          ),
          ElevatedButton(
            onPressed: () => {
            setState(() {
            selected = 1;
            })},
            child: const Text("Unirse a partida")
          ),
        ],
        );
  }
  Widget _showServer() {
    return ServerScreen();
  }

  Widget _showClient() {
    return ClientScreen();
  }
}