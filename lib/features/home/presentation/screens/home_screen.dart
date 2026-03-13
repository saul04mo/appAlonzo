import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../providers/banner_provider.dart';
import '../widgets/product_card.dart';

/// Pantalla principal — Home.
///
/// Layout inspirado en Farfetch:
/// - Carrusel de imágenes con auto-scroll
/// - Sección "En tendencia" con scroll horizontal
/// - Acceso rápido por género
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final PageController _pageCtrl = PageController();
  Timer? _autoScrollTimer;
  int _currentPage = 0;

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  void _startAutoScroll(int totalPages) {
    _autoScrollTimer?.cancel();
    if (totalPages <= 1) return;

    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      _currentPage = (_currentPage + 1) % totalPages;
      if (_pageCtrl.hasClients) {
        _pageCtrl.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final womenProducts = ref.watch(womenProductsProvider);
    final bannerAsync = ref.watch(bannerProvider);

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
            onPressed: () {
              // TODO: Navegar a búsqueda
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, size: 22),
            onPressed: () => context.go('/cart'),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [

          // ── Carrusel de Imágenes ────────────────────────
          SliverToBoxAdapter(
            child: bannerAsync.when(
              data: (slides) {
                if (slides.isEmpty) {
                  return AspectRatio(
                    aspectRatio: 3 / 4,
                    child: Container(
                      color: const Color(0xFFF0EDE8),
                      child: const Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 64,
                          color: Color(0xFFCCCCCC),
                        ),
                      ),
                    ),
                  );
                }

                // Iniciar auto-scroll
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _startAutoScroll(slides.length);
                });

                return AspectRatio(
                  aspectRatio: 3 / 4,
                  child: Stack(
                    children: [
                      // ── PageView con slides ──
                      PageView.builder(
                        controller: _pageCtrl,
                        itemCount: slides.length,
                        onPageChanged: (index) {
                          setState(() => _currentPage = index);
                        },
                        itemBuilder: (context, index) {
                          final slide = slides[index];
                          return Container(
                            color: const Color(0xFFF0EDE8),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                // Imagen
                                CachedNetworkImage(
                                  imageUrl: slide.imageUrl,
                                  fit: BoxFit.cover,
                                  fadeInDuration:
                                      const Duration(milliseconds: 300),
                                  placeholder: (_, __) => const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1,
                                    ),
                                  ),
                                  errorWidget: (_, __, ___) => const Center(
                                    child: Icon(
                                      Icons.image_outlined,
                                      size: 64,
                                      color: Color(0xFFCCCCCC),
                                    ),
                                  ),
                                ),
                                // Overlay con texto (si tiene título)
                                if (slide.title.isNotEmpty)
                                  Positioned(
                                    bottom: 40,
                                    left: 20,
                                    right: 20,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          slide.title,
                                          style: theme
                                              .textTheme.displayLarge
                                              ?.copyWith(
                                            fontSize: 36,
                                            letterSpacing: 2,
                                            height: 1.1,
                                            color: Colors.white,
                                            shadows: [
                                              const Shadow(
                                                blurRadius: 8,
                                                color: Colors.black38,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        SizedBox(
                                          width: 160,
                                          child: OutlinedButton(
                                            onPressed: () =>
                                                context.go(slide.route),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Colors.white,
                                              side: const BorderSide(
                                                color: Colors.white,
                                              ),
                                            ),
                                            child: Text(slide.subtitle),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),

                      // ── Indicadores de página ──
                      if (slides.length > 1)
                        Positioned(
                          bottom: 12,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(slides.length, (i) {
                              final isActive = i == _currentPage;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 3),
                                width: isActive ? 20 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? Colors.white
                                      : Colors.white54,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              );
                            }),
                          ),
                        ),
                    ],
                  ),
                );
              },
              loading: () => const AspectRatio(
                aspectRatio: 3 / 4,
                child: Center(
                  child: CircularProgressIndicator(strokeWidth: 1),
                ),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),

          // ── Sección: En tendencia ───────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                AppStrings.trending,
                style: theme.textTheme.headlineLarge,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Carousel horizontal de productos
          SliverToBoxAdapter(
            child: SizedBox(
              height: 350,
              child: womenProducts.when(
                data: (products) {
                  if (products.isEmpty) {
                    return const Center(
                      child: Text('No hay productos aún'),
                    );
                  }
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: products.take(8).length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return SizedBox(
                        width: 200,
                        child: ProductCard(product: product),
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(strokeWidth: 1),
                ),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 48)),

          // ── Sección: Recomendados para ti ────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recomendados para ti',
                    style: theme.textTheme.headlineLarge,
                  ),
                  TextButton(
                    onPressed: () => context.go('/catalog?gender=Hombre'),
                    child: Text(
                      'Ver todo',
                      style: theme.textTheme.labelMedium?.copyWith(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // Grilla 2 columnas de productos recomendados
          ref.watch(menProductsProvider).when(
                data: (products) {
                  if (products.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Center(child: Text('No hay productos aún')),
                    );
                  }
                  final recommended = products.take(6).toList();
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.58,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            ProductCard(product: recommended[index]),
                        childCount: recommended.length,
                      ),
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 1),
                  ),
                ),
                error: (e, _) =>
                    SliverToBoxAdapter(child: Center(child: Text('Error: $e'))),
              ),

          const SliverToBoxAdapter(child: SizedBox(height: 48)),

          // ── Accesos rápidos por género ──────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _GenderAccessTile(
                    label: 'Ropa de mujer',
                    onTap: () => context.go('/catalog?gender=Mujer'),
                  ),
                  const Divider(),
                  _GenderAccessTile(
                    label: 'Ropa de hombre',
                    onTap: () => context.go('/catalog?gender=Hombre'),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 60)),
        ],
      ),
    );
  }
}

/// Tile de acceso por género — estilo Farfetch.
class _GenderAccessTile extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _GenderAccessTile({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}

