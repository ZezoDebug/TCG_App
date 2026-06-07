import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/tcg_provider.dart';
import '../models/tcg_set.dart';
import 'cards_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState(){
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
      appBar: AppBar(
        title: const Text('TCG App'),
        centerTitle: true,
      ),
      body: provider.isLoadingSets
          ? const Center(child: CircularProgressIndicator(),)
          : provider.errorMessage != null
              ? Center(child: Text(provider.errorMessage!))
              : _buildBody(provider.sets),
    );
  }

  Widget _buildBody(List<TcgSet> sets) {
    if (sets.isEmpty) {
      return const Center(child: Text('Nenhum set encontrado'));
    }

    final featuredSets = sets.take(5).toList();
    final allSets = sets;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Destaques',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 180,
                  child: CarouselView(
                    itemExtent: 280, 
                    children: featuredSets.map((set) {
                      return _buildCarouselItem(set);
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Todas as Coleções',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildSetTile(allSets[index]),
            childCount:  allSets.length,
          ),
        ),
      ],
    );
  }

  Widget _buildCarouselItem(TcgSet set) {
    return GestureDetector(
      onTap: () => _navigateToCards(set),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (set.logo != null)
              CachedNetworkImage(
                imageUrl: '${set.logo}.png',
                fit: BoxFit.contain,
                placeholder: (_, _) => 
                  const Center(child: CircularProgressIndicator()),
                errorWidget: (_, _, _) => 
                  const Icon(Icons.image_not_supported),
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black54,
                padding: const EdgeInsets.all(8),
                child: Text(
                  set.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetTile(TcgSet set) {
    return ListTile(
      leading: set.logo != null
          ? SizedBox(
              width: 60,
              child:  CachedNetworkImage(
                imageUrl: '${set.logo}.png',
                fit: BoxFit.contain,
                errorWidget: (_, _, _) =>
                    const Icon(Icons.style),
              ),
            )
          : const Icon(Icons.style),
      title: Text(set.name),
      subtitle: set.cardCount != null
          ? Text('${set.cardCount} cartas')
          : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _navigateToCards(set),
    );
  }

  void _navigateToCards(TcgSet set) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CardsScreen(set: set),
      ),
    );
  }
}
