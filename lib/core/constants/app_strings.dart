/// Constantes globales de la aplicación ALONZO.
class AppStrings {
  AppStrings._();

  static const String appName = 'ALONZO';
  static const String tagline = 'Premium Fashion';

  // Tabs de género
  static const String women = 'Mujer';
  static const String men = 'Hombre';
  static const String kids = 'Niños';

  // Secciones
  static const String newArrivals = 'Novedades';
  static const String trending = 'En tendencia';
  static const String brands = 'Marcas';
  static const String categories = 'Categorías';

  // Carrito
  static const String cart = 'Carrito';
  static const String addToCart = 'Añadir';
  static const String checkout = 'Finalizar compra';
  static const String orderSummary = 'Resumen de orden';

  // Perfil
  static const String myAccount = 'Mi cuenta';
  static const String orders = 'Pedidos y devoluciones';
  static const String wishlist = 'Mi lista';
  static const String addresses = 'Direcciones';
  static const String security = 'Detalles y seguridad';
  static const String loyaltyProgram = 'Mi programa de lealtad';

  // Auth
  static const String signIn = 'Iniciar sesión';
  static const String signUp = 'Crear cuenta';
  static const String signInWithGoogle = 'Continuar con Google';
  static const String email = 'Correo electrónico';
  static const String password = 'Contraseña';

  // Errores
  static const String genericError = 'Algo salió mal. Intenta de nuevo.';
  static const String noConnection = 'Sin conexión a internet.';
}

/// Constantes de Firestore collections.
class FirestorePaths {
  FirestorePaths._();

  static const String users = 'users';
  static const String products = 'products';
  static const String orders = 'orders';
  static const String cartItems = 'cartItems';
  static const String wishlist = 'wishlist';
  static const String coupons = 'coupons';
  static const String promotions = 'promotions';
  static const String invoices = 'invoices';
  static const String clients = 'clients';
}

/// Enumeración de género para filtrado.
/// Los valores coinciden EXACTAMENTE con Firestore: "Mujer", "Hombre", "Niños".
enum Gender {
  women('Mujer'),
  men('Hombre'),
  kids('Niños');

  final String value;
  const Gender(this.value);
}
