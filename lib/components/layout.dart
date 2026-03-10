import 'package:flutter/material.dart' hide Theme;
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

      body: SafeArea( child: IndexedStack(
        index: selected,
        children: [
          SingleplayerScreen(),
          MultiplayerScreen(),
        ],
        
      )),
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
      ],
    ),
    );
    
  }
}