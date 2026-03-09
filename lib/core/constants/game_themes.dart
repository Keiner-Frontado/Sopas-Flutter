// Constantes para sopas de letras y validaciones
import 'dart:math';

class Theme {
  final int rows;
  final int cols;
  final String theme;
  final List<String> words;
  const Theme({
    required this.rows,
    required this.cols,
    required this.theme,
    required this.words,
  });

  // Serialización: Convierte el objeto a un Map
  Map<String, dynamic> toJson() => {
    'rows': rows,
    'cols': cols,
    'theme': theme,
    'words': words,
  };

  // Deserialización: Crea el objeto desde un Map
  factory Theme.fromJson(Map<String, dynamic> json) {
    return Theme(
      rows: json['rows'],
      cols: json['cols'],
      theme: json['theme'],
      words: List<String>.from(json['words']),
    );
  }
}

class Themes{
  
  static List<Theme> themes = [
    Theme(
      rows: 10,
      cols: 10,
      theme: 'Animales',
      words: ['gato', 'perro', 'elefante', 'jirafa', 'leon'],
    ),
    Theme(
      rows: 8,
      cols: 8,
      theme: 'Frutas',
      words: ['manzana', 'pera', 'banana', 'naranja', 'kiwi', 'uva', 'durazno'],
    ),
    Theme(
      rows: 7,
      cols: 7,
      theme: 'Colores',
      words: ['rojo', 'azul', 'verde', 'amarillo', 'morado'],
    ),
    Theme(
      rows: 12,
      cols: 12,
      theme: 'Paises',
      words: ['espana', 'mexico', 'argentina', 'brasil', 'colombia', 'chile', 'peru'],
    ),
  ];

  static String _normalize(String s) => s.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toLowerCase();

  static Theme selectTheme() => themes[ Random().nextInt(themes.length) ];

  static void validateThemes() {
    for (final t in themes) {
      final int maxLen = t.rows > t.cols ? t.rows : t.cols;

      if (t.words.length < 5) {
        throw Exception('Tema "${t.theme}" debe tener al menos 5 palabras (tiene ${t.words.length}).');
      }

      if (t.words.length > 5 && t.words.length % 2 == 0) {
        throw Exception('Tema "${t.theme}" tiene más de 5 palabras; debe tener un número impar de palabras (tiene ${t.words.length}).');
      }

      for (final w in t.words) {
        final norm = _normalize(w);
        if (norm.length > maxLen) {
          throw Exception('En tema "${t.theme}", la palabra "$w" (longitud ${norm.length}) no cabe en la matriz ${t.rows}x${t.cols}.');
        }
      }
    }
  }

}
// Nota: ejecutar la validación llamando a `validateThemes()`
// desde donde necesites verificar los temas (por ejemplo al iniciar la app).
