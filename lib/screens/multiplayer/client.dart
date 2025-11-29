import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/constants/styles.dart' as app_styles;
import 'package:flutter_application_1/core/services/tcp_cliente.dart';

class ClientScreen extends StatefulWidget {
  const ClientScreen({super.key});

  @override
  State<ClientScreen> createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {

  final TcpClientManager _tcpClient = TcpClientManager();
  
  final TextEditingController _logsController = TextEditingController();
  final TextEditingController _inputController = TextEditingController();
  
  final ipController = TextEditingController(text: '127.0.0.1');
  final portController = TextEditingController(text: '4040');

  StreamSubscription<String>? _logSub;
  StreamSubscription<String>? _logSubClient;

  bool _clientConnected = false;

    @override
  void initState() {
    super.initState();

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
    _tcpClient.dispose();
    _logsController.dispose();
    ipController.dispose();
    portController.dispose();
    _inputController.dispose();
    super.dispose();
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
  await _tcpClient.enviar({ 'msg': text });
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
            SizedBox(width: 8),
            ElevatedButton(
              onPressed: _clientConnected ? null : _connectClient,
              child: const Text('Conectar'),
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
          maxLines: 8,
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
        const SizedBox(height: 12),
        // Controls: create/stop server, connect client
      ],
    );
  }
}