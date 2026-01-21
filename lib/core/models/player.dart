class Player {
  final int id;
  final bool isAI;
  final String name;
  int score = 0;

  Player({
    required this.id,
    this.name = "Guest",
    this.isAI = false,
  });
}