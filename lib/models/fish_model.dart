class FishItem {
  final String name, imageAsset, description;
  final int price;

  const FishItem(
      {required this.name,
      required this.imageAsset,
      required this.price,
      required this.description});

  static const List<FishItem> defaultMarketCatalog = [
    FishItem(
        name: 'Bubble Fish',
        imageAsset: 'assets/fishes/fish (1).png',
        price: 15,
        description:
            'A cute round fish that loves blowing shiny ocean bubbles.'),
    FishItem(
        name: 'Ocean Swimmer',
        imageAsset: 'assets/fishes/fish (2).png',
        price: 20,
        description: 'A friendly blue swimmer exploring shallow coral reefs.'),
    FishItem(
        name: 'Puffer Pal',
        imageAsset: 'assets/fishes/fish (3).png',
        price: 25,
        description: 'A cheerful pufferfish that puffs up when excited.'),
    FishItem(
        name: 'Baby Shark',
        imageAsset: 'assets/fishes/fish (4).png',
        price: 30,
        description:
            'A playful little shark gliding gracefully around the aquarium.'),
    FishItem(
        name: 'Cute Octopus',
        imageAsset: 'assets/fishes/fish (5).png',
        price: 35,
        description:
            'A colorful eight-legged pal who loves hiding in sea caves.'),
    FishItem(
        name: 'Mini Squid',
        imageAsset: 'assets/fishes/fish (6).png',
        price: 40,
        description: 'A tiny jet-propelled squid shining bright underwater.'),
    FishItem(
        name: 'Little Crab',
        imageAsset: 'assets/fishes/fish (7).png',
        price: 45,
        description: 'A adorable red crab scuttling across the sandy seabed.'),
    FishItem(
        name: 'Jelly Friend',
        imageAsset: 'assets/fishes/fish (8).png',
        price: 50,
        description:
            'A translucent jellyfish floating peacefully like an underwater balloon.'),
    FishItem(
        name: 'Starry Guppy',
        imageAsset: 'assets/fishes/fish (9).png',
        price: 60,
        description:
            'A sparkling guppy with scales that glow under moonlight.'),
    FishItem(
        name: 'Golden Angelfish',
        imageAsset: 'assets/fishes/fish (10).png',
        price: 70,
        description: 'A royal golden fish admired for its majestic fins.'),
    FishItem(
        name: 'Neon Tetra',
        imageAsset: 'assets/fishes/fish (11).png',
        price: 80,
        description:
            'A radiant fish displaying glowing neon blue and red stripes.'),
    FishItem(
        name: 'Rainbow Crown Fish',
        imageAsset: 'assets/fishes/fish (12).png',
        price: 100,
        description:
            'The ultimate prize of the sea! A rare mythic fish crowned with magical colors.'),
  ];
}
