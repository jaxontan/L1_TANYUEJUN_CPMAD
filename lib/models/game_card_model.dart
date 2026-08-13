class FishCard {
  final int id;
  final String emoji, name;
  final String? imagePath;
  bool isFlipped, isMatched;

  FishCard(
      {required this.id,
      required this.emoji,
      required this.name,
      this.imagePath,
      this.isFlipped = false,
      this.isMatched = false});
}
