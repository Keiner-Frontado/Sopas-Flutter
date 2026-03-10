import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_application_1/core/logic/game.dart';
import 'package:flutter_application_1/core/models/client.dart';
/*
* TcpServerManager simula la lógica básica de un servidor TCP para pruebas.
* Expone métodos en español solicitados por el usuario:
* - crearConexion(port)
* - cerrarConexion()
*
* Nota: La lógica del cliente (conectar/enviar) se ha extraído a
* `lib/core/tcp_cliente.dart` para separar responsabilidades.
*/


class TcpServerManager {

  ServerSocket? _server;
  final List<Client> _clients = [];
  final Map<Client, int> _clientPlayerIds = {}; // cliente -> id jugador (0=spectator, 1=host, 2=guest)
  Game? game;
  // StreamControllers para emitir logs de eventos y actualizaciones de juego.
  final StreamController<String> _logController = StreamController.broadcast();
  final StreamController<Map> _dataController = StreamController.broadcast();
  Stream<String> get onLog => _logController.stream;

  // Método privado para agregar mensajes al log con formato de timestamp.
  void _log(String message) {
    final ts = DateTime.now().toLocal();
    _logController.add('[SERVIDOR] (${ts.day}/${ts.month} - ${ts.hour}:${(ts.minute>9) ? ts.minute : '0${ts.minute}'})\n\t $message \n');
  }

  /// Número de clientes actualmente conectados al servidor.
  int get clientCount => _clients.length;

  void _sendUpdate(client, data){
    if (game == null) return;

    // Emitir al stream interno
    _dataController.add(data);
    _log('Estado del juego actualizado (stream interno).');

    // Construir payload serializable y enviar a todos los clientes
    try {

      for (final c in _clients) {
        try {
          if (c == client) continue; // no se lo enviamos al que envió el update
          c.send(data);
        } catch (e) {
          _log('Error enviando update al cliente ${c.name}: $e');
        }
      }
      _log('Estado del juego enviado a ${_clients.length} clientes.');
    } catch (e) {
      _log('Error serializando/enviando estado del juego: $e');
    }
  }

  void setInitGame(Game initGame) {
    game = initGame;
  }


  /// Crea y arranca el servidor TCP en el puerto indicado.
  Future<void> crearConexion(int port, {bool bindAny = false}) async {

    if (kIsWeb) {
      _log('No es posible iniciar un ServerSocket en Flutter Web. Operación ommitida.');
      return;
    }

    if (_server != null) {
      _log('Servidor ya ejecutándose en ${_server!.address.address}:${_server!.port}');
      return;
    }

    try {
      // Si el usuario pide bindAny, intentamos enlazar a anyIPv4 (0.0.0.0)
      if (bindAny) {
        _log('Intentando enlazar servidor en 0.0.0.0:$port (anyIPv4)');
        _server = await ServerSocket.bind(InternetAddress.anyIPv4, port);
      } else {
        // Primero intentamos loopback (localhost). En algunos entornos (raro)
        // puede lanzar UnsupportedError, en tal caso hacemos un fallback a anyIPv4.
        try {
          _server = await ServerSocket.bind(InternetAddress.loopbackIPv4, port);
        } on UnsupportedError catch (_) {
          _log('loopbackIPv4 no soportado, intentando InternetAddress.anyIPv4...');
          _server = await ServerSocket.bind(InternetAddress.anyIPv4, port);
        }
      }

      _log('Servidor iniciado en ${_server!.address.address}:${_server!.port}');

      _server!
      .listen((Socket client) {

        _manageClient(client);
      
      },
      onDone:() {
        
      } ,
      onError: (err) {

        _log('Error en ServerSocket: $err');
      });
    } catch (e) {
      _log('No se pudo iniciar el servidor: $e');
      rethrow;
    }
  }

  void _manageClient(Socket clientSocket) {

    final client = Client(clientSocket);
    _clients.add(client);
    _log('Cliente conectado desde ${client.ip}:${client.port}');
    
    // Asignar rol de jugador o espectador según el orden de conexión y si el juego ya ha comenzado.
    final isLoopback = client.socket.remoteAddress.isLoopback;
    int assigned = 0;
    if (game != null) {
      if (isLoopback) {
        assigned = 1;
      } else {
        final alreadyHas2 = _clientPlayerIds.values.contains(2);
        if (!alreadyHas2) {
          assigned = 2;
        }
        // else remains 0 (spectator)
      }
    }
    _clientPlayerIds[client] = assigned;
    client.setName('p$assigned');

    // Informar al cliente de su rol asignado (host/jugador 1, invitado/jugador 2, espectador) 
    // para que el frontend pueda ajustar la interfaz y controlar permisos de juego según corresponda. 
    // También se puede incluir el estado inicial del juego si ya existe, para que el cliente pueda sincronizarse inmediatamente al unirse.
    if (game != null) {
      client.send({'type': 'connect', 'content': game!.toJson(), 'player': assigned});
    }

    // Notificar a todos los clientes que un nuevo jugador se ha unido, si es el jugador 2 (invitado).
    if (assigned == 2) {
      _log('Jugador 2 se ha unido, notificando a todos.');
      for (final c in _clients) {
        try {
          c.send({'type': 'player_joined', 'player': 2});
        } catch (e) {
          _log('Error notificando unión a ${c.name}: $e');
        }
      }
    }

    // Escuchar mensajes de este cliente
    client.stream
    .transform(LineSplitter())
    .listen((String dataString) {
      try {
        final data = jsonDecode(dataString) as Map<String, dynamic>;

        _log('Mensaje de ${client.name} -> ${data.toString()}');

        // Validar que el cliente que envió el mensaje tiene derecho a hacerlo (es su turno o es un mensaje de conexión)
        final senderId = _clientPlayerIds[client] ?? 0;
        if (game != null && senderId != 0) {
          // el cliente que envió el mensaje no es espectador, pero tampoco es su turno
          if (senderId != game!.currentPlayer.id &&
              data['type'] != 'connect') {
            _log('Ignorando mensaje fuera de turno de $senderId');
            return;
          }
        }

        try{
          game!.updateData(data);
        }catch (e){
          _log('Error actualizando estado del juego: $e');
        }

        _sendUpdate(client, data);

      } catch (e) {
        _log('Error decodificando datos: $e');
      }
    }, onDone: () {
      
      _log('Cliente desconectado ${client.ip}:${client.port}');
      _clients.remove(client);
      _clientPlayerIds.remove(client);
    }, onError: (err) {

      _log('Error en cliente ${client.ip}:${client.port}: $err');
      _clients.remove(client);
      _clientPlayerIds.remove(client);
    });
      
  }

  /// Cierra el servidor y todos los clientes conectados.
  Future<void> cerrarConexion() async {
    for (final c in _clients) {
      try {
        c.disconnect();
      } catch (e) {
        _log('Error desconectando al cliente ${c.name}: $e');
      }
    }
    _clients.clear();

    try {
      await _server?.close();
      if (_server != null) {
        _log('Servidor detenido ${_server!.address.address}:${_server!.port}');
      }
      _server = null;
    } catch (e) {
      _log('Error cerrando servidor: $e');
    }
    // Quitar listener de game si existe
  }

  /// Limpia recursos internos.
  Future<void> dispose() async {
    await cerrarConexion();
    await _logController.close();
    await _dataController.close();
  }


}