import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/tcg_provider.dart';
import '../models/tcg_set.dart';
import '../models/tcg_card.dart';
import 'card_detail_screen.dart';

class CardsScreen extends StatefulWidget {
  final TcgSet set;

  const CardsScreen({super.key, required this.set});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
      context.read<TcgProvider>().fetchCards(widget.set.id));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.set.name),
        centerTitle: true,
      ),
      body: provider. isLoadingCards
          ? const Center (child: CircularProgressIndicator())
          : provider.errorMessage != null
              ? Center(child: Text(provider. errorMessage!))
              : _buildGrid(provider.cards),
    );
  }

  Widget _buildGrid(List<TcgCard> cards) {
    if (cards.isEmpty) {
      return const Center(child: Text('Nenhuma carta encontrada'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) => _buildCardItem(cards[index]),
    );
  }

  Widget _buildCardItem(TcgCard card) {
    return GestureDetector(
      onTap: () => _navigateToDetail(card),
      child: Column(
        children: [
          Expanded(
            child: card.image != null
                ? CachedNetworkImage(
                  imageUrl: '${card.image}/low.png',
                  fit: BoxFit.contain,
                  placeholder: (_, __) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (_, __, ___) =>
                      const Icon(Icons.image_not_supported, size: 40),
                  )
                : const Icon(Icons.style, size: 40),
          ),
          const SizedBox(height: 4),
          Text(
            card.name,
            style: const TextStyle(fontSize: 11),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          )
        ],
      )
    );
  }

  void _navigateToDetail(TcgCard card) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CardDetailScreen(cardId: card.id),
      )
    );
  }
}