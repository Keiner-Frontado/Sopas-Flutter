import 'package:flutter/material.dart' hide Theme;
import 'package:flutter_application_1/components/app_view.dart';
import 'package:flutter_application_1/core/game/board.dart';
import 'package:flutter_application_1/core/game/word_search_themes.dart';
import 'package:flutter_application_1/screens/multiplayer/multiplayer.dart';
import 'package:flutter_application_1/screens/singleplayer/singleplayer.dart';
class Layout extends StatefulWidget {
  const Layout({super.key});

  @override
  State<Layout> createState() => _Layout();
}

class _Layout extends State<Layout> {
  int selected = 0;
  Board? board;
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
          AppView(
            title: "Modo Un Jugador",
            subtitle: (board != null) ? board?.theme.theme : "Presiona el botón para iniciar el juego",
            footer: (board != null) ? ElevatedButton(
              onPressed: (){
                setState((){
                    board= null;
                  }
                );
              },
              child: Text("Reiniciar Juego"),
            ) : null,
            child: (board != null) ? SinglePlayerScreen(board: board!)
            : ElevatedButton(
              onPressed: (){
                setState((){
                    board= Board(row: 10, col:10, theme: Themes.selectTheme());
                  }
                );
              },
              child: Text("Iniciar Juego"),
            ),
          ),
          AppView(
            title: "Modo Multijugador",
            child: MultiplayerScreen()
          ),
          AppView(
            title: "Perfil de usuario",
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