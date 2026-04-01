import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../routing/app_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/domain/entities/user_profile_entity.dart';
import '../providers/user_profile_provider.dart';

/// Pantalla para completar el perfil del usuario.
///
/// Flujo:
/// 1. El usuario ingresa su cédula/RIF
/// 2. Se busca en Firestore (colección 'clients') si ya existe
/// 3. Si existe, se auto-rellenan los campos
/// 4. El usuario confirma y guarda
/// 5. El email se toma automáticamente del usuario autenticado
class ProfileCompletionScreen extends ConsumerStatefulWidget {
  const ProfileCompletionScreen({super.key});

  @override
  ConsumerState<ProfileCompletionScreen> createState() =>
      _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState
    extends ConsumerState<ProfileCompletionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _rifCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  bool _isSearching = false;
  bool _clientFound = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = ref.read(userProfileProvider).profile;
      if (profile.rifCi.isNotEmpty) _rifCtrl.text = profile.rifCi;
      if (profile.name.isNotEmpty) _nameCtrl.text = profile.name;
      if (profile.phone.isNotEmpty) _phoneCtrl.text = profile.phone;
      if (profile.address.isNotEmpty) _addressCtrl.text = profile.address;
    });
  }

  @override
  void dispose() {
    _rifCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  /// Busca un cliente en Firestore por cédula/RIF.
  Future<void> _searchByCedula() async {
    final cedula = _rifCtrl.text.trim();
    if (cedula.isEmpty) return;

    setState(() {
      _isSearching = true;
      _clientFound = false;
    });

    try {
      final data =
          await ref.read(userProfileRepositoryProvider).searchByRifCi(cedula);

      if (data != null) {
        setState(() {
          _clientFound = true;
          _nameCtrl.text = data['name'] as String? ?? '';
          _phoneCtrl.text = data['phone'] as String? ?? '';
          _addressCtrl.text = data['address'] as String? ?? '';
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Expanded(child: Text('¡Cliente encontrado! Datos cargados.')),
                ],
              ),
              backgroundColor: Colors.black87,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        setState(() => _clientFound = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Expanded(child: Text('Cliente nuevo. Completa tus datos.')),
                ],
              ),
              backgroundColor: Colors.grey.shade800,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al buscar: $e'),
            backgroundColor: const Color(0xFFB00020),
          ),
        );
      }
    } finally {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final repo = ref.read(userProfileRepositoryProvider);
    final cedula = _rifCtrl.text.trim();
    final authUser = ref.read(authNotifierProvider).user;
    final currentUid = authUser?.uid;

    // Verificar que la cédula no esté registrada por otro usuario CON correo
    if (cedula.isNotEmpty && currentUid != null) {
      try {
        final existing = await repo.searchByRifCi(cedula);
        if (existing != null && existing['id'] != currentUid) {
          final existingEmail =
              (existing['email'] as String? ?? '').trim();
          if (existingEmail.isNotEmpty) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Esta cédula ya está registrada con otra cuenta.',
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: const Color(0xFFB00020),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            }
            return;
          }

          // ── Migrar facturas del cliente POS al nuevo UID ──
          try {
            final oldClientId = existing['id'] as String;
            final invoicesSnap = await FirebaseFirestore.instance
                .collection('invoices')
                .where('clientId', isEqualTo: oldClientId)
                .get();

            if (invoicesSnap.docs.isNotEmpty) {
              final batch = FirebaseFirestore.instance.batch();
              for (final invDoc in invoicesSnap.docs) {
                batch.update(invDoc.reference, {
                  'clientId': currentUid,
                  'linkedFromPOS': oldClientId,
                });
              }
              await batch.commit();

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.link, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '¡Perfil vinculado! ${invoicesSnap.docs.length} pedidos anteriores encontrados.',
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.black87,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            }
          } catch (_) {
            // Si falla la migración, continuar con el guardado
          }
        }
      } catch (_) {
        // Si falla la verificación, continuar con el guardado
      }
    }

    final authEmail = authUser?.email ?? '';

    final profile = UserProfile(
      name: _nameCtrl.text.trim().toUpperCase(),
      email: authEmail,
      phone: _phoneCtrl.text.trim(),
      rifCi: cedula,
      address: _addressCtrl.text.trim().toUpperCase(),
    );

    final success =
        await ref.read(userProfileProvider.notifier).saveProfile(profile);

    if (success && mounted) {
      resetProfileCache();
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileState = ref.watch(userProfileProvider);
    final authUser = ref.watch(authNotifierProvider).user;
    final authEmail = authUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'COMPLETA TU PERFIL',
          style: theme.textTheme.labelLarge?.copyWith(letterSpacing: 2),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header ─────────────────────────────
                      Text(
                        'DATOS PERSONALES',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ingresa tu cédula para buscar tus datos. Si eres nuevo, completa el formulario.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF757575),
                        ),
                      ),

                      // ── Email del usuario (solo lectura) ──
                      if (authEmail.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.email_outlined,
                                size: 18,
                                color: Color(0xFF757575),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  authEmail,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: const Color(0xFF424242),
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.lock_outline,
                                size: 14,
                                color: Color(0xFF9E9E9E),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 28),

                      // ── 1. CÉDULA / RIF ───────────────────
                      _buildLabel('RIF / CÉDULA'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _rifCtrl,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          hintText: 'Ej: 25718928',
                          hintStyle: TextStyle(color: Color(0xFFBDBDBD)),
                          prefixIcon: Icon(Icons.badge_outlined, size: 20),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                        ),
                        validator: (val) => (val == null || val.trim().isEmpty)
                            ? 'Ingresa tu cédula'
                            : null,
                        onFieldSubmitted: (_) => _searchByCedula(),
                      ),
                      const SizedBox(height: 12),

                      // ── Botón buscar ──
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _isSearching ? null : _searchByCedula,
                          icon: _isSearching
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                  ),
                                )
                              : const Icon(Icons.search, size: 18),
                          label: Text(
                            _isSearching ? 'BUSCANDO...' : 'BUSCAR CLIENTE',
                          ),
                        ),
                      ),

                      // ── Indicador de cliente encontrado ──
                      if (_clientFound)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xFF4CAF50),
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Cliente registrado — datos cargados',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFF4CAF50),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 24),
                      const Divider(height: 1),
                      const SizedBox(height: 24),

                      // ── 2. Nombre ─────────────────────────
                      _buildLabel('NOMBRE COMPLETO'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Ej: María Aurora Esteban',
                          hintStyle: TextStyle(color: Color(0xFFBDBDBD)),
                          prefixIcon: Icon(Icons.person_outline, size: 20),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                        ),
                        validator: (val) => (val == null || val.trim().isEmpty)
                            ? 'Este campo es requerido'
                            : null,
                      ),
                      const SizedBox(height: 20),

                      // ── 3. Teléfono ───────────────────────
                      _buildLabel('TELÉFONO'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          hintText: 'Ej: 04141234567',
                          hintStyle: TextStyle(color: Color(0xFFBDBDBD)),
                          prefixIcon: Icon(Icons.phone_outlined, size: 20),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                        ),
                        validator: (val) => (val == null || val.trim().isEmpty)
                            ? 'Este campo es requerido'
                            : null,
                      ),
                      const SizedBox(height: 20),

                      // ── 4. Dirección ──────────────────────
                      _buildLabel('DIRECCIÓN'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _addressCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText: 'Ej: Av. Principal, Edificio...',
                          hintStyle: TextStyle(color: Color(0xFFBDBDBD)),
                          prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                        ),
                      ),

                      // ── Error ─────────────────────────────
                      if (profileState.errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          profileState.errorMessage!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),

            // ── Botón guardar ────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: profileState.isSaving ? null : _save,
                  child: profileState.isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text('GUARDAR'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: const Color(0xFF616161),
            letterSpacing: 1,
          ),
    );
  }
}
