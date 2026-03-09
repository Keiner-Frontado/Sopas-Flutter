import 'dart:async';

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/app_view.dart';
import 'package:flutter_application_1/components/board_canva.dart';

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
  /// id del jugador local (1 o 2). Se asigna en onPlay según el modo.
  int? localPlayerId;
  // flag to know when the other player has joined the match
  bool _opponentConnected = false;
  // flags retained for future feature expansion (currently unused)
  bool _serverRunning = false;
  bool _clientConnected = false;

  StreamSubscription<String>? _logSub;

  StreamSubscription<String>? _logSubClient;
  StreamSubscription<Map>? _dataSubClient;


  void _onChange(Map<String, dynamic> data) {
    // enviar los datos al servidor
    _tcpClient.enviar(data);

  }

  /// Llamado cuando el jugador local desea terminar su turno.
  void _finishTurn() {
    if (game == null) return;
    // actualizamos localmente (el servidor también lo hará al recibir el mensaje)
    setState(() {
      game!.finishTurn();
    });
    _onChange({'type': 'finish_turn'});
  }

  void disconnect() {
    game = null;
    _opponentConnected = false;
    _serverRunning = false;
    _clientConnected = false;
    _logSub?.cancel();
    _logSubClient?.cancel();
    _dataSubClient?.cancel();
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
      // el host siempre será jugador 1, el cliente jugador 2
      if (mode == 'server') {
        localPlayerId = 1;
        createServer();
        // host should wait for opponent
        _opponentConnected = false;
      }
      if (mode == 'client') {
        localPlayerId = 2;
        _opponentConnected = true; // host is already present
        connectServer();
      }
    });
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
            ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: game!.board.theme.words.map((word) {
                    final isFound = game!.board.foundWords.containsKey(word);
                    final finderId = game!.board.foundWords[word];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Chip(
                        label: Text(
                          word,
                          style: styles.Styles.buttonText.copyWith(
                            decoration: isFound ? TextDecoration.lineThrough : null,
                            color: isFound ? (finderId == 1 ? Colors.lightBlue : Colors.pink) : null,
                          ),
                        ),
                        backgroundColor: styles.Styles.buttonSecondaryBg,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        side: const BorderSide(color: Colors.transparent, width: 0),
                        shape: const StadiumBorder(),
                      ),
                    );
                  }).toList(),
                ),
              ),
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
    if (game != null) {
      // The board itself doesn't need the turn controls anymore; they live in the footer.
      // We still listen to the game so the board can update when state changes (e.g. found words).
      return ListenableBuilder(
        listenable: game!,
        builder: (context, child) {
          final isMyTurn = localPlayerId != null && game!.currentPlayer.id == localPlayerId;
          return Column(
            children: [
              Expanded(
                child: BoardCanva(
                  game: game!,
                  handler: _onChange,
                  // only allow interaction when it's our turn and the opponent is present (host waits for player 2)
                  allowInteraction: isMyTurn && _opponentConnected,
                ),
              ),
            ],
          );
        },

      );
    }

    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 50,
        children: _setMenu());
  }

  Widget? _setFooter() {
    if (selected == 0) return null;
    // When a game is active we display turn info and finish button together with the back button
    if (game != null) {
      final isMyTurn = localPlayerId != null && game!.currentPlayer.id == localPlayerId;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 1.0),
            child: Text(
              'Turno: ${game!.currentPlayer.name}',
              style: styles.Styles.text.copyWith(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          if (!_opponentConnected)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Text(
                'Esperando jugador 2...',
                style: styles.Styles.hintText.copyWith(fontSize: 10),
              ),
            ),
          // buttons row: finish turn (if applicable) and back
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isMyTurn)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  ),
                  onPressed: (_opponentConnected ? _finishTurn : null),
                  child: const Text('Terminar turno', style: TextStyle(fontSize: 10)),
                ),
              if (isMyTurn) const SizedBox(width: 4),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                ),
                onPressed: () => setState((){
                  selected = 0;
                  disconnect();
                }),
                child: const Text("Volver al menú", style: TextStyle(fontSize: 10)),
              ),
            ],
          ),
        ],
      );
    }

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
            // ignore: avoid_print
      print('[---] Game created: \n\n ${initGame.toJson()}');
      _tcp.setInitGame(initGame);

      setState(() => _serverRunning = true );
      connectServer();

    } catch (_) {
      // error already logged inside TcpServerManager
    }
  }

  void connectServer() async {
    _dataSubClient = _tcpClient.onData.listen((data) {
      // ignore: avoid_print
      print('[---] Game received from server: \n\n $data');

      if(data['type'] == 'connect' && game == null){
        try {
          final gameInstance = Game(data: data['content']);

          setState(() {
            game = gameInstance;
            if (mode == 'client' && data['player'] != null) {
              localPlayerId = data['player'];
            }
          });
        } catch (e) {
          // ignore: avoid_print
          print('Error procesando connect payload: $e');
        }
      } else if (data['type'] == 'player_joined' && data['player'] == 2) {
        // host learns that opponent has connected
        setState(() {
          _opponentConnected = true;
        });
      } else {
        setState(() {
          try{
            game!.updateData(data);
          } catch (e) {
            // ignore: avoid_print
            print('Error procesando game update payload: $e');
          }
        });
      }
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