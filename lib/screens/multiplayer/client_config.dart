import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/constants/styles.dart' as app_styles;

class ClientConfigScreen extends StatefulWidget {

  final ValueChanged<Map> onPlay;

  const ClientConfigScreen({super.key, required this.onPlay});

  @override
  State<ClientConfigScreen> createState() => _ClientConfigScreen();
}

class _ClientConfigScreen extends State<ClientConfigScreen> {
  final ipController = TextEditingController(text: '192.168.1.21');
  final portController = TextEditingController(text: '4040');

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
        
        ElevatedButton(
          onPressed: notify,
          child: Text("Conectar al servidor")
        )
      ]
    );

  }

  void notify() {
    final ip = ipController.text.trim();
    final port = int.tryParse(portController.text) ?? 4040;

    widget.onPlay({'mode': 'client', 'ip': ip, 'port': port});
  }
}