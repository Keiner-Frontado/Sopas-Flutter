import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/app_view.dart';
import 'package:flutter_application_1/components/board_canva.dart';
import 'package:flutter_application_1/components/chip_row.dart';
import 'package:flutter_application_1/core/constants/game_themes.dart';
import 'package:flutter_application_1/core/constants/styles.dart' as styles;
import 'package:flutter_application_1/core/logic/game.dart';
import 'package:flutter_application_1/core/models/board.dart';
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
  StreamSubscription<Map>? _dataSubClient;

    @override
  void dispose() {
    game = null;
    _serverRunning = false;
    _clientConnected = false;
    _logSub?.cancel();
    _logSubClient?.cancel();
    _dataSubClient?.cancel();
    _tcp.dispose();
    _tcpClient.dispose();
    super.dispose();
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
        listenable: game!.board,
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
    if (game != null) return BoardCanva(board: game!.board);

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
        dispose();
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






  void createServer() async {

    _dataSubClient = _tcpClient.onData.listen((data) {
      if (data['type'] == 'connect') setState(() => game = Game('client', data['board'],data['theme']) );

      // ignore: avoid_print
      print(data.toString());
    });

    _logSub = _tcp.onLog.listen((log) {
      // ignore: avoid_print
      print('\n $log \n');
    });
    // Subscribe to client logs too so both server and client logs appear
    _logSubClient = _tcpClient.onLog.listen((log) {
      // ignore: avoid_print
      print('\n $log \n');
    });

    try {

      await _tcp.crearConexion(port!, bindAny: true);
      final initBoard = Board(
        row: size! > 7 ? size! : 7,
        col: size! > 7 ? size! : 7,
        theme: Themes.selectTheme()
      );
      _tcp.setInitData({'board': initBoard.board, 'theme': initBoard.theme});
      setState(() => _serverRunning = true );
      connectServer();

    } catch (_) {
      // error already logged inside TcpServerManager
    }
  }

  void connectServer() async {
    await _tcpClient.conectar(ip!, port!);


  }
}