import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../home/presentation/widgets/product_card.dart';
import '../../domain/entities/product_entity.dart';
import '../providers/catalog_providers.dart';

/// Pantalla de Catálogo — inspirada en Zara.
///
/// Dos modos de acceso:
/// 1. Vista "Comprar" con opciones Marcas/Categorías
/// 2. Grilla de productos filtrada por género
class CatalogScreen extends ConsumerStatefulWidget {
// ... resto del archivo omitido para el inicio y pasamos al header ...

  final String gender;

  const CatalogScreen({super.key, this.gender = 'Mujer'});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _genders = [
    (label: 'MUJER', value: 'Mujer'),
    (label: 'HOMBRE', value: 'Hombre'),
  ];

  @override
  void initState() {
    super.initState();
    final initialIndex =
        _genders.indexWhere((g) => g.value == widget.gender).clamp(0, 1);
    _tabController = TabController(
      length: _genders.length,
      vsync: this,
      initialIndex: initialIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/logoAlonzo.png',
          height: 32,
          fit: BoxFit.contain,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 22),
            onPressed: () {}, // TODO: Search
          ),
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, size: 22),
            onPressed: () => context.go('/cart'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: _genders.map((g) => Tab(text: g.label)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _genders.map((g) => _ProductGrid(gender: g.value)).toList(),
      ),
    );
  }
}

/// Grilla de productos 2 columnas con lazy loading.
class _ProductGrid extends ConsumerWidget {
  final String gender;

  const _ProductGrid({required this.gender});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsByGenderProvider(gender));

    return productsAsync.when(
      data: (products) {
        if (products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.shopping_bag_outlined,
                  size: 48,
                  color: Color(0xFFCCCCCC),
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay productos disponibles',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          );
        }

        // Agrupar productos por categoría
        final Map<String, List<ProductEntity>> groupedProducts = {};
        for (final product in products) {
          final cat = product.category.toUpperCase();
          if (!groupedProducts.containsKey(cat)) {
            groupedProducts[cat] = [];
          }
          groupedProducts[cat]!.add(product);
        }

        // Ordenar categorías alfabéticamente
        final sortedCategories = groupedProducts.keys.toList()..sort();

        return AnimationLimiter(
          child: CustomScrollView(
            slivers: sortedCategories.map((category) {
              final categoryProducts = groupedProducts[category]!;

              return SliverMainAxisGroup(
                slivers: [
                  // Header de la categoría
                  // Header de la categoría
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _CategoryHeaderDelegate(
                      category: category,
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    ),
                  ),
                  // Grilla de productos de esa categoría
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.50, // Espacio para la imagen y el texto
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 24,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return AnimationConfiguration.staggeredGrid(
                            position: index,
                            columnCount: 2,
                            duration: const Duration(milliseconds: 400),
                            child: FadeInAnimation(
                              child: SlideAnimation(
                                verticalOffset: 30,
                                child: ProductCard(
                                  // No mostrar marca en el catálogo porque ya está por categoría/género
                                  product: categoryProducts[index],
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: categoryProducts.length,
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(strokeWidth: 1),
      ),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Error al cargar productos: $error',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

/// Delegate para el header fijo (sticky header) de cada categoría.
class _CategoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String category;
  final Color backgroundColor;

  _CategoryHeaderDelegate({
    required this.category,
    required this.backgroundColor,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: 12,
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        category,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w500,
              letterSpacing: 2,
            ),
      ),
    );
  }

  @override
  double get maxExtent => 64.0;

  @override
  double get minExtent => 64.0;

  @override
  bool shouldRebuild(covariant _CategoryHeaderDelegate oldDelegate) {
    return category != oldDelegate.category ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
