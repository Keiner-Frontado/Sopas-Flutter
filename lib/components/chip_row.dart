import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/constants/styles.dart';

class ChipRow extends StatelessWidget {

  final List<String> buttonTexts;
  const ChipRow({super.key, required this.buttonTexts});


  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
      ),
      child:SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: buttonTexts.map((text) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Chip(
                // 1. Avatar: El icono a la izquierda (opcional)
                avatar: null,
                
                // 2. Label: El texto principal
                label: Text(
                  text,
                  style: Styles.buttonText
                ),

                // 3. Estilos visuales
                backgroundColor: Styles.buttonSecondaryBg,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                
                // Eliminar el borde gris por defecto del Chip si quieres que sea plano
                side: const BorderSide(color: Colors.transparent, width: 0),
                
                // Asegurar la forma totalmente redondeada
                shape: const StadiumBorder(), 
              ),
            );
          }
          ).toList(),
        ),
      )
    );
  }
}