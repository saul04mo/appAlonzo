import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/providers.dart';

/// Datos de un slide del banner desde Firestore (config/banners).
class BannerSlide {
  final String imageUrl;
  final String title;
  final String subtitle;
  final String route;

  const BannerSlide({
    this.imageUrl = '',
    this.title = '',
    this.subtitle = 'EXPLORAR',
    this.route = '/catalog?gender=Mujer',
  });

  factory BannerSlide.fromMap(Map<String, dynamic> data) {
    return BannerSlide(
      imageUrl: data['imageUrl'] as String? ?? '',
      title: data['title'] as String? ?? '',
      subtitle: data['subtitle'] as String? ?? 'EXPLORAR',
      route: data['route'] as String? ?? '/catalog?gender=Mujer',
    );
  }
}

/// Provider que escucha en tiempo real config/banners.
final bannerProvider = StreamProvider<List<BannerSlide>>((ref) {
  final firestore = ref.watch(firestoreProvider);

  return firestore
      .collection('config')
      .doc('banners')
      .snapshots()
      .map((snapshot) {
    if (!snapshot.exists || snapshot.data() == null) return <BannerSlide>[];

    final slides = snapshot.data()!['slides'] as List<dynamic>? ?? [];
    return slides
        .map((s) => BannerSlide.fromMap(s as Map<String, dynamic>))
        .where((s) => s.imageUrl.isNotEmpty)
        .toList();
  });
});
