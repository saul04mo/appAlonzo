import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Banner de promociones activas.
///
/// Lee la colección 'promotions' de Firestore y muestra
/// las promociones activas y vigentes como tarjetas horizontales.
class PromotionsBanner extends StatelessWidget {
  const PromotionsBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('promotions')
          .where('active', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final now = DateTime.now().millisecondsSinceEpoch;
        final promos = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final startsAt = data['startsAt'] as Timestamp?;
          final expiresAt = data['expiresAt'] as Timestamp?;
          if (startsAt != null && startsAt.millisecondsSinceEpoch > now) return false;
          if (expiresAt != null && expiresAt.millisecondsSinceEpoch < now) return false;
          return true;
        }).toList();

        if (promos.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'OFERTAS ACTIVAS',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              // Horizontal list
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: promos.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final data = promos[index].data() as Map<String, dynamic>;
                    return _PromotionCard(
                      name: data['name'] as String? ?? '',
                      description: data['description'] as String? ?? '',
                      type: data['type'] as String? ?? '',
                      buyQty: (data['buyQty'] as num?)?.toInt() ?? 0,
                      payQty: (data['payQty'] as num?)?.toInt() ?? 0,
                      discountValue: (data['discountValue'] as num?)?.toDouble() ?? 0,
                      discountType: data['discountType'] as String? ?? 'percentage',
                      minPurchase: (data['minPurchase'] as num?)?.toDouble() ?? 0,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PromotionCard extends StatelessWidget {
  final String name;
  final String description;
  final String type;
  final int buyQty;
  final int payQty;
  final double discountValue;
  final String discountType;
  final double minPurchase;

  const _PromotionCard({
    required this.name,
    required this.description,
    required this.type,
    required this.buyQty,
    required this.payQty,
    required this.discountValue,
    required this.discountType,
    required this.minPurchase,
  });

  String get _label {
    switch (type) {
      case 'nxm':
        if (buyQty == 2 && payQty == 1) return '2x1';
        if (buyQty == 3 && payQty == 2) return '3x2';
        return '${buyQty}x$payQty';
      case 'volume_discount':
        return '${discountValue.toStringAsFixed(0)}${discountType == 'percentage' ? '%' : '\$'} OFF';
      case 'min_purchase':
        return '${discountValue.toStringAsFixed(0)}${discountType == 'percentage' ? '%' : '\$'} OFF';
      case 'free_shipping':
        return 'ENVÍO GRATIS';
      case 'bundle':
        return '${discountValue.toStringAsFixed(0)}${discountType == 'percentage' ? '%' : '\$'} COMBO';
      default:
        return name;
    }
  }

  IconData get _icon {
    switch (type) {
      case 'nxm': return Icons.card_giftcard_outlined;
      case 'volume_discount': return Icons.local_offer_outlined;
      case 'min_purchase': return Icons.bolt_outlined;
      case 'free_shipping': return Icons.local_shipping_outlined;
      case 'bundle': return Icons.inventory_2_outlined;
      default: return Icons.star_outline;
    }
  }

  Color get _color {
    switch (type) {
      case 'nxm': return const Color(0xFF7C3AED);
      case 'volume_discount': return const Color(0xFF2563EB);
      case 'min_purchase': return const Color(0xFF059669);
      case 'free_shipping': return const Color(0xFFD97706);
      case 'bundle': return const Color(0xFFE11D48);
      default: return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.06),
        border: Border.all(color: _color.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(_icon, size: 22, color: _color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _color,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  description.isNotEmpty ? description : name,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF6B7280),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
