import 'package:flutter_test/flutter_test.dart';
import 'package:mes_taches/modele/taches.dart';

void main() {
  group('prioriteDepuisCode', () {
    test('reconnaît les trois codes et refuse les autres', () {
      expect(prioriteDepuisCode('low'), Priorite.basse);
      expect(prioriteDepuisCode('normal'), Priorite.normale);
      expect(prioriteDepuisCode('high'), Priorite.haute);
      expect(prioriteDepuisCode('High'), isNull);
    });
  });

  group('tacheDepuisJson', () {
    test('lit une tâche sans échéance ni note', () {
      final tache = tacheDepuisJson({
        'id': 'a',
        'title': 'Lire',
        'priority': 'normal',
        'done': false,
      });
      expect(tache.echeance, isA<SansEcheance>());
      expect(tache.note, isNull);
    });

    test('lit une date, une note et ignore les clés inconnues', () {
      final tache = tacheDepuisJson({
        'id': 'a',
        'title': 'Lire',
        'priority': 'high',
        'done': true,
        'due': '2026-12-01',
        'note': 'x',
        'extra': 1,
      });
      expect(tache.echeance, isA<EcheanceDatee>());
      expect(tache.note, 'x');
      expect(tache.faite, isTrue);
    });

    for (final invalide in <Map<String, Object?>>[
      {'title': 'x', 'priority': 'low', 'done': false},
      {'id': 'x', 'priority': 'low', 'done': false},
      {'id': 'x', 'title': 'x', 'done': false},
      {'id': 'x', 'title': 'x', 'priority': 'low'},
      {'id': '', 'title': 'x', 'priority': 'low', 'done': false},
      {'id': 'x', 'title': '', 'priority': 'low', 'done': false},
      {'id': 'x', 'title': 'x', 'priority': 'urgent', 'done': false},
      {'id': 'x', 'title': 'x', 'priority': 'low', 'done': 'no'},
      {
        'id': 'x',
        'title': 'x',
        'priority': 'low',
        'done': false,
        'due': '2026-02-30',
      },
      {'id': 'x', 'title': 'x', 'priority': 'low', 'done': false, 'due': 42},
      {'id': 'x', 'title': 'x', 'priority': 'low', 'done': false, 'note': 3},
    ]) {
      test('rejette un document invalide: $invalide', () {
        expect(() => tacheDepuisJson(invalide), throwsFormatException);
      });
    }
  });

  test('formate les échéances et refuse un jour hebdomadaire invalide', () {
    expect(libelleEcheance(const SansEcheance()), 'sans échéance');
    expect(
      libelleEcheance(EcheanceDatee(DateTime(2026, 12, 1))),
      'pour le 1/12',
    );
    expect(
      libelleEcheance(EcheanceHebdomadaire(DateTime.saturday)),
      'chaque samedi',
    );
    expect(() => EcheanceHebdomadaire(8), throwsArgumentError);
  });

  test('détecte seulement les échéances datées dépassées et non faites', () {
    final hier = Tache(
      id: 'a',
      titre: 'x',
      echeance: EcheanceDatee(DateTime(2026, 11, 8)),
    );
    final faite = hier.copyWith(faite: true);
    final aujourdHui = Tache(
      id: 'b',
      titre: 'x',
      echeance: EcheanceDatee(DateTime(2026, 11, 9, 8)),
    );
    expect(estEnRetard(hier, aujourdhui: DateTime(2026, 11, 9, 15)), isTrue);
    expect(estEnRetard(faite, aujourdhui: DateTime(2026, 11, 9)), isFalse);
    expect(
      estEnRetard(aujourdHui, aujourdhui: DateTime(2026, 11, 9, 18)),
      isFalse,
    );
    expect(
      estEnRetard(
        const Tache(id: 'c', titre: 'x'),
        aujourdhui: DateTime(2026),
      ),
      isFalse,
    );
    expect(
      estEnRetard(
        Tache(id: 'd', titre: 'x', echeance: EcheanceHebdomadaire(1)),
        aujourdhui: DateTime(2026),
      ),
      isFalse,
    );
  });

  test('bilan compte les tâches faites, y compris une liste vide', () {
    expect(bilan(<Tache>[]), (faites: 0, total: 0));
    expect(
      bilan([
        const Tache(id: 'a', titre: 'x'),
        const Tache(id: 'b', titre: 'y', faite: true),
      ]),
      (faites: 1, total: 2),
    );
  });

  test('aFaire filtre, trie sans modifier son entrée et respecte le seuil', () {
    final entree = [
      const Tache(id: '1', titre: 'Courses', priorite: Priorite.basse),
      const Tache(id: '2', titre: 'Dentiste'),
      const Tache(id: '3', titre: 'Passeport', priorite: Priorite.haute),
      const Tache(
        id: '4',
        titre: 'Installer',
        priorite: Priorite.haute,
        faite: true,
      ),
      const Tache(id: '5', titre: 'Banque'),
    ];
    final originalIds = entree.map((t) => t.id).toList();
    expect(aFaire(entree).map((t) => t.titre), [
      'Passeport',
      'Banque',
      'Dentiste',
      'Courses',
    ]);
    expect(aFaire(entree, auMoins: Priorite.normale).map((t) => t.titre), [
      'Passeport',
      'Banque',
      'Dentiste',
    ]);
    expect(entree.map((t) => t.id).toList(), originalIds);
  });

  test('copyWith produit une tâche distincte sans modifier l’originale', () {
    const originale = Tache(id: 'a', titre: 'x', note: 'note');
    final modifiee = originale.copyWith(faite: true, supprimerNote: true);
    expect(modifiee.id, originale.id);
    expect(modifiee.faite, isTrue);
    expect(modifiee.note, isNull);
    expect(originale.faite, isFalse);
    expect(originale.note, 'note');
    expect(identical(originale, modifiee), isFalse);
  });
}
