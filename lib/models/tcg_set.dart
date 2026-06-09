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
    final id = json['id'] ?? '';
    return TcgSet(
      id: id,
      name: json['name'] ?? '',
      logo: id.isNotEmpty ? 'https://assets.tcgdex.net/en/tcgp/$id/logo' : '',
      cardCount: json['cardCount']?['total'],
    );
  }
}
