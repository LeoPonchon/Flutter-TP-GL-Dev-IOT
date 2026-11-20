import 'dart:convert';

enum Priorite {
  basse('Basse'),
  normale('Normale'),
  haute('Haute');

  const Priorite(this.libelle);

  final String libelle;
}

sealed class Echeance {
  const Echeance();
}

final class SansEcheance extends Echeance {
  const SansEcheance();
}

final class EcheanceDatee extends Echeance {
  EcheanceDatee(DateTime date)
    : date = DateTime(date.year, date.month, date.day);

  final DateTime date;
}

final class EcheanceHebdomadaire extends Echeance {
  EcheanceHebdomadaire(this.jourSemaine) {
    if (jourSemaine < DateTime.monday || jourSemaine > DateTime.sunday) {
      throw ArgumentError.value(jourSemaine, 'jourSemaine');
    }
  }

  final int jourSemaine;
}

final class Tache {
  const Tache({
    required this.id,
    required this.titre,
    this.priorite = Priorite.normale,
    this.echeance = const SansEcheance(),
    this.note,
    this.faite = false,
  }) : assert(id != ''),
       assert(titre != '');

  final String id;
  final String titre;
  final Priorite priorite;
  final Echeance echeance;
  final String? note;
  final bool faite;

  Tache copyWith({
    String? titre,
    Priorite? priorite,
    Echeance? echeance,
    String? note,
    bool supprimerNote = false,
    bool? faite,
  }) => Tache(
    id: id,
    titre: titre ?? this.titre,
    priorite: priorite ?? this.priorite,
    echeance: echeance ?? this.echeance,
    note: supprimerNote ? null : note ?? this.note,
    faite: faite ?? this.faite,
  );
}

Priorite? prioriteDepuisCode(String code) => switch (code) {
  'low' => Priorite.basse,
  'normal' => Priorite.normale,
  'high' => Priorite.haute,
  _ => null,
};

Tache tacheDepuisJson(Map<String, Object?> json) {
  String chaineNonVide(String cle) {
    final valeur = json[cle];
    if (valeur is String && valeur.isNotEmpty) return valeur;
    throw FormatException('La clé "$cle" doit être une chaîne non vide.');
  }

  final codePriorite = json['priority'];
  final priorite = codePriorite is String
      ? prioriteDepuisCode(codePriorite)
      : null;
  final faite = json['done'];
  if (priorite == null) {
    throw FormatException(
      'La clé "priority" ne désigne pas une priorité connue.',
    );
  }
  if (faite is! bool) {
    throw FormatException('La clé "done" doit être un booléen.');
  }

  Echeance echeance = const SansEcheance();
  final due = json['due'];
  if (due != null) {
    if (due is! String || !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(due)) {
      throw const FormatException(
        'La clé "due" doit être une date AAAA-MM-JJ.',
      );
    }
    final date = DateTime.tryParse(due);
    if (date == null ||
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}' !=
            due) {
      throw const FormatException(
        'La clé "due" ne contient pas une date valide.',
      );
    }
    echeance = EcheanceDatee(date);
  }

  String? note;
  final valeurNote = json['note'];
  if (valeurNote != null) {
    if (valeurNote is! String) {
      throw const FormatException(
        'La clé "note" doit être une chaîne ou null.',
      );
    }
    note = valeurNote;
  }

  return Tache(
    id: chaineNonVide('id'),
    titre: chaineNonVide('title'),
    priorite: priorite,
    echeance: echeance,
    note: note,
    faite: faite,
  );
}

String libelleEcheance(Echeance echeance) => switch (echeance) {
  SansEcheance() => 'sans échéance',
  EcheanceDatee(:final date) => 'pour le ${date.day}/${date.month}',
  EcheanceHebdomadaire(:final jourSemaine) =>
    'chaque ${_jours[jourSemaine - 1]}',
};

const _jours = [
  'lundi',
  'mardi',
  'mercredi',
  'jeudi',
  'vendredi',
  'samedi',
  'dimanche',
];

bool estEnRetard(Tache tache, {required DateTime aujourdhui}) {
  if (tache.faite) {
    return false;
  }
  if (tache.echeance case EcheanceDatee(:final date)) {
    final jourEcheance = DateTime(date.year, date.month, date.day);
    final jourActuel = DateTime(
      aujourdhui.year,
      aujourdhui.month,
      aujourdhui.day,
    );
    return jourEcheance.isBefore(jourActuel);
  }
  return false;
}

({int faites, int total}) bilan(Iterable<Tache> taches) {
  var faites = 0;
  var total = 0;
  for (final tache in taches) {
    total++;
    if (tache.faite) faites++;
  }
  return (faites: faites, total: total);
}

List<Tache> aFaire(
  Iterable<Tache> taches, {
  Priorite auMoins = Priorite.basse,
}) {
  final resultat = taches
      .where((tache) => !tache.faite && tache.priorite.index >= auMoins.index)
      .toList();
  resultat.sort((a, b) {
    final parPriorite = b.priorite.index.compareTo(a.priorite.index);
    return parPriorite != 0 ? parPriorite : a.titre.compareTo(b.titre);
  });
  return resultat;
}

List<Tache> tachesDepuisJson(String source) {
  final decoded = jsonDecode(source);
  if (decoded is! List) {
    throw const FormatException('Une liste JSON est attendue.');
  }
  return decoded.map((item) {
    if (item is! Map<String, dynamic>) {
      throw const FormatException('Chaque tâche doit être un objet JSON.');
    }
    return tacheDepuisJson(Map<String, Object?>.from(item));
  }).toList();
}
