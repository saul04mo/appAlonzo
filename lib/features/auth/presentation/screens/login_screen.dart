import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../profile/presentation/providers/user_profile_provider.dart';

/// Pantalla de Login — minimalista, estilo premium.
///
/// Layout:
/// - Logo ALONZO centrado
/// - Campos de email y contraseña
/// - Botón de login
/// - Separador "o"
/// - Botón de Google Sign-In
/// - Link a crear cuenta
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) return;

    if (_isSignUp) {
      ref.read(authNotifierProvider.notifier).createAccount(email, password);
    } else {
      ref.read(authNotifierProvider.notifier).signInWithEmail(email, password);
    }
  }

  /// Verifica si el usuario tiene perfil en la colección 'clients'.
  Future<void> _checkProfileAndRedirect() async {
    try {
      final hasProfile =
          await ref.read(userProfileRepositoryProvider).checkProfileExists();
      if (mounted) {
        context.go(hasProfile ? '/' : '/complete-profile');
      }
    } catch (_) {
      if (mounted) context.go('/complete-profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final theme = Theme.of(context);

    // Redirect: verificar perfil después de autenticación
    ref.listen(authNotifierProvider, (_, next) {
      if (next.status == AuthStatus.authenticated) {
        _checkProfileAndRedirect();
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Logo ──────────────────────────────────
                Image.asset(
                  'assets/images/logoAlonzo.png',
                  height: 80,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 56),

                // ── Campos ────────────────────────────────
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                  ),
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 24),

                // ── Error ─────────────────────────────────
                if (authState.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      authState.errorMessage!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),

                // ── Botón principal ───────────────────────
                ElevatedButton(
                  onPressed:
                      authState.status == AuthStatus.loading ? null : _submit,
                  child: authState.status == AuthStatus.loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(_isSignUp ? 'CREAR CUENTA' : 'INICIAR SESIÓN'),
                ),
                const SizedBox(height: 24),

                // ── Divider "o" ───────────────────────────
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'o',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Google Sign-In ────────────────────────
                OutlinedButton.icon(
                  onPressed: authState.status == AuthStatus.loading
                      ? null
                      : () => ref
                          .read(authNotifierProvider.notifier)
                          .signInWithGoogle(),
                  icon: const Text(
                    'G',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  label: const Text('CONTINUAR CON GOOGLE'),
                ),
                const SizedBox(height: 32),

                // ── Toggle signup/login ───────────────────
                GestureDetector(
                  onTap: () => setState(() => _isSignUp = !_isSignUp),
                  child: Text(
                    _isSignUp
                        ? '¿Ya tienes cuenta? Inicia sesión'
                        : '¿No tienes cuenta? Crear cuenta',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
