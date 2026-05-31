class TcgSet {
  final String id;
  final String name;
  final String? logo;
  final int? cardCount;

  TcgSet({
    required this.id,
    required this.name,
    this.logo,
    this.cardCount,
  });

  factory TcgSet.fromJson(Map<String, dynamic> json){
    return TcgSet(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      logo: json['logo'] ?? '',
      cardCount: json['cardCount']?['total'],
    );
  }
}
