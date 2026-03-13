import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/cart_entity.dart';

/// Clave para guardar el carrito en SharedPreferences.
const _cartStorageKey = 'alonzo_cart_items';

/// Notifier del carrito de compras con persistencia local.
///
/// Gestión global del estado del carrito con operaciones CRUD.
/// Los datos se guardan automáticamente en SharedPreferences
/// para que no se pierdan al cerrar la app.
class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState()) {
    _loadCart(); // Cargar datos guardados al iniciar
  }

  /// Carga el carrito guardado desde SharedPreferences.
  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_cartStorageKey);

      if (cartJson != null) {
        final List<dynamic> decoded = jsonDecode(cartJson);
        final items = decoded
            .map((item) =>
                CartItemEntity.fromJson(item as Map<String, dynamic>))
            .toList();
        state = state.copyWith(items: items);
      }
    } catch (e) {
      // Si hay error al cargar, mantener carrito vacío
      state = const CartState();
    }
  }

  /// Guarda el estado actual del carrito en SharedPreferences.
  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson =
          jsonEncode(state.items.map((item) => item.toJson()).toList());
      await prefs.setString(_cartStorageKey, cartJson);
    } catch (_) {
      // Error silencioso al guardar
    }
  }

  /// Agrega un item al carrito.
  /// Si el item ya existe (mismo producto + talla + color), incrementa la cantidad.
  void addItem(CartItemEntity item) {
    final existingIndex = state.items.indexWhere(
      (i) => i.cartItemId == item.cartItemId,
    );

    if (existingIndex >= 0) {
      // Ya existe: incrementar cantidad
      final updatedItems = [...state.items];
      final existing = updatedItems[existingIndex];
      updatedItems[existingIndex] = existing.copyWith(
        quantity: existing.quantity + item.quantity,
      );
      state = state.copyWith(items: updatedItems);
    } else {
      // Nuevo item
      state = state.copyWith(items: [...state.items, item]);
    }
    _saveCart();
  }

  /// Elimina un item del carrito por su ID único.
  void removeItem(String cartItemId) {
    state = state.copyWith(
      items: state.items.where((i) => i.cartItemId != cartItemId).toList(),
    );
    _saveCart();
  }

  /// Actualiza la cantidad de un item.
  void updateQuantity(String cartItemId, int quantity) {
    if (quantity <= 0) {
      removeItem(cartItemId);
      return;
    }

    final updatedItems = state.items.map((item) {
      if (item.cartItemId == cartItemId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    state = state.copyWith(items: updatedItems);
    _saveCart();
  }

  /// Vacía el carrito completamente.
  void clearCart() {
    state = const CartState();
    _saveCart();
  }
}

/// Provider global del carrito.
final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});

/// Provider de conveniencia: cantidad total de items en el carrito.
final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).itemCount;
});

/// Provider de conveniencia: total del carrito.
final cartTotalProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).total;
});
