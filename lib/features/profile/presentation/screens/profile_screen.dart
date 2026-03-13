import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/user_profile_provider.dart';

/// Pantalla de Perfil / Mi Cuenta — rediseño premium.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final profileState = ref.watch(userProfileProvider);
    final theme = Theme.of(context);
    final user = authState.user;
    final profile = profileState.profile;

    final initials = (profile.name.isNotEmpty ? profile.name : user?.displayName ?? 'U')
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    return Scaffold(
      appBar: AppBar(
        title: const SizedBox.shrink(),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 22),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, size: 22),
            onPressed: () => context.go('/cart'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          // ── Header con avatar ───────────────────────────
          const SizedBox(height: 8),
          Row(
            children: [
              // Avatar con iniciales
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.surfaceContainerHighest,
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w300,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Nombre y email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name.isNotEmpty ? profile.name : (user?.displayName ?? 'Invitado'),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.email.isNotEmpty ? profile.email : (user?.email ?? ''),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // ── Información personal ────────────────────────
          _SectionHeader(title: 'Información personal'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.badge_outlined,
                  label: 'Cédula / RIF',
                  value: profile.rifCi.isNotEmpty ? profile.rifCi : '—',
                ),
                const Divider(height: 24),
                _InfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Teléfono',
                  value: profile.phone.isNotEmpty ? profile.phone : '—',
                ),
                const Divider(height: 24),
                _InfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'Dirección',
                  value: profile.address.isNotEmpty ? profile.address : '—',
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ── Mi cuenta ──────────────────────────────────
          _SectionHeader(title: 'Mi cuenta'),
          const SizedBox(height: 8),
          _ProfileMenuItem(
            icon: Icons.receipt_long_outlined,
            label: 'Pedidos y devoluciones',
            onTap: () => context.push('/orders'),
          ),
          _ProfileMenuItem(
            icon: Icons.shield_outlined,
            label: 'Detalles y seguridad',
            onTap: () {},
          ),
          _ProfileMenuItem(
            icon: Icons.location_on_outlined,
            label: 'Direcciones',
            onTap: () {},
          ),
          _ProfileMenuItem(
            icon: Icons.edit_outlined,
            label: 'Editar perfil',
            onTap: () => context.push('/complete-profile'),
          ),

          const SizedBox(height: 32),

          // ── Soporte ────────────────────────────────────
          _SectionHeader(title: 'Soporte'),
          const SizedBox(height: 8),
          _ProfileMenuItem(
            icon: Icons.help_outline_rounded,
            label: 'Centro de ayuda',
            onTap: () {},
          ),
          _ProfileMenuItem(
            icon: Icons.policy_outlined,
            label: 'Términos y condiciones',
            onTap: () {},
          ),

          const SizedBox(height: 40),

          // ── Cerrar sesión ──────────────────────────────
          if (user != null)
            Center(
              child: TextButton.icon(
                onPressed: () =>
                    ref.read(authNotifierProvider.notifier).signOut(),
                icon: Icon(
                  Icons.logout_rounded,
                  size: 18,
                  color: theme.colorScheme.error,
                ),
                label: Text(
                  'Cerrar sesión',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

          const SizedBox(height: 16),

          // ── Versión ────────────────────────────────────
          Center(
            child: Text(
              'v1.0.0',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

/// Header de sección.
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
    );
  }
}

/// Fila de información (icono + label + valor).
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Item del menú de perfil con icono.
class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
        ),
        Divider(
          height: 0,
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ],
    );
  }
}
