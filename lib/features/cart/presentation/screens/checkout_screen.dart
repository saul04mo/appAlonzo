import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../domain/entities/cart_entity.dart';
import '../../../cart/presentation/providers/checkout_provider.dart';
import '../../../auth/domain/entities/user_profile_entity.dart';
import '../../../profile/presentation/providers/user_profile_provider.dart';
import '../widgets/address_picker_sheet.dart';

/// BLINDAJE TOTAL 2.0: Estructura ultra-estable para el Checkout.
/// Elimina GridView dinámicos y ciclos de redibujado en build.
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
  final _couponCtrl = TextEditingController();

  String _deliveryMethod = 'Retiro en tienda (GRATIS)';
  String? _selectedPayment;
  bool _isProcessing = false;
  bool _orderConfirmed = false;
  bool _profilePopulated = false;
  double? _selectedLat;
  double? _selectedLng;

  static final _currency = NumberFormat.currency(locale: 'es_MX', symbol: '\$', decimalDigits: 2);

  @override
  void dispose() {
    _rifCtrl.dispose(); _nameCtrl.dispose(); _phoneCtrl.dispose();
    _addressCtrl.dispose(); _couponCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cartState = ref.watch(cartProvider);
    final checkoutState = ref.watch(checkoutProvider);

    // ── Población controlada (SIDE EFFECT) ──
    ref.listen(userProfileProvider, (previous, next) {
      if (!_profilePopulated && next.profileLoaded) {
        final profile = next.profile;
        if (profile.name.isNotEmpty || profile.phone.isNotEmpty) {
          _profilePopulated = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _nameCtrl.text = profile.name;
              _phoneCtrl.text = profile.phone;
              _rifCtrl.text = profile.rifCi;
              _addressCtrl.text = profile.address;
            }
          });
        }
      }
    });

    if (_orderConfirmed) return _buildConfirmed(theme);
    if (_isProcessing) return _buildProcessing(theme);

    final subtotal = cartState.total;
    final couponDiscount = checkoutState.couponDiscount;
    final deliveryCost = checkoutState.couponFreeShipping ? 0.0 : 
        (_deliveryMethod == 'Envío a domicilio' ? checkoutState.deliveryCostUsd : 0.0);
    final total = (subtotal - couponDiscount + deliveryCost).clamp(0.0, double.infinity);
    final totalBs = checkoutState.exchangeRate > 0 ? total * checkoutState.exchangeRate : 0.0;

    return Scaffold(
      appBar: AppBar(title: const Text('RESUMEN DE COMPRA')),
      body: Column(
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: CustomScrollView(
                slivers: [
                  // Bloque de Datos
                  _SliverCard(
                    title: 'MIS DATOS',
                    children: [
                      _InputField(label: 'RIF / CI', controller: _rifCtrl),
                      const SizedBox(height: 12),
                      _InputField(label: 'NOMBRE COMPLETO', controller: _nameCtrl, isRequired: true),
                      const SizedBox(height: 12),
                      _InputField(label: 'TELÉFONO', controller: _phoneCtrl, isNumeric: true, isRequired: true),
                    ],
                  ),

                  // Bloque de Entrega
                  _SliverCard(
                    title: 'MODO DE ENTREGA',
                    children: [
                      _buildShippingDropdown(),
                      const SizedBox(height: 16),
                      _buildAddressPicker(),
                    ],
                  ),

                  // Bloque de Pago (FILAS ESTÁTICAS - NO GRID)
                  _SliverCard(
                    title: 'MÉTODO DE PAGO',
                    children: [
                      _buildStaticPaymentRows(),
                    ],
                  ),

                  // Bloque de Cupón
                  _SliverCard(
                    title: 'CUPÓN',
                    children: [
                      _buildCouponRow(checkoutState, subtotal),
                    ],
                  ),

                  // Bloque de Precios
                  _SliverCard(
                    title: 'TOTALES',
                    children: [
                      _buildPriceBreakdown(cartState, checkoutState, deliveryCost, total, totalBs),
                    ],
                  ),

                  // Bloque de Observaciones
                  _SliverCard(
                    title: 'OBSERVACIONES',
                    children: [
                      _buildObservationField(),
                    ],
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                ],
              ),
            ),
          ),
          _buildConfirmButton(theme),
        ],
      ),
    );
  }

  // --- SUBWIDGETS ---

  Widget _buildShippingDropdown() {
    return DropdownButtonFormField<String>(
      value: _deliveryMethod,
      decoration: const InputDecoration(labelText: 'MÉTODO DE ENVÍO', border: OutlineInputBorder()),
      items: ['Retiro en tienda (GRATIS)', 'Envío a domicilio'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
      onChanged: (v) {
        setState(() => _deliveryMethod = v ?? 'Retiro en tienda (GRATIS)');
        ref.read(checkoutProvider.notifier).updateDeliveryType(v == 'Envío a domicilio' ? DeliveryType.delivery : DeliveryType.pickup);
      },
    );
  }

  Widget _buildAddressPicker() {
    return InkWell(
      onTap: () async {
        final res = await AddressPickerSheet.show(context, initialAddress: _addressCtrl.text, initialLat: _selectedLat, initialLng: _selectedLng);
        if (res != null) setState(() { _addressCtrl.text = res.address; _selectedLat = res.latitude; _selectedLng = res.longitude; });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(4)),
        child: Row(children: [
          const Icon(Icons.location_on_outlined, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(_addressCtrl.text.isEmpty ? 'Seleccionar dirección en mapa...' : _addressCtrl.text, maxLines: 1, overflow: TextOverflow.ellipsis)),
          const Icon(Icons.chevron_right, size: 20),
        ]),
      ),
    );
  }

  Widget _buildStaticPaymentRows() {
    final theme = Theme.of(context);
    final methods = [
      ('Pago Móvil', Icons.phone_android), ('Zelle', Icons.account_balance), ('Efectivo', Icons.attach_money),
      ('Binance', Icons.currency_bitcoin), ('Zinli', Icons.credit_card), ('PayPal', Icons.paypal),
    ];
    
    // Dividir en 2 filas de 3 para evitar GridView inestable
    return Column(
      children: [
        Row(children: methods.sublist(0, 3).map((m) => Expanded(child: _PaymentItem(m.$1, m.$2, _selectedPayment == m.$1, () {
          setState(() => _selectedPayment = m.$1);
          ref.read(checkoutProvider.notifier).updatePaymentMethod(m.$1);
        }))).toList()),
        const SizedBox(height: 8),
        Row(children: methods.sublist(3, 6).map((m) => Expanded(child: _PaymentItem(m.$1, m.$2, _selectedPayment == m.$1, () {
          setState(() => _selectedPayment = m.$1);
          ref.read(checkoutProvider.notifier).updatePaymentMethod(m.$1);
        }))).toList()),
      ],
    );
  }

  Widget _buildCouponRow(CheckoutState state, double subtotal) {
    if (state.hasCoupon) {
      return Container(
        padding: const EdgeInsets.all(8), color: Colors.green.shade50,
        child: Row(children: [
          Text('Cupón: ${state.couponCode ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          const Spacer(),
          IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => ref.read(checkoutProvider.notifier).removeCoupon()),
        ]),
      );
    }
    return Row(children: [
      Expanded(child: TextFormField(controller: _couponCtrl, decoration: const InputDecoration(hintText: 'CÓDIGO', border: UnderlineInputBorder()))),
      const SizedBox(width: 8),
      TextButton(onPressed: () => ref.read(checkoutProvider.notifier).applyCoupon(_couponCtrl.text, subtotal), child: const Text('APLICAR')),
    ]);
  }

  Widget _buildPriceBreakdown(CartState cart, CheckoutState check, double delivery, double total, double totalBs) {
    return Column(
      children: [
        _RowPrice('Subtotal', _currency.format(cart.totalWithoutDiscounts)),
        if (cart.totalSaved > 0) _RowPrice('Ahorro Ofertas', '- ${_currency.format(cart.totalSaved)}', color: Colors.red),
        if (check.couponDiscount > 0) _RowPrice('Cupón', '- ${_currency.format(check.couponDiscount)}', color: Colors.green),
        _RowPrice('Envío', check.couponFreeShipping ? 'GRATIS' : _currency.format(delivery)),
        const Divider(height: 20),
        _RowPrice('PAGAR USD', _currency.format(total), isBold: true),
        _RowPrice('PAGAR BS', 'Bs. ${totalBs.toStringAsFixed(2)}', isBold: true),
        const SizedBox(height: 8),
        Text('Tasa: Bs. ${check.exchangeRate.toStringAsFixed(2)}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildObservationField() {
    return TextFormField(maxLines: 2, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Ej: Puerta verde...'), onChanged: (v) => ref.read(checkoutProvider.notifier).updateObservation(v));
  }

  Widget _buildConfirmButton(ThemeData theme) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade200))),
      child: ElevatedButton(
        onPressed: _selectedPayment == null ? null : _confirmOrder,
        style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: Colors.black),
        child: const Text('CONFIRMAR PEDIDO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _confirmOrder() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isProcessing = true);
    try {
      ref.read(checkoutProvider.notifier).updateClient(ClientSnapshot(name: _nameCtrl.text, phone: _phoneCtrl.text, address: _addressCtrl.text, rifCi: _rifCtrl.text));
      await ref.read(checkoutProvider.notifier).placeOrder();
      if (mounted) {
        final state = ref.read(checkoutProvider);
        if (state.step == CheckoutStep.confirmed) setState(() => _orderConfirmed = true);
        setState(() => _isProcessing = false);
      }
    } catch (e) {
      if (mounted) { setState(() => _isProcessing = false); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'))); }
    }
  }

  Widget _buildProcessing(ThemeData theme) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }

  Widget _buildConfirmed(ThemeData theme) {
    return Scaffold(
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.verified, size: 80, color: Colors.green),
          const SizedBox(height: 16),
          const Text('¡PEDIDO REGISTRADO!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          ElevatedButton(onPressed: () { ref.read(checkoutProvider.notifier).reset(); context.go('/'); }, child: const Text('VOLVER AL INICIO')),
        ]),
      ),
    );
  }
}

class _SliverCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SliverCard({required this.title, required this.children});
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isNumeric;
  final bool isRequired;
  const _InputField({required this.label, required this.controller, this.isNumeric = false, this.isRequired = false});
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller, keyboardType: isNumeric ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      validator: isRequired ? (v) => (v == null || v.isEmpty) ? 'Requerido' : null : null,
    );
  }
}

class _PaymentItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _PaymentItem(this.label, this.icon, this.selected, this.onTap);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(border: Border.all(color: selected ? Colors.black : Colors.grey.shade300, width: selected ? 2 : 1), borderRadius: BorderRadius.circular(4)),
        child: Column(children: [Icon(icon, size: 20, color: selected ? Colors.black : Colors.grey), const SizedBox(height: 4), Text(label, style: TextStyle(fontSize: 8, fontWeight: selected ? FontWeight.bold : FontWeight.normal))]),
      ),
    );
  }
}

class _RowPrice extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final bool isBold;
  const _RowPrice(this.label, this.value, {this.color, this.isBold = false});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(color: color, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(color: color, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      ]),
    );
  }
}
