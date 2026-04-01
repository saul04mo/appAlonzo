import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/catalog_providers.dart';
import '../../../cart/domain/entities/cart_entity.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../wishlist/presentation/providers/favorites_provider.dart';

/// Pantalla de Detalle de Producto (PDP) — estilo Zara.
///
/// Layout:
/// - Imagen de producto a pantalla completa (scrollable)
/// - Tabs: DESCRIPCIÓN, COLOR, DETALLES, MEDIDAS
/// - Selector de talla (chips cuadrados)
/// - Precio dinámico según variante seleccionada
/// - Botón AÑADIR fijo en la parte inferior
class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  String? _selectedSize;
  String? _selectedColor;

  static final _currencyFormat = NumberFormat.currency(
    locale: 'es_MX',
    symbol: '\$',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productByIdProvider(widget.productId));
    final theme = Theme.of(context);

    return productAsync.when(
      data: (product) {
        if (product == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Producto no encontrado')),
          );
        }

        // Inicializar color por defecto (puede ser null si no hay colores)
        if (_selectedColor == null && product.hasColorVariants) {
          _selectedColor = product.availableColors.first;
        }

        // Obtener variante seleccionada
        final selectedVariant = _selectedSize != null
            ? product.getVariant(_selectedSize!, _selectedColor)
            : null;

        final displayPrice = selectedVariant?.price ?? product.minPrice;
        final discountedDisplayPrice = product.discountedPrice(displayPrice);
        final hasStock =
            selectedVariant?.stock != null && selectedVariant!.stock > 0;

        return Scaffold(
          backgroundColor: Colors.white,
          body: CustomScrollView(
            slivers: [
              // ── AppBar flotante ─────────────────────────
              SliverAppBar(
                floating: true,
                snap: true,
                backgroundColor: Colors.white.withValues(alpha: 0.95),
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.close, size: 22),
                  onPressed: () => context.pop(),
                ),
                actions: [
                  Builder(
                    builder: (context) {
                      final isFav = ref.watch(
                        favoritesProvider.select(
                          (s) => s.isFavorite(product.id),
                        ),
                      );
                      return IconButton(
                        icon: Icon(
                          isFav
                              ? Icons.favorite_rounded
                              : Icons.favorite_border,
                          size: 22,
                          color: isFav ? Colors.red.shade700 : null,
                        ),
                        onPressed: () {
                          ref
                              .read(favoritesProvider.notifier)
                              .toggle(product.id);
                        },
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_outlined, size: 22),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.shopping_bag_outlined, size: 22),
                    onPressed: () => context.go('/cart'),
                  ),
                ],
              ),

              // ── Imagen del producto ─────────────────────
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 3 / 4,
                      child: CachedNetworkImage(
                        imageUrl: product.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(color: const Color(0xFFF5F5F5)),
                        errorWidget: (_, __, ___) => Container(
                          color: const Color(0xFFF5F5F5),
                          child: const Center(
                            child: Icon(Icons.image_outlined, size: 48),
                          ),
                        ),
                      ),
                    ),
                    if (product.hasOffer)
                      Positioned(
                        bottom: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.red.shade700,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text(
                            product.offer!.type == 'percentage'
                                ? '-${product.offer!.value.toStringAsFixed(0)}% OFF'
                                : '-\$${product.offer!.value.toStringAsFixed(0)} OFF',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ── Información del producto ────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tabs de info (visual, no funcional aún)
                      Row(
                        children: [
                          _InfoTab(label: 'DESCRIPCIÓN', isActive: true),
                          const SizedBox(width: 16),
                          _InfoTab(label: 'COLOR'),
                          const SizedBox(width: 16),
                          _InfoTab(label: 'DETALLES'),
                          const SizedBox(width: 16),
                          _InfoTab(label: 'MEDIDAS'),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Nombre del producto
                      Text(
                        product.name,
                        style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                      ),
                      const SizedBox(height: 12),

                      // Color/categoría actual
                      Text(
                        _selectedColor != null && _selectedColor!.isNotEmpty
                            ? '${_selectedColor!.toUpperCase()} | ${product.category}'
                            : product.category,
                        style: theme.textTheme.bodySmall?.copyWith(
                          letterSpacing: 0.5,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Selector de color (solo si hay colores definidos) ──
                      if (product.hasColorVariants) ...[
                        Text('COLOR', style: theme.textTheme.labelMedium),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children: product.availableColors.map((color) {
                            final isSelected = color == _selectedColor;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedColor = color;
                                  _selectedSize = null; // Reset talla
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.black
                                        : const Color(0xFFE0E0E0),
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Text(
                                  color.toUpperCase(),
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: isSelected
                                        ? Colors.black
                                        : const Color(0xFF9E9E9E),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // ── Selector de tallas ─────────────
                      Text('TALLA', style: theme.textTheme.labelMedium),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: product.availableSizes.map((size) {
                          final isSelected = size == _selectedSize;
                          final variant = product.getVariant(
                            size,
                            _selectedColor,
                          );
                          final inStock = variant != null && variant.stock > 0;

                          return GestureDetector(
                            onTap: inStock
                                ? () => setState(() => _selectedSize = size)
                                : null,
                            child: Container(
                              width: 56,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.black : Colors.white,
                                border: Border.all(
                                  color: !inStock
                                      ? const Color(0xFFEEEEEE)
                                      : isSelected
                                      ? Colors.black
                                      : const Color(0xFFE0E0E0),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                size,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: !inStock
                                      ? const Color(0xFFCCCCCC)
                                      : isSelected
                                      ? Colors.white
                                      : Colors.black,
                                  decoration: !inStock
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 100), // Espacio para el botón fijo
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Botón AÑADIR fijo ───────────────────────────
          bottomNavigationBar: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                // Botón AÑADIR
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedSize != null && hasStock
                        ? () {
                            ref
                                .read(cartProvider.notifier)
                                .addItem(
                                  CartItemEntity(
                                    productId: product.id,
                                    productName: product.name,
                                    imageUrl: product.imageUrl,
                                    selectedSize: _selectedSize ?? '',
                                    selectedColor: _selectedColor ?? '',
                                    price: selectedVariant.price,
                                    barcode: selectedVariant.barcode,
                                    offerType: product.offer?.type ?? '',
                                    offerValue: product.offer?.value ?? 0,
                                  ),
                                );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('AÑADIDO AL CARRITO'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      disabledBackgroundColor: const Color(0xFFE0E0E0),
                      disabledForegroundColor: const Color(0xFF9E9E9E),
                    ),
                    child: Text(
                      _selectedSize == null ? 'SELECCIONA TALLA' : 'AÑADIR',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Precio (con oferta si aplica)
                if (product.hasOffer)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _currencyFormat.format(discountedDisplayPrice),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        _currencyFormat.format(displayPrice),
                        style: theme.textTheme.bodySmall?.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    _currencyFormat.format(displayPrice),
                    style: theme.textTheme.titleLarge,
                  ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator(strokeWidth: 1)),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
      ),
    );
  }
}

/// Tab de información en el PDP — estilo Zara.
class _InfoTab extends StatelessWidget {
  final String label;
  final bool isActive;

  const _InfoTab({required this.label, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: isActive ? Colors.black : const Color(0xFF9E9E9E),
        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
      ),
    );
  }
}
