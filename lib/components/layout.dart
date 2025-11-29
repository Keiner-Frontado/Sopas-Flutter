import 'package:flutter/material.dart' hide Theme;
import 'package:flutter_application_1/components/app_view.dart';
import 'package:flutter_application_1/core/constants/styles.dart';
import 'package:flutter_application_1/screens/multiplayer/multiplayer.dart';
import 'package:flutter_application_1/screens/singleplayer/singleplayer.dart';
class Layout extends StatefulWidget {
  const Layout({super.key});

  @override
  State<Layout> createState() => _Layout();
}

class _Layout extends State<Layout> {
  int selected = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: Text('App'),
        centerTitle: true,
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.settings),
            itemBuilder:  (context) => [
              PopupMenuItem(
                value: 0,
                child: Text("Opción 1"),
              ),
              PopupMenuItem(
                value: 1,
                child: Text("Opción 2"),

              ),
          ]),
        ],
      ),
      body: IndexedStack(
        index: selected,
        children: [
          SingleplayerScreen(),
          AppView(
            title: Text("MULTIJUGADOR", style: Styles.titleText),
            child: MultiplayerScreen()
          ),
          AppView(
            title: Text("PERFIL", style: Styles.titleText),
            footer: ElevatedButton(
              onPressed: () {},
              child: Text("Cerrar sesión"),
            )
          )
            
        ],
        
      ),
      bottomNavigationBar: BottomNavigationBar(
      showUnselectedLabels: false,
      currentIndex: selected,
      onTap: (index) {
        setState(() {
          selected = index;
  
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.gamepad_rounded),
          label: 'Un jugador',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.groups),
          label: 'Multijugador',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    ),
    );
    
  }
}