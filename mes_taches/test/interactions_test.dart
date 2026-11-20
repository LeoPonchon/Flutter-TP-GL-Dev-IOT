import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mes_taches/main.dart';

void main() {
  testWidgets('cocher une tâche met immédiatement à jour le compteur', (
    tester,
  ) async {
    await tester.pumpWidget(const MesTachesApp());
    expect(find.text('5 à faire'), findsOneWidget);
    await tester.tap(find.byType(Checkbox).at(1));
    await tester.pumpAndSettle();
    expect(find.text('4 à faire'), findsOneWidget);
  });

  testWidgets('le filtre limite les tâches visibles sans changer le compteur', (
    tester,
  ) async {
    await tester.pumpWidget(const MesTachesApp());
    await tester.tap(find.text('Faites'));
    await tester.pumpAndSettle();
    expect(find.text('5 à faire'), findsOneWidget);
    expect(find.text('Installer Flutter'), findsOneWidget);
    expect(find.text('Relire le CM 01'), findsNothing);
  });

  testWidgets(
    'agir depuis un détail avec un filtre actif met à jour la bonne tâche',
    (tester) async {
      await tester.pumpWidget(const MesTachesApp());
      await tester.tap(find.text('À faire'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Faire les courses'));
      await tester.pumpAndSettle();
      expect(find.text('Détail de la tâche'), findsOneWidget);
      expect(find.text('pain, lait, café'), findsOneWidget);
      await tester.tap(find.text('Marquer comme faite'));
      await tester.pumpAndSettle();
      expect(find.text('4 à faire'), findsOneWidget);
      expect(find.text('Faire les courses'), findsNothing);
      await tester.tap(find.text('Faites'));
      await tester.pumpAndSettle();
      expect(find.text('Faire les courses'), findsOneWidget);
    },
  );

  testWidgets('le formulaire vide affiche une erreur et reste ouvert', (
    tester,
  ) async {
    await tester.pumpWidget(const MesTachesApp());
    await tester.tap(find.text('Ajouter'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('enregistrer-tache')));
    await tester.pumpAndSettle();
    expect(find.text('Le titre est obligatoire'), findsOneWidget);
    expect(find.text('Nouvelle tâche'), findsOneWidget);
  });

  testWidgets('le formulaire refuse un titre de plus de 60 caractères', (
    tester,
  ) async {
    await tester.pumpWidget(const MesTachesApp());
    await tester.tap(find.text('Ajouter'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('champ-titre')),
      List.filled(61, 'a').join(),
    );
    await tester.tap(find.byKey(const Key('enregistrer-tache')));
    await tester.pumpAndSettle();
    expect(
      find.text('Le titre ne peut pas dépasser 60 caractères'),
      findsOneWidget,
    );
    expect(find.text('Nouvelle tâche'), findsOneWidget);
  });

  testWidgets('une tâche valide enregistrée apparaît dans la liste', (
    tester,
  ) async {
    await tester.pumpWidget(const MesTachesApp());
    await tester.tap(find.text('Ajouter'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('champ-titre')),
      'Préparer le rendu',
    );
    await tester.enterText(
      find.byKey(const Key('champ-note')),
      '  vérifier les tests  ',
    );
    await tester.tap(find.byKey(const Key('enregistrer-tache')));
    await tester.pumpAndSettle();
    expect(find.text('Préparer le rendu'), findsOneWidget);
    expect(find.text('6 à faire'), findsOneWidget);
    await tester.tap(find.text('Préparer le rendu'));
    await tester.pumpAndSettle();
    expect(find.text('vérifier les tests'), findsOneWidget);
  });

  testWidgets('le formulaire refuse une note de plus de 200 caractères', (
    tester,
  ) async {
    await tester.pumpWidget(const MesTachesApp());
    await tester.tap(find.text('Ajouter'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('champ-titre')), 'Valide');
    await tester.enterText(
      find.byKey(const Key('champ-note')),
      List.filled(201, 'n').join(),
    );
    await tester.tap(find.byKey(const Key('enregistrer-tache')));
    await tester.pumpAndSettle();
    expect(
      find.text('La note ne peut pas dépasser 200 caractères'),
      findsOneWidget,
    );
    expect(find.text('Nouvelle tâche'), findsOneWidget);
  });

  testWidgets('un retour arrière du formulaire ne crée aucune tâche', (
    tester,
  ) async {
    await tester.pumpWidget(const MesTachesApp());
    await tester.tap(find.text('Ajouter'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('5 à faire'), findsOneWidget);
  });

  testWidgets('la liste reste affichable à 360 pixels de large', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MesTachesApp());
    expect(find.text('Toutes'), findsOneWidget);
    expect(find.text('5 à faire'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
