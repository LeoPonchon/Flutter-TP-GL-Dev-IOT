import 'package:flutter/material.dart';

import 'ecrans/liste_taches.dart';

void main() => runApp(const MesTachesApp());

class MesTachesApp extends StatelessWidget {
  const MesTachesApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Mes tâches',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      useMaterial3: true,
    ),
    home: const ListeTachesEcran(),
  );
}
