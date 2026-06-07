import 'package:flutter/material.dart';
import 'dart:math';
import '../models/tcg_set.dart';
import '../models/tcg_card.dart';
import '../services/tcg_service.dart';

class TcgProvider extends ChangeNotifier {
  final TcgService _service = TcgService();

  List<TcgSet> sets = [];
  List<TcgCard> cards = [];
  List<TcgCard> openedPack = [];
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
    openedPack = [];
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

  void openPack({int cardCount = 5}) {
    if (cards.isEmpty) {
      openedPack = [];
      notifyListeners();
      return;
    }

    final random = Random();
    final shuffledCards = [...cards]..shuffle(random);
    openedPack = shuffledCards.take(cardCount).toList();
    notifyListeners();
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
