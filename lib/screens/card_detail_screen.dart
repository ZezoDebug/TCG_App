import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/tcg_card.dart';
import '../providers/tcg_provider.dart';

class CardDetailScreen extends StatefulWidget {
  final String cardId;

  const CardDetailScreen({super.key, required this.cardId});

  @override
  State<CardDetailScreen> createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends State<CardDetailScreen> {
  static const _surfaceColor = Color(0xFF171B31);
  static const _accentColor = Color(0xFF6C63FF);
  static const _rareColor = Color(0xFFFFC857);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TcgProvider>().fetchCardDetail(widget.cardId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TcgProvider>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text(provider.selectedCard?.name ?? 'Carta')),
      body: provider.isLoadingCard
          ? const Center(child: CircularProgressIndicator())
          : provider.errorMessage != null
          ? _buildStateMessage(
              icon: Icons.error_outline,
              title: 'Nao foi possivel carregar',
              message: provider.errorMessage!,
            )
          : provider.selectedCard == null
          ? _buildStateMessage(
              icon: Icons.style_outlined,
              title: 'Carta nao encontrada',
              message: 'Tente voltar e abrir outra carta.',
            )
          : _buildDetail(provider.selectedCard!),
    );
  }

  Widget _buildDetail(TcgCard card) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              MediaQuery.of(context).padding.top + 78,
              16,
              24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCardStage(card),
                const SizedBox(height: 24),
                Text(
                  card.name,
                  style: const TextStyle(
                    fontSize: 30,
                    height: 1.04,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                _buildTypeChips(card),
                const SizedBox(height: 18),
                _buildInfoCard(card),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardStage(TcgCard card) {
    final cardImage = Hero(
      tag: card.id,
      child: card.image != null
          ? CachedNetworkImage(
              imageUrl: '${card.image}/high.png',
              height: 420,
              fit: BoxFit.contain,
              placeholder: (_, _) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (_, _, _) =>
                  const Icon(Icons.image_not_supported, size: 80),
            )
          : const Icon(Icons.style, size: 80),
    );

    if (!_isFourDiamond(card)) {
      return Center(child: cardImage);
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF4B8),
              Color(0xFFFFC857),
              Color(0xFFFF9F1C),
              Color(0xFFFFF4B8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: _rareColor.withValues(alpha: 0.55),
              blurRadius: 26,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: const Color(0xFFFFF4B8).withValues(alpha: 0.34),
              blurRadius: 10,
              spreadRadius: -1,
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.45),
              width: 1.2,
            ),
          ),
          child: cardImage,
        ),
      ),
    );
  }

  bool _isFourDiamond(TcgCard card) {
    final rarity = card.rarity?.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    if (rarity == null) return false;
    return rarity.contains('fourdiamond');
  }

  Widget _buildTypeChips(TcgCard card) {
    final chips = [
      if (card.rarity != null) card.rarity!,
      if (card.category != null) card.category!,
      ...card.types,
    ];

    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: chips.map((label) => _buildChip(label)).toList(),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _rareColor.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _rareColor.withValues(alpha: 0.24)),
      ),
      child: Text(
        label,
        style: const TextStyle(color: _rareColor, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _buildInfoCard(TcgCard card) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.badge, 'ID', card.id),
          if (card.category != null)
            _buildInfoRow(Icons.category, 'Categoria', card.category!),
          if (card.rarity != null)
            _buildInfoRow(Icons.star, 'Raridade', card.rarity!),
          if (card.types.isNotEmpty)
            _buildInfoRow(Icons.bubble_chart, 'Tipos', card.types.join(', ')),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _accentColor.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 19, color: _accentColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.58),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
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
              style: TextStyle(color: Colors.white.withValues(alpha: 0.64)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
