import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../cart/presentation/providers/checkout_provider.dart';
import '../../../auth/domain/entities/user_profile_entity.dart';
import '../../../profile/presentation/providers/user_profile_provider.dart';

/// Pantalla única de Resumen de Compra.
///
/// Todo en una sola vista scrolleable:
/// - Datos personales (RIF/CI, Nombre, Teléfono)
/// - Dirección de entrega
/// - Método de envío (dropdown)
/// - Método de pago (grid de íconos)
/// - Desglose de precios (subtotal, descuento, envío, total USD/Bs)
/// - Botón confirmar
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _rifCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  String _deliveryMethod = 'Retiro en tienda (GRATIS)';
  String? _selectedPayment;
  bool _isProcessing = false;
  bool _orderConfirmed = false;
  String? _orderId;
  int? _numericId;
  bool _profilePopulated = false;

  static const _deliveryOptions = [
    'Retiro en tienda (GRATIS)',
    'Envío a domicilio',
  ];

  static const _paymentMethods = [
    ('Pago Móvil', Icons.phone_android_outlined),
    ('Zelle', Icons.account_balance_outlined),
    ('Efectivo (\$)', Icons.attach_money),
    ('Binance', Icons.currency_bitcoin),
    ('Zinli', Icons.credit_card_outlined),
    ('PayPal', Icons.paypal_outlined),
  ];

  static final _currency = NumberFormat.currency(
    locale: 'es_MX',
    symbol: '\$',
    decimalDigits: 2,
  );

  @override
  void dispose() {
    _rifCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  /// Llena los campos con datos del perfil cuando estén disponibles.
  void _populateFromProfile(UserProfile profile) {
    if (_profilePopulated) return;
    if (profile.name.isEmpty && profile.phone.isEmpty) return;
    _profilePopulated = true;
    if (profile.name.isNotEmpty) _nameCtrl.text = profile.name;
    if (profile.phone.isNotEmpty) _phoneCtrl.text = profile.phone;
    if (profile.rifCi.isNotEmpty) _rifCtrl.text = profile.rifCi;
    if (profile.address.isNotEmpty) _addressCtrl.text = profile.address;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cartState = ref.watch(cartProvider);
    final checkoutState = ref.watch(checkoutProvider);
    final profileState = ref.watch(userProfileProvider);

    // Auto-llenar con datos del perfil cuando estén disponibles
    _populateFromProfile(profileState.profile);

    // Si ya se confirmó
    if (_orderConfirmed) {
      return _buildConfirmed(theme);
    }

    // Si está procesando
    if (_isProcessing) {
      return _buildProcessing(theme);
    }

    final isDelivery = _deliveryMethod == 'Envío a domicilio';
    final deliveryCost = checkoutState.couponFreeShipping ? 0.0 :
        (isDelivery ? checkoutState.deliveryCostUsd : 0.0);
    final subtotal = cartState.total; // already includes offer discounts
    final offerSaved = cartState.totalSaved;
    final couponDiscount = checkoutState.couponDiscount;
    final total = subtotal - couponDiscount + deliveryCost;
    final rate = checkoutState.exchangeRate;
    final totalBs = rate > 0 ? total * rate : 0.0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 22),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'RESUMEN DE COMPRA',
          style: theme.textTheme.labelLarge?.copyWith(letterSpacing: 2),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ─────────────────────────────
                    Text(
                      'VERIFICA TUS DATOS Y PAGO ANTES DE FINALIZAR',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Datos personales ───────────────────
                    _InputField(
                      label: 'RIF / CI',
                      hint: 'V12345678',
                      controller: _rifCtrl,
                    ),
                    const SizedBox(height: 16),
                    _InputField(
                      label: 'NOMBRE',
                      hint: 'TU NOMBRE',
                      controller: _nameCtrl,
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),
                    _InputField(
                      label: 'TELÉFONO',
                      hint: '0412...',
                      controller: _phoneCtrl,
                      isNumeric: true,
                      isRequired: true,
                    ),

                    const SizedBox(height: 24),

                    // ── Dirección de entrega ───────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'DIRECCIÓN DE ENTREGA',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _addressCtrl,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              hintText: 'CONFIRMA TU DIRECCIÓN AQUÍ...',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Método de envío ────────────────────
                    Text(
                      'MÉTODO DE ENVÍO',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF616161),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _deliveryMethod,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                      items: _deliveryOptions
                          .map(
                            (o) => DropdownMenuItem(value: o, child: Text(o)),
                          )
                          .toList(),
                      onChanged: (val) {
                        setState(
                          () => _deliveryMethod = val ?? _deliveryOptions[0],
                        );
                        ref
                            .read(checkoutProvider.notifier)
                            .updateDeliveryType(
                              val == 'Envío a domicilio'
                                  ? DeliveryType.delivery
                                  : DeliveryType.pickup,
                            );
                      },
                    ),

                    const SizedBox(height: 24),

                    // ── Método de pago (grid) ─────────────
                    Text(
                      'MÉTODO DE PAGO',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF616161),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.2,
                      children: _paymentMethods.map((pm) {
                        final (label, icon) = pm;
                        final selected = _selectedPayment == label;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedPayment = label);
                            ref
                                .read(checkoutProvider.notifier)
                                .updatePaymentMethod(label);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: selected
                                    ? Colors.black
                                    : const Color(0xFFE0E0E0),
                                width: selected ? 1.5 : 1,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  icon,
                                  size: 28,
                                  color: selected
                                      ? Colors.black
                                      : const Color(0xFF757575),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  label.toUpperCase(),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontSize: 9,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: selected
                                        ? Colors.black
                                        : const Color(0xFF757575),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 28),

                    // ── Cupón de descuento ─────────────────
                    Text(
                      'CUPÓN DE DESCUENTO',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF616161),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (checkoutState.hasCoupon)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, size: 18, color: Color(0xFF16A34A)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    checkoutState.couponCode!,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF15803D),
                                    ),
                                  ),
                                  Text(
                                    checkoutState.couponDescription,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: const Color(0xFF16A34A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 18, color: Color(0xFF86EFAC)),
                              onPressed: () => ref.read(checkoutProvider.notifier).removeCoupon(),
                            ),
                          ],
                        ),
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                hintText: 'CÓDIGO DE CUPÓN',
                                prefixIcon: const Icon(Icons.local_offer_outlined, size: 18),
                                hintStyle: theme.textTheme.bodySmall?.copyWith(letterSpacing: 1),
                                border: const UnderlineInputBorder(),
                                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                              textCapitalization: TextCapitalization.characters,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontFamily: 'monospace',
                                letterSpacing: 2,
                              ),
                              onFieldSubmitted: (val) {
                                if (val.trim().isNotEmpty) {
                                  ref.read(checkoutProvider.notifier).applyCoupon(val, subtotal);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () {
                                // Get value from text field — user submits via keyboard
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                              ),
                              child: const Text('APLICAR', style: TextStyle(fontSize: 11, letterSpacing: 1)),
                            ),
                          ),
                        ],
                      ),
                    if (checkoutState.couponError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          checkoutState.couponError!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                    const SizedBox(height: 28),

                    // ── Desglose de precios ────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
                        border: Border.all(color: const Color(0xFFEEEEEE)),
                      ),
                      child: Column(
                        children: [
                          _PriceRow(
                            label: 'SUBTOTAL PRODUCTOS:',
                            value: _currency.format(cartState.totalWithoutDiscounts),
                          ),
                          if (offerSaved > 0) ...[
                            const SizedBox(height: 6),
                            _PriceRow(
                              label: 'OFERTAS:',
                              value: '- ${_currency.format(offerSaved)}',
                              valueColor: const Color(0xFFB00020),
                              labelColor: const Color(0xFFB00020),
                            ),
                          ],
                          if (couponDiscount > 0) ...[
                            const SizedBox(height: 6),
                            _PriceRow(
                              label: 'CUPÓN ${checkoutState.couponCode ?? ''}:',
                              value: '- ${_currency.format(couponDiscount)}',
                              valueColor: const Color(0xFF16A34A),
                              labelColor: const Color(0xFF16A34A),
                            ),
                          ],
                          const SizedBox(height: 6),
                          _PriceRow(
                            label: 'COSTO ENVÍO:',
                            value: checkoutState.couponFreeShipping
                                ? 'GRATIS 🎉'
                                : (deliveryCost > 0 ? _currency.format(deliveryCost) : '\$ 0.00'),
                          ),
                          const SizedBox(height: 6),
                          _PriceRow(label: 'TOTAL PAGADO:', value: '\$ 0.00'),

                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 12),

                          // Total USD
                          _PriceRow(
                            label: 'TOTAL A PAGAR (\$):',
                            value: _currency.format(total),
                            isBold: true,
                            labelSize: 14,
                          ),
                          const SizedBox(height: 8),

                          // Total Bs
                          _PriceRow(
                            label: 'TOTAL A PAGAR (Bs):',
                            value: rate > 0
                                ? 'Bs. ${totalBs.toStringAsFixed(2)}'
                                : 'Bs. 0.00',
                            isBold: true,
                            labelSize: 14,
                          ),

                          if (rate <= 0) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Ingresa la tasa para ver el total en Bs.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF9E9E9E),
                                fontSize: 11,
                              ),
                            ),
                          ],

                          const SizedBox(height: 12),

                          // Restante
                          _PriceRow(
                            label: 'RESTANTE:',
                            value: _currency.format(total),
                            labelColor: const Color(0xFFB00020),
                            valueColor: const Color(0xFFB00020),
                          ),
                          const SizedBox(height: 4),
                          _PriceRow(
                            label: '',
                            value: rate > 0
                                ? 'Bs. ${totalBs.toStringAsFixed(2)}'
                                : 'Bs. 0.00',
                            labelColor: const Color(0xFFB00020),
                            valueColor: const Color(0xFFB00020),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Tasa de cambio (automática) ────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.currency_exchange,
                            size: 18,
                            color: Color(0xFF757575),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'TASA DEL DÍA',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: const Color(0xFF616161),
                              letterSpacing: 1,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            rate > 0
                                ? 'Bs. ${rate.toStringAsFixed(2)}'
                                : 'Cargando...',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Observación ────────────────────────
                    TextFormField(
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'OBSERVACIÓN',
                        hintText: 'Ej: POR PAGAR 60',
                        labelStyle: theme.textTheme.labelSmall?.copyWith(
                          color: const Color(0xFF616161),
                          letterSpacing: 1,
                        ),
                        border: const OutlineInputBorder(),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 1.5,
                          ),
                        ),
                      ),
                      onChanged: (val) => ref
                          .read(checkoutProvider.notifier)
                          .updateObservation(val),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),

          // ── Botón confirmar ─────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200, width: 0.5),
              ),
            ),
            child: ElevatedButton(
              onPressed: _selectedPayment == null
                  ? null
                  : () => _confirmOrder(),
              child: const Text('CONFIRMAR COMPRA'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPayment == null) return;

    // Guardar datos del cliente
    ref
        .read(checkoutProvider.notifier)
        .updateClient(
          ClientSnapshot(
            name: _nameCtrl.text.trim().toUpperCase(),
            address: _addressCtrl.text.trim().toUpperCase(),
            phone: _phoneCtrl.text.trim(),
            rifCi: _rifCtrl.text.trim(),
          ),
        );

    setState(() => _isProcessing = true);

    try {
      await ref.read(checkoutProvider.notifier).placeOrder();
      final state = ref.read(checkoutProvider);

      if (state.step == CheckoutStep.confirmed) {
        setState(() {
          _isProcessing = false;
          _orderConfirmed = true;
          _orderId = state.orderId;
          _numericId = state.numericId;
        });
      } else {
        setState(() => _isProcessing = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Error al procesar'),
              backgroundColor: const Color(0xFFB00020),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFB00020),
          ),
        );
      }
    }
  }

  Widget _buildProcessing(ThemeData theme) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PROCESANDO',
          style: theme.textTheme.labelLarge?.copyWith(letterSpacing: 2),
        ),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(strokeWidth: 1.5),
            SizedBox(height: 24),
            Text('Procesando tu pedido...'),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmed(ThemeData theme) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PEDIDO CONFIRMADO',
          style: theme.textTheme.labelLarge?.copyWith(letterSpacing: 2),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 36),
              ),
              const SizedBox(height: 28),
              Text(
                '¡PEDIDO CONFIRMADO!',
                style: theme.textTheme.labelLarge?.copyWith(letterSpacing: 2),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Tu pedido ha sido registrado exitosamente.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                ),
                child: Column(
                  children: [
                    if (_numericId != null)
                      Text(
                        'Factura #$_numericId',
                        style: theme.textTheme.titleLarge,
                      ),
                    if (_orderId != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _orderId!.substring(0, _orderId!.length.clamp(0, 16)),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  ref.read(checkoutProvider.notifier).reset();
                  context.go('/');
                },
                child: const Text('SEGUIR COMPRANDO'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  WIDGETS COMPARTIDOS
// ═══════════════════════════════════════════════════════════

class _InputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool isNumeric;
  final bool isRequired;

  const _InputField({
    required this.label,
    required this.hint,
    required this.controller,
    this.isNumeric = false,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: const Color(0xFF616161),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: isNumeric ? TextInputType.phone : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
          validator: isRequired
              ? (val) =>
                    (val == null || val.trim().isEmpty) ? 'Requerido' : null
              : null,
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;
  final Color? labelColor;
  final double? labelSize;

  const _PriceRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
    this.labelColor,
    this.labelSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style:
              (isBold ? theme.textTheme.titleSmall : theme.textTheme.bodySmall)
                  ?.copyWith(
                    color: labelColor,
                    fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                    fontSize: labelSize,
                  ),
        ),
        Text(
          value,
          style:
              (isBold
                      ? theme.textTheme.titleMedium
                      : theme.textTheme.bodyMedium)
                  ?.copyWith(
                    color: valueColor,
                    fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                  ),
        ),
      ],
    );
  }
}
