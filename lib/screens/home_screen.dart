import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/tcg_set.dart';
import '../providers/auth_provider.dart';
import '../providers/tcg_provider.dart';
import 'cards_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _surfaceColor = Color(0xFF171B31);
  static const _accentColor = Color(0xFF6C63FF);
  static const _warmAccentColor = Color(0xFFFFC857);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TcgProvider>().fetchSets();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TcgProvider>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'TCG App',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: provider.isLoadingSets
          ? const Center(child: CircularProgressIndicator())
          : provider.errorMessage != null
          ? _buildStateMessage(
              icon: Icons.error_outline,
              title: 'Algo saiu do baralho',
              message: provider.errorMessage!,
            )
          : _buildBody(provider.sets),
    );
  }

  Widget _buildBody(List<TcgSet> sets) {
    if (sets.isEmpty) {
      return _buildStateMessage(
        icon: Icons.style_outlined,
        title: 'Nenhum set encontrado',
        message: 'Tente atualizar a lista de colecoes mais tarde.',
      );
    }

    final featuredSets = sets.take(5).toList();
    final totalCards = sets.fold<int>(
      0,
      (sum, set) => sum + (set.cardCount ?? 0),
    );

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: EdgeInsets.fromLTRB(
              16,
              MediaQuery.of(context).padding.top + 76,
              16,
              20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHero(totalCards, sets.length),
                const SizedBox(height: 24),
                _buildSectionHeader(
                  title: 'Destaques',
                  subtitle: 'Colecoes para comecar a explorar',
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 210,
                  child: CarouselView(
                    itemExtent: 310,
                    shrinkExtent: 240,
                    children: featuredSets.map(_buildCarouselItem).toList(),
                  ),
                ),
                const SizedBox(height: 28),
                _buildSectionHeader(
                  title: 'Todas as colecoes',
                  subtitle: '${sets.length} sets disponiveis',
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          sliver: SliverList.separated(
            itemBuilder: (context, index) => _buildSetTile(sets[index]),
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemCount: sets.length,
          ),
        ),
      ],
    );
  }

  Widget _buildHero(int totalCards, int totalSets) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.12),
            Colors.white.withValues(alpha: 0.04),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _warmAccentColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Biblioteca TCG',
              style: TextStyle(
                color: _warmAccentColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Explore coleções, abra packs e descubra suas cartas favoritas.',
            style: TextStyle(
              fontSize: 28,
              height: 1.08,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.collections_bookmark,
                  label: 'Sets',
                  value: '$totalSets',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.style,
                  label: 'Cartas',
                  value: totalCards > 0 ? '$totalCards' : '--',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1020).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: _accentColor),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                label,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.62)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.62)),
        ),
      ],
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

  Widget _buildCarouselItem(TcgSet set) {
    return GestureDetector(
      onTap: () => _navigateToCards(set),
      child: Container(
        decoration: BoxDecoration(
          color: _surfaceColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 24,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topRight,
                    radius: 1,
                    colors: [
                      _accentColor.withValues(alpha: 0.28),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 58),
              child: set.logo != null && set.logo!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: '${set.logo}.png',
                      fit: BoxFit.contain,
                      placeholder: (_, _) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (_, _, _) =>
                          const Icon(Icons.image_not_supported),
                    )
                  : const Icon(Icons.style, size: 64),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 14,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      set.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 10),
                  _buildCountPill(set.cardCount),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountPill(int? count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        count != null ? '$count cartas' : 'Set',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildSetTile(TcgSet set) {
    return Material(
      color: _surfaceColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _navigateToCards(set),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 72,
                height: 58,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: set.logo != null && set.logo!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: '${set.logo}.png',
                        fit: BoxFit.contain,
                        errorWidget: (_, _, _) => const Icon(Icons.style),
                      )
                    : const Icon(Icons.style),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      set.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      set.cardCount != null
                          ? '${set.cardCount} cartas na colecao'
                          : 'Colecao TCG',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.58),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _accentColor.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.chevron_right, color: _accentColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToCards(TcgSet set) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CardsScreen(set: set)),
    );
  }
}
