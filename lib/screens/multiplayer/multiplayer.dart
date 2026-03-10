// ignore_for_file: avoid_print

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

  // gestión de conexión TCP (servidor y cliente)
  final TcpServerManager _tcp = TcpServerManager();
  final TcpClientManager _tcpClient = TcpClientManager();
  
  // estado de la pantalla: 0 = menú, 1 = creando partida, 2 = uniendo a partida
  int selected = 0;
  // datos de la partida y conexión
  String? ip, mode;
  // el tamaño de la sopa se decide al crear la partida, pero lo guardamos aquí para que el cliente lo reciba al conectarse
  int? port, size;
  // estado del juego y jugador local
  Game? game;
  /// id del jugador local (1 o 2). Se asigna en onPlay según el modo.
  int? localPlayerId;
  // estado de la conexión y el oponente, usado para mostrar mensajes de espera y controlar la interacción con el tablero
  bool _opponentConnected = false;


  // subscripciones a logs y datos del servidor para debug y actualización de estado
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
      // lógica de turno: si el jugador encontró al menos una palabra válida, sigue jugando; si no, se cambia el turno
      game!.finishTurn();
    });
    // notificamos al servidor para que actualice el estado del juego y se lo envíe al otro jugador
    _onChange({'type': 'finish_turn'});
  }

  /// Llamado para limpiar el estado de la partida y desconectar de la red, usado al volver al menú principal o al reiniciar el juego.
  void disconnect() {
    game = null;
    _opponentConnected = false;
    _logSub?.cancel();
    _logSubClient?.cancel();
    _dataSubClient?.cancel();
    _tcp.cerrarConexion();
    _tcpClient.desconectar();
  }

  // UI builders
  @override
  Widget build(BuildContext context) {
    return AppView(
      title: Text("MULTIJUGADOR", style: styles.Styles.titleText),
      subtitle: _setSubtitle(),
      height: 0.75,
      footer: _setFooter(),
      child: _setChild(),
    );
    
  }

  // el título muestra el modo de juego y la conexión
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
        // el host espera a que el cliente se conecte, así que no hay oponente al iniciar la partida
        _opponentConnected = false;
      }
      // el cliente se conecta directamente al host, así que ambos jugadores ya están presentes al iniciar la partida
      if (mode == 'client') {
        localPlayerId = 2;
        _opponentConnected = true; // el cliente asume que el host ya está esperando, así que se muestra el tablero directamente al conectarse exitosamente al servidor. Si el cliente se conecta antes de que el host inicie su servidor, la conexión fallará y se quedará en el menú principal.
        connectServer();
      }
    });
    print("""
      IP: $ip
      PORT: $port
    """);
  }
  // el subtítulo muestra las palabras por encontrar, tachando las que ya se han encontrado y coloreándolas según quién las encontró
  Widget _setSubtitle() {
    if (game != null){
      return ListenableBuilder(
        listenable: game!,
        builder:(context, child){
          return Column (
          children: [
            ChipRow(
              words: game!.board.theme.words,
              foundWords: game!.board.foundWords
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
      // el tablero solo es interactivo cuando es nuestro turno y el oponente ya se ha conectado (en el caso del host)
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
    // el botón de volver al menú solo se muestra cuando estamos en una partida o en la pantalla de configuración, no en el menú principal
    if (game != null) {

      return ListenableBuilder(
        listenable: game!,
        builder: (context, child) {
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
            // el botón de terminar turno solo se habilita si es nuestro turno y el oponente ya se ha conectado (en el caso del host)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 10,
              children: [
                OutlinedButton(onPressed: game!.gameover  ? null : ()=> game!.autoFinish(), child: Text("Terminar Juego", style: TextStyle(fontSize: 10))),
                if (isMyTurn && !game!.gameover)
                  ElevatedButton(
                    onPressed: (_opponentConnected ? _finishTurn : null),
                    child: const Text('Terminar turno', style: TextStyle(fontSize: 10)),
                  ),
                OutlinedButton(
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
      // para depuración: mostrar logs del servidor en la consola
      print('\n $log \n');
    });


    try {

      await _tcp.crearConexion(port!, bindAny: true);
      final initGame = Game(data: {'size': size});
            // Para depuración: mostrar el estado inicial del juego en la consola

      print('[---] Game created: \n\n ${initGame.toJson()}');
      _tcp.setInitGame(initGame);
      connectServer();

    } catch (_) {
      // error already logged inside TcpServerManager
    }
  }

  void connectServer() async {
    _dataSubClient = _tcpClient.onData.listen((data) {
      // para depuración: mostrar datos recibidos del servidor en la consola

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
          // para depuración: mostrar errores al procesar el estado inicial del juego recibido del servidor en la consola
          print('Error procesando connect payload: $e');
        }
      } else if (data['type'] == 'player_joined' && data['player'] == 2) {
        //ahora el host muestra el tablero y espera a que el cliente envíe su primer mensaje 
        setState(() {
          _opponentConnected = true;
        });
      } else {
        setState(() {
          try{
            game!.updateData(data);
          } catch (e) {
            // para depuración: mostrar errores al procesar actualizaciones del juego en la consola
            print('Error procesando game update payload: $e');
          }
        });
      }
    });


    // el cliente se conecta al servidor y espera a recibir el estado inicial del juego para asignarlo a su variable de estado
    _logSubClient = _tcpClient.onLog.listen((log) {
      // para depuración: mostrar logs del cliente en la consola
      print('\n $log \n');
    });

    await _tcpClient.conectar(ip!, port!);


  }
}