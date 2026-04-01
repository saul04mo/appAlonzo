import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Pantalla de cupones disponibles para el usuario.
class MyCouponsScreen extends StatefulWidget {
  const MyCouponsScreen({super.key});

  @override
  State<MyCouponsScreen> createState() => _MyCouponsScreenState();
}

class _MyCouponsScreenState extends State<MyCouponsScreen> {
  List<_CouponData> _coupons = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCoupons();
  }

  Future<void> _loadCoupons() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final snap = await FirebaseFirestore.instance
          .collection('coupons')
          .where('active', isEqualTo: true)
          .get();

      final now = DateTime.now().millisecondsSinceEpoch;
      final available = <_CouponData>[];

      for (final doc in snap.docs) {
        final d = doc.data();

        // Check dates
        final startsAt = d['startsAt'] as Timestamp?;
        final expiresAt = d['expiresAt'] as Timestamp?;
        if (startsAt != null && startsAt.millisecondsSinceEpoch > now) continue;
        if (expiresAt != null && expiresAt.millisecondsSinceEpoch < now) continue;

        // Check total uses
        final maxTotal = (d['maxUsesTotal'] as num?)?.toInt() ?? 0;
        final usedCount = (d['usedCount'] as num?)?.toInt() ?? 0;
        if (maxTotal > 0 && usedCount >= maxTotal) continue;

        // Check per-client uses
        final maxPerClient = (d['maxUsesPerClient'] as num?)?.toInt() ?? 0;
        final usageByClient = d['usageByClient'] as Map<String, dynamic>? ?? {};
        final clientUses = (usageByClient[uid] as num?)?.toInt() ?? 0;
        if (maxPerClient > 0 && clientUses >= maxPerClient) continue;

        available.add(_CouponData(
          code: d['code'] as String? ?? '',
          description: d['description'] as String? ?? '',
          discountType: d['discountType'] as String? ?? 'percentage',
          discountValue: (d['discountValue'] as num?)?.toDouble() ?? 0,
          minPurchase: (d['minPurchase'] as num?)?.toDouble() ?? 0,
          freeShipping: d['freeShipping'] == true,
          expiresAt: expiresAt?.toDate(),
          remainingUses: maxPerClient > 0 ? (maxPerClient - clientUses) : null,
        ));
      }

      if (mounted) setState(() { _coupons = available; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MIS CUPONES',
          style: theme.textTheme.labelLarge?.copyWith(letterSpacing: 2),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 1))
          : _coupons.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.local_offer_outlined, size: 56, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'No tienes cupones disponibles',
                        style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey.shade500),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Los nuevos cupones aparecerán aquí.',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: _coupons.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _CouponCard(coupon: _coupons[index]),
                ),
    );
  }
}

class _CouponData {
  final String code;
  final String description;
  final String discountType;
  final double discountValue;
  final double minPurchase;
  final bool freeShipping;
  final DateTime? expiresAt;
  final int? remainingUses;

  _CouponData({
    required this.code,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.minPurchase,
    required this.freeShipping,
    this.expiresAt,
    this.remainingUses,
  });

  String get discountLabel {
    if (discountType == 'percentage') return '${discountValue.toStringAsFixed(0)}%';
    return '\$${discountValue.toStringAsFixed(0)}';
  }
}

class _CouponCard extends StatefulWidget {
  final _CouponData coupon;
  const _CouponCard({required this.coupon});

  @override
  State<_CouponCard> createState() => _CouponCardState();
}

class _CouponCardState extends State<_CouponCard> {
  bool _copied = false;

  void _copy() {
    Clipboard.setData(ClipboardData(text: widget.coupon.code));
    setState(() => _copied = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('CÓDIGO COPIADO'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = widget.coupon;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          // Left: discount
          Container(
            width: 100,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(3),
                bottomLeft: Radius.circular(3),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  c.discountLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Text(
                  'descuento',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 9,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // Right: details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          c.code,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _copy,
                        child: Icon(
                          _copied ? Icons.check_circle : Icons.copy,
                          size: 18,
                          color: _copied ? const Color(0xFF16A34A) : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                  if (c.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(c.description, style: theme.textTheme.bodySmall),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (c.minPurchase > 0)
                        _Tag(text: 'Mín. \$${c.minPurchase.toStringAsFixed(0)}', icon: Icons.shopping_cart_outlined),
                      if (c.freeShipping)
                        _Tag(text: 'Envío gratis', icon: Icons.local_shipping_outlined, color: const Color(0xFF16A34A)),
                      if (c.expiresAt != null)
                        _Tag(
                          text: 'Exp: ${c.expiresAt!.day}/${c.expiresAt!.month}/${c.expiresAt!.year}',
                          icon: Icons.access_time,
                        ),
                      if (c.remainingUses != null)
                        _Tag(text: '${c.remainingUses} uso${c.remainingUses != 1 ? 's' : ''}', icon: Icons.repeat),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color? color;

  const _Tag({required this.text, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.grey.shade600;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: c),
        const SizedBox(width: 3),
        Text(text, style: TextStyle(fontSize: 10, color: c)),
      ],
    );
  }
}
