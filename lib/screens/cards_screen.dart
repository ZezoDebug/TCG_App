import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/tcg_card.dart';
import '../models/tcg_set.dart';
import '../providers/tcg_provider.dart';
import 'card_detail_screen.dart';

class CardsScreen extends StatefulWidget {
  final TcgSet set;

  const CardsScreen({super.key, required this.set});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  static const _surfaceColor = Colors.white;
  static const _accentColor = Colors.red;
  static const _rareColor = Colors.redAccent;

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text(widget.set.name)),
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
          ? _buildStateMessage(
              icon: Icons.error_outline,
              title: 'Nao foi possivel carregar',
              message: provider.errorMessage!,
            )
          : _buildGrid(provider.cards),
    );
  }

  Widget _buildGrid(List<TcgCard> cards) {
    if (cards.isEmpty) {
      return _buildStateMessage(
        icon: Icons.style_outlined,
        title: 'Nenhuma carta encontrada',
        message: 'Essa colecao ainda nao retornou cartas.',
      );
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(cards.length)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 96),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 170,
              childAspectRatio: 0.58,
              crossAxisSpacing: 12,
              mainAxisSpacing: 14,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildCardItem(cards[index]),
              childCount: cards.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(int cardCount) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 78,
        16,
        24,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.red.shade50, Colors.white],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.set.name,
                      style: const TextStyle(
                        fontSize: 28,
                        height: 1.05,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Toque em uma carta para ver detalhes em alta resolucao.',
                      style: const TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              _buildSetLogo(),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _buildHeaderChip(Icons.style, '$cardCount cartas'),
              const SizedBox(width: 10),
              _buildHeaderChip(Icons.inventory_2, 'Pack de 5'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSetLogo() {
    return Container(
      width: 92,
      height: 76,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black12),
      ),
      child: widget.set.logo != null && widget.set.logo!.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: '${widget.set.logo}.png',
              fit: BoxFit.contain,
              errorWidget: (_, _, _) => const Icon(Icons.style),
            )
          : const Icon(Icons.style),
    );
  }

  Widget _buildHeaderChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: _rareColor),
          const SizedBox(width: 7),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildCardItem(TcgCard card) {
    return Material(
      color: _surfaceColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _navigateToDetail(card),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Hero(
                  tag: card.id,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black12,
                          Colors.black26,
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: card.image != null
                          ? CachedNetworkImage(
                              imageUrl: '${card.image}/low.png',
                              fit: BoxFit.contain,
                              placeholder: (_, _) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (_, _, _) =>
                                  const Icon(Icons.image_not_supported),
                            )
                          : const Icon(Icons.style, size: 40),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 9),
              Text(
                card.name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 7),
              Align(
                alignment: Alignment.center,
                child: _buildRarityBadge(card.rarity ?? card.category ?? 'TCG'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRarityBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _accentColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: _accentColor,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildStateMessage({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 54, color: _accentColor),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _openPack(TcgProvider provider) {
    provider.openPack();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: _surfaceColor,
      builder: (context) {
        final packCards = context.watch<TcgProvider>().openedPack;
        if (packCards.isEmpty) return const SizedBox();

        int currentIndex = 0;

        return StatefulBuilder(
          builder: (context, setState) {
            final card = packCards[currentIndex];

            return GestureDetector(
              onTap: () {
                if (currentIndex < packCards.length - 1) {
                  setState(() => currentIndex++);
                } else {
                  Navigator.pop(context);
                }
              },
              behavior: HitTestBehavior.opaque,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: _rareColor.withValues(alpha: 0.14),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.inventory_2, color: _rareColor),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Pack aberto (${currentIndex + 1}/${packCards.length})',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Fechar',
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 380,
                        child: Center(
                          child: _buildPackCard(card),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        currentIndex < packCards.length - 1 
                            ? 'Toque na tela para a proxima carta'
                            : 'Toque na tela para fechar',
                        style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPackCard(TcgCard card) {
    return AspectRatio(
      aspectRatio: 0.7,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: card.image != null
                  ? CachedNetworkImage(
                      imageUrl: '${card.image}/high.png',
                      fit: BoxFit.contain,
                      placeholder: (_, _) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (_, _, _) =>
                          const Icon(Icons.image_not_supported, size: 60),
                    )
                  : const Icon(Icons.style, size: 60),
            ),
            const SizedBox(height: 12),
            Text(
              card.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (card.rarity != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.center,
                child: _buildRarityBadge(card.rarity!),
              ),
            ],
          ],
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
