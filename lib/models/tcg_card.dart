class TcgCard {
  final String id;
  final String name;
  final String? image;
  final String? rarity;
  final String? category;
  final List<String> types;

  TcgCard({
    required this.id,
    required this.name,
    this.image,
    this.rarity,
    this.category,
    this.types = const [],
  });

  factory TcgCard.fromJson(Map<String, dynamic> json) {
    return TcgCard(
      id: json['id'] ?? '', 
      name: json['name'] ?? '', 
      image: json['image'], 
      rarity: json['rarity'], 
      category: json['category'], 
      types: (json['types'] as List<dynamic>?)
              ?.map((type) => type.toString())
              .toList() ??
          const [],
    );
  }
}
