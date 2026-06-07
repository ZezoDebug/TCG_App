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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TcgProvider>().fetchCards(widget.set.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TcgProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(widget.set.name), centerTitle: true),
      floatingActionButton:
          provider.cards.isNotEmpty && !provider.isLoadingCards
          ? FloatingActionButton.extended(
              onPressed: () => _openPack(provider),
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Abrir pack'),
            )
          : null,
      body: provider.isLoadingCards
          ? const Center(child: CircularProgressIndicator())
          : provider.errorMessage != null
          ? Center(child: Text(provider.errorMessage!))
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
                    placeholder: (_, _) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (_, _, _) =>
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
          ),
        ],
      ),
    );
  }

  void _openPack(TcgProvider provider) {
    provider.openPack();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final packCards = context.watch<TcgProvider>().openedPack;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.inventory_2),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Pack aberto',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Abrir outro pack',
                      onPressed: () => context.read<TcgProvider>().openPack(),
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 260,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: packCards.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final card = packCards[index];
                      return _buildPackCard(card);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPackCard(TcgCard card) {
    return SizedBox(
      width: 150,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          Navigator.pop(context);
          _navigateToDetail(card);
        },
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: card.image != null
                      ? CachedNetworkImage(
                          imageUrl: '${card.image}/low.png',
                          fit: BoxFit.contain,
                          placeholder: (_, _) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (_, _, _) =>
                              const Icon(Icons.image_not_supported, size: 40),
                        )
                      : const Icon(Icons.style, size: 40),
                ),
                const SizedBox(height: 8),
                Text(
                  card.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (card.rarity != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    card.rarity!,
                    style: Theme.of(context).textTheme.labelSmall,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToDetail(TcgCard card) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CardDetailScreen(cardId: card.id)),
    );
  }
}
