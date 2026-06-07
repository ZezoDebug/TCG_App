import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/tcg_provider.dart';
import '../models/tcg_card.dart';

class CardDetailScreen extends StatefulWidget {
  final String cardId;

  const CardDetailScreen({super.key, required this.cardId});

  @override
  State<CardDetailScreen> createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends State<CardDetailScreen> {
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
      appBar: AppBar(
        title: Text(provider.selectedCard?.name ?? 'Carta'),
        centerTitle: true,
      ),
      body: provider.isLoadingCard
          ? const Center(child: CircularProgressIndicator())
          : provider.errorMessage != null
              ? Center(child: Text(provider.errorMessage!))
              : provider.selectedCard == null
                  ? const Center(child: Text('Carta não encontrada'))
                  : _buildDetail(provider.selectedCard!),
    );
  }

  Widget _buildDetail(TcgCard card) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (card.image != null)
            Hero(
              tag: card.id,
              child: CachedNetworkImage(
                imageUrl: '${card.image}/high.png',
                height: 350,
                fit: BoxFit.contain,
                placeholder: (_, _) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (_, _, _) =>
                    const Icon(Icons.image_not_supported, size: 80),
              ),
            ),
          const SizedBox(height: 24),
          Text(
            card.name,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _buildInfoCard(card),
        ],
      ),
    );
  }

  Widget _buildInfoCard(TcgCard card) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (card.category != null)
              _buildInfoRow(Icons.category, 'Categoria', card.category!),
            if (card.rarity != null)
              _buildInfoRow(Icons.star, 'Raridade', card.rarity!),
            _buildInfoRow(Icons.badge, 'ID', card.id),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
