import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/app_view.dart';
import 'package:flutter_application_1/core/styles.dart' as app_styles;

class SingleplayerScreen extends StatefulWidget {
  const SingleplayerScreen({super.key});

  @override
  State<SingleplayerScreen> createState() => _SingleplayerScreenState();
}

class _SingleplayerScreenState extends State<SingleplayerScreen> {
  @override
  Widget build(BuildContext context) {
    return AppView(
      title: "Modo Un Jugador",
      subtitle: "Bienvenido al modo un jugador",
      child: [
        Text(
          "Aquí puedes jugar solo contra la IA.",
          style: app_styles.Styles.text,
        ),
      ],
    );
  }
}