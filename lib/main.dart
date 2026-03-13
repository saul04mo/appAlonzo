import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'core/theme/alonzo_theme.dart';
import 'routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase con las opciones generadas por FlutterFire CLI
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Status bar transparente para estética limpia
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Orientación vertical forzada
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);



  runApp(const ProviderScope(child: AlonzoApp()));
}

/// Root de la aplicación ALONZO.
class AlonzoApp extends ConsumerWidget {
  const AlonzoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'ALONZO',
      debugShowCheckedModeBanner: false,
      theme: AlonzoTheme.lightTheme,
      routerConfig: router,
    );
  }
}
