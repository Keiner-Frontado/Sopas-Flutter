import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/constants/styles.dart' as app_styles;

class ServerConfigScreen extends StatefulWidget {

  final ValueChanged<Map> onPlay;
  const ServerConfigScreen({super.key, required this.onPlay});

  @override
  State<ServerConfigScreen> createState() => _ServerConfigScreen();
}

class _ServerConfigScreen extends State<ServerConfigScreen> {
  final ipController = TextEditingController(text: '127.0.0.1');
  final portController = TextEditingController(text: '4040');
  final sizeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 50,
      children:[
        SizedBox(
          width: 300,
          child: TextField(
            controller: ipController,
            style: app_styles.Styles.text,
            decoration: const InputDecoration(
              labelText: 'IP del servidor',
              hintText: '127.0.0.1',
            ),
          ),
        ),
        
        SizedBox(
          width: 300,
          child: TextField(
            controller: portController,
            style: app_styles.Styles.text,
            decoration: const InputDecoration(
              labelText: 'Puerto',
              hintText: '4040',
            ),
            keyboardType: TextInputType.number,
          ),
        ),
        
        SizedBox(
          width: 300,
          child: TextField(
            controller: sizeController,
            style: app_styles.Styles.text,
            decoration: const InputDecoration(
              labelText: 'Tamaño del tablero',
              hintText: '7~20',
            ),
            keyboardType: TextInputType.number,
          ),
        ),

        ElevatedButton(
          onPressed: ()=> notify(),
          child: Text("Conectar al servidor")
        )
      ]
    );

  }

  void notify() {
    final ip = ipController.text.trim();
    final port = int.tryParse(portController.text) ?? 4040;
    final size = int.tryParse(sizeController.text) ?? 7;
    widget.onPlay({'mode': 'server', 'ip': ip, 'port': port, 'size': size});
  }
}