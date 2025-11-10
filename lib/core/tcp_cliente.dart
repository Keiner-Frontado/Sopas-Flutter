import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

/*
/ TcpClientManager contiene la lógica del cliente TCP separada del servidor.
/ Métodos en español:
/ - conectar(host, port)
/ - enviar(message)
/ - desconectar()
/ - dispose()
*/
class TcpClientManager {
  Socket? _clientSocket;

  final StreamController<String> _logController = StreamController.broadcast();

  Stream<String> get onLog => _logController.stream;

  void _log(String message) {
    final ts = DateTime.now().toLocal();
    _logController.add('[ *CLIENTE* (${ts.day}/${ts.month} - ${ts.hour}:${(ts.minute>9) ? ts.minute : '0${ts.minute}'})] $message');
  }

  /// Conecta como cliente a un servidor TCP remoto/local.
  Future<void> conectar(String host, int port) async {
    if (kIsWeb) {
      _log('No es posible usar Socket.connect en Flutter Web desde dart:io. Operación omitida.');
      return;
    }

    if (_clientSocket != null) {
      _log('Cliente ya conectado a ${_clientSocket!.remoteAddress.address}:${_clientSocket!.remotePort}');
      return;
    }

    try {
      _clientSocket = await Socket.connect(host, port, timeout: const Duration(seconds: 5));
      _log('Cliente conectado a $host:$port');

      _clientSocket!.listen((data) {
        try {
          final message = utf8.decode(data);
          _log('Respuesta servidor -> $message');
        } catch (e) {
          _log('Error decodificando respuesta: $e');
        }
      }, onDone: () {
        _log('Conexión del cliente cerrada por el servidor');
        _clientSocket = null;
      }, onError: (err) {
        _log('Error en socket cliente: $err');
        _clientSocket = null;
      });
    } catch (e) {
      _log('No se pudo conectar al servidor $host:$port - $e');
      rethrow;
    }
  }

  /// Envía un mensaje (string) desde el cliente conectado.
  Future<void> enviar(String message) async {
    if (_clientSocket == null) {
      _log('No hay cliente conectado para enviar mensaje');
      return;
    }

    try {
      final bytes = utf8.encode(message);
      _clientSocket!.add(bytes);
      _log('Enviado desde cliente: $message');
    } catch (e) {
      _log('Error enviando mensaje: $e');
    }
  }

  /// Cierra la conexión del cliente si existe.
  Future<void> desconectar() async {
    if (_clientSocket == null) return;
    try {
      await _clientSocket?.close();
      _log('Cliente desconectado manualmente');
    } catch (e) {
      _log('Error cerrando socket cliente: $e');
    } finally {
      _clientSocket = null;
    }
  }

  /// Limpia recursos internos.
  Future<void> dispose() async {
    await desconectar();
    await _logController.close();
  }
}
