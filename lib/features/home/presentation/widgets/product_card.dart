import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../../../catalog/domain/entities/product_entity.dart';
import '../../../wishlist/presentation/providers/favorites_provider.dart';

/// Card de producto — estilo Farfetch/Zara.
///
/// Sin bordes, sin sombras, sin elevación.
/// Imagen grande + marca + nombre + precio + botón de favorito.
class ProductCard extends ConsumerWidget {
  final ProductEntity product;
  final bool showBrand;

  const ProductCard({
    super.key,
    required this.product,
    this.showBrand = false,
  });

  static final _currencyFormat = NumberFormat.currency(
    locale: 'es_MX',
    symbol: '\$',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isFav = ref.watch(
      favoritesProvider.select((s) => s.isFavorite(product.id)),
    );

    return GestureDetector(
      onTap: () => context.push('/product/${product.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Imagen + corazón ─────────────────────────────
          AspectRatio(
            aspectRatio: 3 / 4,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.zero,
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (_, __) => Shimmer.fromColors(
                      baseColor: const Color(0xFFF0F0F0),
                      highlightColor: const Color(0xFFFAFAFA),
                      child: Container(color: Colors.white),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: const Color(0xFFF5F5F5),
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: Color(0xFFCCCCCC),
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Botón de favorito ──
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () {
                      ref.read(favoritesProvider.notifier).toggle(product.id);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFav
                            ? Icons.favorite_rounded
                            : Icons.favorite_outline_rounded,
                        size: 16,
                        color: isFav ? Colors.red.shade700 : Colors.black54,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // ── Info del producto ────────────────────────────
          Text(
            product.category.toUpperCase(),
            style: theme.textTheme.bodySmall?.copyWith(
              letterSpacing: 1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 1),

          Text(
            product.name,
            style: theme.textTheme.titleSmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),

          Text(
            _currencyFormat.format(product.minPrice),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
