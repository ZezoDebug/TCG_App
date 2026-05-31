import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/tcg_set.dart';
import '../models/tcg_card.dart';

class TcgService {
  static const String _baseUrlPt = 'https://api.tcgdex.net/v2/pt-BR';
  static const String _baseUrlEn = 'https://api.tcgdex.net/v2/en';

  Future<http.Response> _getWithFallback(String path) async {
    final responsePt = await http.get(Uri.parse('$_baseUrlPt/$path'));
    if (responsePt.statusCode == 200) return responsePt;

    return await http.get(Uri.parse('$_baseUrlEn/$path'));
  }

  Future<List<TcgSet>> getSets() async {
    final response = await _getWithFallback('sets');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => TcgSet.fromJson(json)).toList();
    }else{
      throw Exception('Erro ao buscar sets');
    }
  }

  Future<List<TcgCard>> getCards(String setId) async {
    final response = await _getWithFallback('sets/$setId');

    if (response.statusCode == 200){
      final data = jsonDecode(response.body);
      final List<dynamic> cards = data ['cards'] ?? [];
      return cards.map((json) => TcgCard.fromJson(json)).toList();
    }else{
      throw Exception('Erro ao buscar carta');
    }
  }

  Future<TcgCard> getCardDetail(String cardId) async {
    final response = await _getWithFallback('cards/$cardId');

    if (response.statusCode == 200) {
      return TcgCard.fromJson(jsonDecode(response.body));
    }else{
      throw Exception('Erro ao buscar carta');
    }
  }
}