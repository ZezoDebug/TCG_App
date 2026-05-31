import 'package:flutter/material.dart';
import '../models/tcg_set.dart';
import '../models/tcg_card.dart';
import '../services/tcg_service.dart';

class TcgProvider extends ChangeNotifier {
  final TcgService _service = TcgService();

  List<TcgSet> sets = [];
  List<TcgCard> cards = [];
  TcgCard? selectedCard;

  bool isLoadingSets = false;
  bool isLoadingCards = false;
  bool isLoadingCard = false;

  String? errorMessage;

  Future<void> fetchSets() async {
    isLoadingSets = true;
    errorMessage = null;
    notifyListeners();

    try {
      sets = await _service.getSets();
    } catch (e) {
      errorMessage = 'Erro ao carregar os sets';
    } finally {
      isLoadingSets = false;
      notifyListeners();
    }
  }

  Future<void> fetchCards(String setId) async {
    isLoadingCards = true;
    errorMessage = null;
    notifyListeners();

    try {
      cards = await _service.getCards(setId);
    } catch (e) {
      errorMessage = 'Erro ao carregar as cartas';
    } finally {
      isLoadingCards = false;
      notifyListeners();
    }
  }

  Future<void> fetchCardDetail(String cardId) async {
    isLoadingCard = true;
    selectedCard = null;
    errorMessage = null;

    try {
      selectedCard = await _service.getCardDetail(cardId);
    } catch (e) {
      errorMessage = 'Erro ao carrger a carta';
    } finally {
      isLoadingCard = false;
      notifyListeners();
    }
  }
}