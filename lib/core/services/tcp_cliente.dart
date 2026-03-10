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
// El cliente se conecta a un servidor TCP remoto/local, envía mensajes y recibe respuestas.
class TcpClientManager {
  // El cliente TCP activo, si existe. Null si no hay conexión.
  Client? client;
  // StreamController para emitir logs de eventos (conexiones, errores, mensajes).
  final StreamController<String> _logController = StreamController.broadcast();
  Stream<String> get onLog => _logController.stream;
  final StreamController<Map> _dataController = StreamController.broadcast();
  Stream<Map> get onData => _dataController.stream;
  // Método privado para agregar mensajes al log con formato de timestamp.
  void _log(String message) {
    final ts = DateTime.now().toLocal();
    _logController.add('[ *CLIENTE* (${ts.day}/${ts.month} - ${ts.hour}:${(ts.minute>9) ? ts.minute : '0${ts.minute}'})] $message');
  }
  // Método privado para emitir datos recibidos a través del stream onData.
  void _showData(Map data){
    _dataController.add(data);
    _log('Datos recibidos: $data');
  }

  /// Conecta como cliente a un servidor TCP remoto/local.
  Future<void> conectar(String host, int port) async {
    if (kIsWeb) {
      _log('No es posible usar Socket.connect en Flutter Web desde dart:io. Operación omitida.');
      return;
    }
    // Verificar si ya hay un cliente conectado antes de intentar conectar.
    if (client != null) {
      _log('Cliente ya conectado a ${client!.ip}:${client!.port}');
      return;
    }
    // Intentar conectar al servidor TCP. Si falla, se lanza una excepción que el llamador debe manejar.
    try {
      Socket clientSocket = await Socket.connect(host, port, timeout: const Duration(seconds: 5));
      _log('Cliente conectado a $host:$port');
      client = Client(clientSocket);
      
      client!.stream
      .transform(LineSplitter())
      .listen((String dataString) {

        try {
          final data = jsonDecode(dataString) as Map<String, dynamic>;

          _log('DATA RECIBIDA CLIENTE: $dataString');
          
          _showData(data);

        } catch (e) {
          _log('Error decodificando respuesta: $e \n\n Data: $dataString');
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

  // envía un mensaje (string) desde el cliente conectado.
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
