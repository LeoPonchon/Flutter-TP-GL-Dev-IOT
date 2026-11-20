import 'package:flutter/material.dart';

import '../modele/taches.dart';

class DetailTacheEcran extends StatelessWidget {
  const DetailTacheEcran({required this.tache, super.key});

  final Tache tache;

  @override
  Widget build(BuildContext context) {
    final aujourdhui = DateTime.now();
    final enRetard = estEnRetard(tache, aujourdhui: aujourdhui);
    return Scaffold(
      appBar: AppBar(title: const Text('Détail de la tâche')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(tache.titre, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 20),
          _LigneDetail(libelle: 'Priorité', valeur: tache.priorite.libelle),
          _LigneDetail(
            libelle: 'Échéance',
            valeur: libelleEcheance(tache.echeance),
            couleur: enRetard ? Theme.of(context).colorScheme.error : null,
          ),
          _LigneDetail(libelle: 'Note', valeur: tache.note ?? 'Aucune note'),
          _LigneDetail(
            libelle: 'État',
            valeur: tache.faite ? 'Faite' : 'À faire',
          ),
          if (enRetard)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Cette tâche est en retard',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () =>
                Navigator.of(context).pop(tache.copyWith(faite: !tache.faite)),
            icon: Icon(tache.faite ? Icons.undo : Icons.check),
            label: Text(
              tache.faite ? 'Marquer à faire' : 'Marquer comme faite',
            ),
          ),
        ],
      ),
    );
  }
}

class _LigneDetail extends StatelessWidget {
  const _LigneDetail({
    required this.libelle,
    required this.valeur,
    this.couleur,
  });

  final String libelle;
  final String valeur;
  final Color? couleur;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(libelle, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 4),
        Text(valeur, style: TextStyle(color: couleur)),
      ],
    ),
  );
}
