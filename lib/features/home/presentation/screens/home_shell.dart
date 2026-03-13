import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../cart/presentation/providers/cart_provider.dart';

/// Notifier global para que las pantallas hijas reporten la dirección de scroll.
final scrollDirectionProvider =
    StateProvider<ScrollDirection>((ref) => ScrollDirection.idle);

/// Shell principal con Bottom Navigation Bar.
///
/// El nav bar se oculta al hacer scroll hacia abajo
/// y reaparece al hacer scroll hacia arriba (estilo Farfetch).
class HomeShell extends ConsumerStatefulWidget {
  final Widget child;

  const HomeShell({super.key, required this.child});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<Offset> _slideAnim;

  static const _tabs = [
    (icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home', path: '/'),
    (icon: Icons.menu_rounded, activeIcon: Icons.menu_rounded, label: 'Comprar', path: '/catalog'),
    (icon: Icons.shopping_bag_outlined, activeIcon: Icons.shopping_bag_rounded, label: 'Carrito', path: '/cart'),
    (icon: Icons.favorite_outline_rounded, activeIcon: Icons.favorite_rounded, label: 'Mi lista', path: '/wishlist'),
    (icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Mi cuenta', path: '/profile'),
  ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _slideAnim = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 1), // slide down to hide
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < _tabs.length; i++) {
      if (location == _tabs[i].path) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);
    final cartCount = ref.watch(cartItemCountProvider);

    // Escuchar la dirección de scroll para ocultar/mostrar nav bar
    ref.listen<ScrollDirection>(scrollDirectionProvider, (prev, next) {
      if (next == ScrollDirection.reverse) {
        // Scrolling down → hide
        _animCtrl.forward();
      } else if (next == ScrollDirection.forward) {
        // Scrolling up → show
        _animCtrl.reverse();
      }
    });

    return Scaffold(
      extendBody: true,
      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          final direction = notification.direction;
          if (direction == ScrollDirection.forward ||
              direction == ScrollDirection.reverse) {
            ref.read(scrollDirectionProvider.notifier).state = direction;
          }
          return false;
        },
        child: widget.child,
      ),
      bottomNavigationBar: SlideTransition(
        position: _slideAnim,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) => context.go(_tabs[index].path),
            items: _tabs.asMap().entries.map((entry) {
              final tab = entry.value;
              final isCart = tab.path == '/cart';

              return BottomNavigationBarItem(
                icon: isCart && cartCount > 0
                    ? Badge(
                        label: Text(
                          '$cartCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        backgroundColor: Colors.black,
                        child: Icon(tab.icon),
                      )
                    : Icon(tab.icon),
                activeIcon: isCart && cartCount > 0
                    ? Badge(
                        label: Text(
                          '$cartCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        backgroundColor: Colors.black,
                        child: Icon(tab.activeIcon),
                      )
                    : Icon(tab.activeIcon),
                label: tab.label,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
