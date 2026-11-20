import 'package:flutter/material.dart';

import '../modele/taches.dart';

class TuileTache extends StatelessWidget {
  const TuileTache({
    required this.tache,
    required this.aujourdhui,
    required this.onToggle,
    required this.onOuvrir,
    super.key,
  });

  final Tache tache;
  final DateTime aujourdhui;
  final VoidCallback onToggle;
  final VoidCallback onOuvrir;

  @override
  Widget build(BuildContext context) {
    final enRetard = estEnRetard(tache, aujourdhui: aujourdhui);
    final couleurPriorite = switch (tache.priorite) {
      Priorite.basse => Colors.blueGrey,
      Priorite.normale => Colors.indigo,
      Priorite.haute => Colors.deepOrange,
    };
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Checkbox(value: tache.faite, onChanged: (_) => onToggle()),
        title: Text(
          tache.titre,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: tache.faite
              ? const TextStyle(decoration: TextDecoration.lineThrough)
              : null,
        ),
        subtitle: Row(
          children: [
            Icon(Icons.flag, size: 14, color: couleurPriorite),
            const SizedBox(width: 4),
            Text(tache.priorite.libelle),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                libelleEcheance(tache.echeance),
                overflow: TextOverflow.ellipsis,
                style: enRetard
                    ? TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w600,
                      )
                    : null,
              ),
            ),
          ],
        ),
        onTap: onOuvrir,
      ),
    );
  }
}
