import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
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
          _log('Respuesta servidor -> ${data.toString()}');
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
