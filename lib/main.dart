import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/app_router.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Tactica - Gioco educativo di strategia per bambini 7-10 anni
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Tactica - Gioco di Strategia',
      theme: ThemeData(
        // Tema ottimizzato per bambini con colori vivaci e amichevoli
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}


