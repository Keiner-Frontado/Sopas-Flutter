import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/constants/styles.dart' as styles;

class ChipRow extends StatelessWidget {

  final List<String> words;
  final Map<String, int> foundWords;
  const ChipRow({super.key, required this.words, required this.foundWords});


  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: words.map((word) {
            final isFound = foundWords.containsKey(word);
            final finderId = foundWords[word];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Chip(
                label: Text(
                  word,
                  style: styles.Styles.buttonText.copyWith(
                    decoration: isFound ? TextDecoration.lineThrough : null,
                    color: isFound ? (finderId == 1 ? Colors.lightBlue : Colors.pink) : null,
                  ),
                ),
                backgroundColor: styles.Styles.buttonSecondaryBg,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                side: const BorderSide(color: Colors.transparent, width: 0),
                shape: const StadiumBorder(),
              ),
            );
          }).toList(),
        ),
      ),
    ); 
  }
}