import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/app_view.dart';
import 'package:flutter_application_1/core/constants/styles.dart' as app_styles;
import 'package:flutter_application_1/screens/multiplayer/client.dart';
import 'package:flutter_application_1/screens/multiplayer/server.dart';

class MultiplayerScreen extends StatefulWidget {
  const MultiplayerScreen({super.key});

  @override
  State<MultiplayerScreen> createState() => _MultiplayerScreenState();
}

class _MultiplayerScreenState extends State<MultiplayerScreen> {
  int selected = 0;
  bool config = true;
  final ipController = TextEditingController(text: '127.0.0.1');
  final portController = TextEditingController(text: '4040');
  @override
  Widget build(BuildContext context) {
    return AppView(
      title: Text("MULTIJUGADOR"),
      height: 0.75,
      footer: _setFooter(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 50,
        children: _setChildren()
      )
    );
    
    
  }
  Widget? _setFooter() {
    if (selected == 0) return null;
    return OutlinedButton(

      onPressed: () => setState((){
        selected = 0;
        config = true;
        }),
      child: const Text("Volver al menú")
    );
  }
  
  List<Widget> _setChildren() {
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

    if (config){
      return [
        
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
          onPressed: ()=> setState(()=> config = false),
          child: Text("Conectar al servidor")
        )

        
      ];
    }else{
      return [ServerScreen()];
    }
  }

  List<Widget> _showClient() {
    if (config){
      return [
                
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
          onPressed: ()=> setState(()=> config = false),
          child: Text("Conectar al servidor")
        )
      ];
    }else{
    return [ClientScreen()];
    }
  }
}