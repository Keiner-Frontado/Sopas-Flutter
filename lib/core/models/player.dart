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

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'isAI': isAI,
    'score': score,
  };

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      name: json['name'],
      isAI: json['isAI'],
    )..score = json['score'];
  }
}