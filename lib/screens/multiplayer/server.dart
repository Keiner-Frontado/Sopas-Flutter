import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/constants/styles.dart' as app_styles;
import 'package:flutter_application_1/core/services/tcp_cliente.dart';
import 'package:flutter_application_1/core/services/tcp_server.dart';

class ServerScreen extends StatefulWidget {
  const ServerScreen({super.key});

  @override
  State<ServerScreen> createState() => _ServerScreenState();
}

class _ServerScreenState extends State<ServerScreen> {

  final TcpServerManager _tcp = TcpServerManager();
  final TcpClientManager _tcpClient = TcpClientManager();

  final TextEditingController _logsController = TextEditingController();
  final TextEditingController _inputController = TextEditingController();

  final ipController = TextEditingController(text: '127.0.0.1');
  final portController = TextEditingController(text: '4040');

  StreamSubscription<String>? _logSub;
  StreamSubscription<String>? _logSubClient;

  bool _serverRunning = false;
  bool _clientConnected = false;
  bool _exposeToNetwork = false;

  @override
  void initState() {
    super.initState();
    _logSub = _tcp.onLog.listen((log) {
      // Append to logs TextField
      final previous = _logsController.text;
      final updated = previous.isEmpty ? log : '$previous \n $log';
      setState(() {
        _logsController.text = updated;
      });
      // Scroll behavior or selection could be added later
    });
    // Subscribe to client logs too so both server and client logs appear
    _logSubClient = _tcpClient.onLog.listen((log) {
      final previous = _logsController.text;
      final updated = previous.isEmpty ? log : '$previous \n $log';
      setState(() {
        _logsController.text = updated;
      });
    });
  }

  @override
  void dispose() {
  _logSub?.cancel();
  _logSubClient?.cancel();
  _tcp.dispose();
  _tcpClient.dispose();
    _logsController.dispose();
    ipController.dispose();
    portController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _createServer() async {
    try {
      final port = int.tryParse(portController.text) ?? 4040;
      await _tcp.crearConexion(port, bindAny: _exposeToNetwork);
      setState(() => _serverRunning = true);
    } catch (_) {
      // error already logged inside TcpServerManager
    }
  }

  Future<void> _stopServer() async {
    await _tcp.cerrarConexion();
    setState(() => _serverRunning = false);
  }

  Future<void> _connectClient() async {
    try {
      final host = ipController.text.trim();
      final port = int.tryParse(portController.text) ?? 4040;
      await _tcpClient.conectar(host, port);
      setState(() => _clientConnected = true);
    } catch (_) {
      setState(() => _clientConnected = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
  await _tcpClient.enviar({'msg': text});
    // Optionally show the sent message immediately in logs (it will also be logged by manager)
    final previous = _logsController.text;
    final updated = previous.isEmpty ? 'Tú: $text' : '$previous \n Tú: $text';
    setState(() {
      _logsController.text = updated;
      _inputController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Row(
          children: [
            Expanded(
              child: TextField(
                controller: ipController,
                style: app_styles.Styles.text,
                decoration: const InputDecoration(
                  labelText: 'IP del servidor',
                  hintText: 'Escribe la IP a la que conectarse',
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 80,
              child: TextField(
                controller: portController,
                style: app_styles.Styles.text,
                decoration: const InputDecoration(
                  labelText: 'Puerto',
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _clientConnected ? null : _connectClient,
              child: const Text('Conectar'),
            ),
            // ElevatedButton(
            //   onPressed: _connectClient,
            //   child: const Text('Conectar'),
            // ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ElevatedButton(
              onPressed: _serverRunning ? null : _createServer,
              child: const Text('Crear servidor'),
            ),
            ElevatedButton(
              onPressed: _serverRunning ? _stopServer : null,
              child: const Text('Detener servidor'),
            ),
            
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: _exposeToNetwork,
                  onChanged: (v) => setState(() => _exposeToNetwork = v ?? false),
                ),
                const Text('Exponer servidor en la red (0.0.0.0)'),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Logs area (read-only chat view)
        TextField(
          controller: _logsController,
          style: app_styles.Styles.text,
          readOnly: true,
          decoration: const InputDecoration(
            labelText: "Chat (logs)",
            hintText: "Aquí aparecerán los logs de conexión y mensajes",
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 12),
        // Input + send
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _inputController,
                style: app_styles.Styles.text,
                decoration: const InputDecoration(
                  labelText: 'Mensaje',
                  hintText: 'Escribe tu mensaje aquí',
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _clientConnected ? _sendMessage : null,
              child: const Text('Enviar'),
            ),
          ],
        ),
        // Controls: create/stop server, connect client
      ],
    );
  }
}