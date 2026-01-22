import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/app_view.dart';
import 'package:flutter_application_1/components/board_canva.dart';
import 'package:flutter_application_1/components/chip_row.dart';

import 'package:flutter_application_1/core/constants/styles.dart' as styles;
import 'package:flutter_application_1/core/logic/game.dart';

import 'package:flutter_application_1/core/services/tcp_cliente.dart';
import 'package:flutter_application_1/core/services/tcp_server.dart';
import 'package:flutter_application_1/screens/multiplayer/client_config.dart';
import 'package:flutter_application_1/screens/multiplayer/server_config.dart';

class MultiplayerScreen extends StatefulWidget {
  const MultiplayerScreen({super.key});

  @override
  State<MultiplayerScreen> createState() => _MultiplayerScreenState();
}

class _MultiplayerScreenState extends State<MultiplayerScreen> {

  final TcpServerManager _tcp = TcpServerManager();
  final TcpClientManager _tcpClient = TcpClientManager();
  
  int selected = 0;
  String? ip, mode;
  int? port, size;
  Game? game;
  bool _serverRunning = false;
  bool _clientConnected = false;

  StreamSubscription<String>? _logSub;

  StreamSubscription<String>? _logSubClient;
  StreamSubscription<Game>? _gameSubClient;

  void disconnect() {
    game = null;
    _serverRunning = false;
    _clientConnected = false;
    _logSub?.cancel();
    _logSubClient?.cancel();
    _gameSubClient?.cancel();
    _tcp.cerrarConexion();
    _tcpClient.desconectar();
  }

  @override
  Widget build(BuildContext context) {
    return AppView(
      title: Text("MULTIJUGADOR"),
      subtitle: _setSubtitle(),
      height: 0.75,
      footer: _setFooter(),
      child: _setChild(),
    );
    
  }

  void onPlay(Map received) {
    setState(() {
      ip = received['ip'];
      port = received['port'];
      size = received['size'] ?? 7;
      mode = received['mode'];
      if(mode == 'server') createServer();
      if(mode == 'client') connectServer();
    } );
    // ignore: avoid_print
    print("""
      IP: $ip
      PORT: $port
    """);
  }

  Widget _setSubtitle() {
    if (game != null){
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
      );}

      return Text(
        "Crea o únete a una partida para comenzar a jugar.",
        style: styles.Styles.hintText
      );
  }

  Widget _setChild() {
    if (game != null) return BoardCanva(game: game!);

    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 50,
        children: _setMenu()
      );
  }

  Widget? _setFooter() {
    if (selected == 0) return null;
    return OutlinedButton(

      onPressed: () => setState((){
        selected = 0;
        disconnect();
        }),
      child: const Text("Volver al menú")
    );
  }
  
  List<Widget> _setMenu() {
    List<Widget> children = [];

    if (selected == 0) {
      children = _showMenu();
    } else if (selected == 1) {
      children = _showServer();
    } else if (selected == 2){
      children = _showClient();
    }

    return children;
  }

  List<Widget> _showMenu() {
    return [
      ElevatedButton(
        onPressed: () => setState(() => selected = 1),
        child: const Text("Crear partida")
      ),
      ElevatedButton(
        onPressed: () => setState(() => selected = 2),
        child: const Text("Unirse a partida")
      ),
    ];
  }
  
  List<Widget> _showServer() {
    final screen = ServerConfigScreen(onPlay: onPlay);
      return [ screen ];

  }

  List<Widget> _showClient() {

      return [ ClientConfigScreen(onPlay: onPlay) ];

  }




// LOGICA DE SERVIDOR (hay que sacar esta vaina de aquí después)

  void createServer() async {

    _logSub = _tcp.onLog.listen((log) {
      // ignore: avoid_print
      print('\n $log \n');
    });


    try {

      await _tcp.crearConexion(port!, bindAny: true);
      final initGame = Game(data: {'size': size});

      _tcp.setInitGame(initGame);

      setState(() => _serverRunning = true );
      connectServer();

    } catch (_) {
      // error already logged inside TcpServerManager
    }
  }

  void connectServer() async {
    _gameSubClient = _tcpClient.onGame.listen((receivedGame) {
      setState(() {
        game = receivedGame;
        _clientConnected = true;
      });
      // ignore: avoid_print
      print('Game received from server: ${receivedGame.toJson()}');
    });


    // Subscribe to client logs too so both server and client logs appear
    _logSubClient = _tcpClient.onLog.listen((log) {
      // ignore: avoid_print
      print('\n $log \n');
    });

    await _tcpClient.conectar(ip!, port!);

    // If already connected synchronously, set flag
    if (_tcpClient.client != null) {
      setState(() => _clientConnected = true);
    }


  }
}