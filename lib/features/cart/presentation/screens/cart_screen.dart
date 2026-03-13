import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/cart_entity.dart';
import '../providers/cart_provider.dart';

/// Pantalla del Carrito de Compras.
///
/// Diseño limpio inspirado en Zara:
/// - Lista de items con imagen + info + controles de cantidad
/// - Resumen de orden en la parte inferior
/// - Botón de checkout fijo
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  static final _currencyFormat = NumberFormat.currency(
    locale: 'es_MX',
    symbol: '\$',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 22),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: Text(
          'CARRITO (${cartState.itemCount})',
          style: theme.textTheme.labelLarge?.copyWith(letterSpacing: 2),
        ),
      ),
      body: cartState.isEmpty
          ? _EmptyCart()
          : Column(
              children: [
                // ── Lista de items ────────────────────────
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: cartState.items.length,
                    separatorBuilder: (_, __) =>
                        const Divider(indent: 20, endIndent: 20),
                    itemBuilder: (context, index) {
                      return _CartItemTile(item: cartState.items[index]);
                    },
                  ),
                ),

                // ── Resumen de orden ──────────────────────
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200, width: 0.5),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Subtotal', style: theme.textTheme.bodyMedium),
                          Text(
                            _currencyFormat.format(cartState.total),
                            style: theme.textTheme.titleSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Envío', style: theme.textTheme.bodyMedium),
                          Text(
                            cartState.total >= 400 ? 'GRATIS' : 'Por calcular',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cartState.total >= 400
                                  ? const Color(0xFF2E7D32)
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('TOTAL', style: theme.textTheme.labelLarge),
                          Text(
                            _currencyFormat.format(cartState.total),
                            style: theme.textTheme.titleLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          context.push('/checkout');
                        },
                        child: const Text('FINALIZAR COMPRA'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

/// Item individual del carrito.
class _CartItemTile extends ConsumerWidget {
  final CartItemEntity item;

  const _CartItemTile({required this.item});

  static final _currencyFormat = NumberFormat.currency(
    locale: 'es_MX',
    symbol: '\$',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen
          SizedBox(
            width: 100,
            height: 140,
            child: CachedNetworkImage(
              imageUrl: item.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: theme.textTheme.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item.selectedColor.isNotEmpty
                      ? '${item.selectedColor} | ${item.selectedSize}'
                      : 'Talla: ${item.selectedSize}',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  _currencyFormat.format(item.price),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),

                // Controles de cantidad
                Row(
                  children: [
                    _QuantityButton(
                      icon: Icons.remove,
                      onTap: () => ref
                          .read(cartProvider.notifier)
                          .updateQuantity(item.cartItemId, item.quantity - 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '${item.quantity}',
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    _QuantityButton(
                      icon: Icons.add,
                      onTap: () => ref
                          .read(cartProvider.notifier)
                          .updateQuantity(item.cartItemId, item.quantity + 1),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: () => ref
                          .read(cartProvider.notifier)
                          .removeItem(item.cartItemId),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}

/// Estado vacío del carrito.
class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_bag_outlined,
            size: 56,
            color: Color(0xFFCCCCCC),
          ),
          const SizedBox(height: 20),
          Text(
            'Tu carrito está vacío',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Explora nuestra colección y encuentra algo que te encante.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: OutlinedButton(
              onPressed: () {
                context.go('/catalog');
              },
              child: const Text('EXPLORAR'),
            ),
          ),
        ],
      ),
    );
  }
}
