import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_application_1/core/logic/game.dart';
import 'package:flutter_application_1/core/models/board.dart';
import 'package:flutter_application_1/core/models/client.dart';

/*
/ TcpClientManager contiene la lógica del cliente TCP separada del servidor.
/ Métodos en español:
/ - conectar(host, port)
/ - enviar(message)
/ - desconectar()
/ - dispose()
*/
class TcpClientManager {

  Client? client;

  final StreamController<String> _logController = StreamController.broadcast();
  Stream<String> get onLog => _logController.stream;

  final StreamController<Game> _gameController = StreamController.broadcast();
  Stream<Game> get onGame => _gameController.stream;

  void _log(String message) {
    final ts = DateTime.now().toLocal();
    _logController.add('[ *CLIENTE* (${ts.day}/${ts.month} - ${ts.hour}:${(ts.minute>9) ? ts.minute : '0${ts.minute}'})] $message');
  }

  void _showData(Game game){
    _gameController.add(game);
    _log('Datos recibidos: ${game.toString()}');
  }

  /// Conecta como cliente a un servidor TCP remoto/local.
  Future<void> conectar(String host, int port) async {
    if (kIsWeb) {
      _log('No es posible usar Socket.connect en Flutter Web desde dart:io. Operación omitida.');
      return;
    }

    if (client != null) {
      _log('Cliente ya conectado a ${client!.ip}:${client!.port}');
      return;
    }

    try {
      Socket clientSocket = await Socket.connect(host, port, timeout: const Duration(seconds: 5));
      _log('Cliente conectado a $host:$port');
      client = Client(clientSocket);

      client!.stream
      .transform(LineSplitter())
      .listen((String dataString) {
        try {
          final data = jsonDecode(dataString) as Map<String, dynamic>;

          final String? type = data['type'] as String?;

          // Manejo de payloads que contienen el estado del juego
          if (type == 'game_update' && data['game'] is Map) {
            final gameJson = data['game'] as Map<String, dynamic>;

            Board? boardObj;
            if (gameJson['board'] != null) {
              try {
                boardObj = Board.fromJson({
                  'board': gameJson['board'],
                  if (gameJson['theme'] != null) 'theme': gameJson['theme'],
                });
              } catch (e) {
                _log('Error reconstruyendo Board desde game_update: $e');
              }
            }

            final gameInstance = Game(data: {
              'players': gameJson['players'],
              if (boardObj != null) 'board': boardObj,
            });

            _showData(gameInstance);
          }

          // Compatibilidad con payload antiguo 'connect' que incluye 'board' y 'theme'
          if (type == 'connect') {
            try {
              Board? boardObj;
              if (data['board'] != null) {
                boardObj = Board.fromJson(data);
              }

              final gameInstance = Game(data: {
                'players': data['players'],
                if (boardObj != null) 'board': boardObj,
              });

              _showData(gameInstance);
            } catch (e) {
              _log('Error procesando connect payload: $e');
            }
          }

          // Por defecto, solo loguear y ignorar
          _log('Mensaje no procesado del servidor: ${data.toString()}');

        } catch (e) {
          _log('Error decodificando respuesta: $e');
        }
      }, onDone: () {
        _log('Conexión del cliente cerrada por el servidor');
        client!.disconnect();
      }, onError: (err) {
        _log('Error en socket cliente: $err');
        client!.disconnect();
      });
    } catch (e) {
      _log('No se pudo conectar al servidor $host:$port - $e');
      rethrow;
    }
  }

  /// Envía un mensaje (string) desde el cliente conectado.
  Future<void> enviar(Map<String,dynamic> msgData) async {
    if (client == null) {
      _log('No hay cliente conectado para enviar mensaje');
      return;
    }

    try {
      client!.send(msgData);
      _log('Enviado desde cliente: ${msgData.toString()}');
    } catch (e) {
      _log('Error enviando mensaje: $e');
    }
  }

  /// Cierra la conexión del cliente si existe.
  void desconectar() async {
    if (client == null) return;
    try {
      await client!.disconnect();
      _log('Cliente desconectado manualmente');
    } catch (e) {
      _log('Error cerrando socket cliente: $e');
    } finally {
      client = null;
    }
  }

  /// Limpia recursos internos.
  Future<void> dispose() async {
    desconectar();
    await _logController.close();
  }
}
