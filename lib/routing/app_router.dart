import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/utils/providers.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/cart/presentation/screens/cart_screen.dart';
import '../features/cart/presentation/screens/checkout_screen.dart';
import '../features/catalog/presentation/screens/catalog_screen.dart';
import '../features/catalog/presentation/screens/product_detail_screen.dart';
import '../features/home/presentation/screens/home_shell.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/profile/presentation/screens/profile_completion_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/profile/presentation/screens/orders_screen.dart';
import '../features/profile/presentation/screens/my_coupons_screen.dart';
import '../features/wishlist/presentation/screens/wishlist_screen.dart';

/// Nombres de rutas para navegación type-safe.
class AppRoutes {
  AppRoutes._();
  static const String home = '/';
  static const String login = '/login';
  static const String catalog = '/catalog';
  static const String productDetail = '/product/:id';
  static const String cart = '/cart';
  static const String profile = '/profile';
  static const String wishlist = '/wishlist';
  static const String orders = '/orders';
  static const String checkout = '/checkout';
  static const String completeProfile = '/complete-profile';
}

/// Cache para evitar consultar Firestore en cada navegación.
/// Se resetea al cambiar el usuario autenticado.
String? _lastCheckedUid;
bool _hasProfile = false;

/// Resetea la cache del perfil (llamar después de guardar perfil).
void resetProfileCache() {
  _hasProfile = false;
}

/// Provider del router.
final routerProvider = Provider<GoRouter>((ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();

  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,

    // ── Redirect: TODAS las rutas requieren auth ─────
    redirect: (context, state) async {
      final authState = ref.read(authStateProvider);
      final currentUser = authState.valueOrNull;
      
      final isLoggedIn = currentUser != null;
      final isOnLogin = state.matchedLocation == AppRoutes.login;
      final isOnCompleteProfile =
          state.matchedLocation == AppRoutes.completeProfile;

      // Si NO está logueado → mandar a login (excepto si ya está ahí)
      if (!isLoggedIn) {
        debugPrint('AUTH: No logueado. Redirigiendo a LOGIN.');
        return isOnLogin ? null : AppRoutes.login;
      }

      // ── A partir de aquí, el usuario SÍ está logueado ──

      // Helper: verificar perfil en Firestore (con cache)
      Future<bool> ensureProfileChecked() async {
        if (_hasProfile) return true;
        try {
          final doc = await FirebaseFirestore.instance
              .collection('clients')
              .doc(currentUser.uid)
              .get();
          _hasProfile = doc.exists &&
              doc.data() != null &&
              (doc.data()!['name'] ?? '').toString().isNotEmpty;
          debugPrint('ROUTER: Perfil en Firestore: $_hasProfile');
        } catch (e) {
          debugPrint('ROUTER ERROR: Fallo al consultar perfil: $e');
          _hasProfile = false;
        }
        return _hasProfile;
      }

      // Si está en login y ya logueado → verificar perfil
      if (isOnLogin) {
        final hasProfile = await ensureProfileChecked();
        debugPrint('ROUTER: En LOGIN pero con AUTH. Perfil=$hasProfile. Redirigiendo...');
        return hasProfile ? AppRoutes.home : AppRoutes.completeProfile;
      }

      // Si está en complete-profile y ya tiene perfil → home
      if (isOnCompleteProfile) {
        final hasProfile = await ensureProfileChecked();
        debugPrint('ROUTER: En COMPLETE_PROFILE. Perfil=$hasProfile.');
        return hasProfile ? AppRoutes.home : null;
      }

      // Para CUALQUIER otra ruta, verificar perfil
      final hasProfile = await ensureProfileChecked();
      if (!hasProfile) {
        debugPrint('ROUTER: Sin perfil. Redirigiendo a COMPLETE_PROFILE.');
        return AppRoutes.completeProfile;
      }

      return null;
    },

    routes: [
      // ── Shell con Bottom Navigation ───────────────────
      ShellRoute(
        builder: (context, state, child) => HomeShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: AppRoutes.catalog,
            name: 'catalog',
            pageBuilder: (context, state) {
              final gender = state.uri.queryParameters['gender'] ?? 'Mujer';
              return NoTransitionPage(child: CatalogScreen(gender: gender));
            },
          ),
          GoRoute(
            path: '/wishlist',
            name: 'wishlist',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: WishlistScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.cart,
            name: 'cart',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CartScreen()),
          ),
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),
        ],
      ),

      // ── Login con transición fade ─────────────────────
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      ),

      GoRoute(
        path: AppRoutes.productDetail,
        name: 'productDetail',
        builder: (context, state) {
          final productId = state.pathParameters['id'] ?? '';
          return ProductDetailScreen(productId: productId);
        },
      ),
      GoRoute(
        path: AppRoutes.checkout,
        name: 'checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: AppRoutes.orders,
        name: 'orders',
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: '/my-coupons',
        name: 'myCoupons',
        builder: (context, state) => const MyCouponsScreen(),
      ),

      // ── Completar perfil con transición slide up ──────
      GoRoute(
        path: AppRoutes.completeProfile,
        name: 'completeProfile',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const ProfileCompletionScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final slideUp = Tween<Offset>(
              begin: const Offset(0, 0.15),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ));
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: slideUp, child: child),
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      ),
    ],

    // ── Error page ──────────────────────────────────────
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('404', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 8),
            Text(
              'Página no encontrada',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    ),
  );

  // Reaccionar a cambios de autenticación
  ref.listen(authStateProvider, (previous, next) {
    if (previous?.valueOrNull?.uid != next.valueOrNull?.uid) {
      _lastCheckedUid = next.valueOrNull?.uid;
      _hasProfile = false;
    }
    router.refresh();
  });

  ref.onDispose(router.dispose);

  return router;
});
