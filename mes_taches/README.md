# Mes tâches — HAI912I, TP 1

Application Flutter de gestion de tâches réalisée pour le TP 1 « Fondamentaux de Dart et Flutter » (année 2026–2027). Les tâches sont conservées en mémoire pendant la session et sont réinitialisées au redémarrage.

## Fonctionnalités

- Lecture des tâches d’exemple depuis le JSON fourni.
- Modèle Dart immuable, priorités, échéances datées ou hebdomadaires, détection des retards et bilan.
- Liste avec compteur global, filtres « Toutes », « À faire » et « Faites », changement d’état et repérage visuel des retards.
- Écran de détail avec toutes les informations et action pour cocher ou décocher.
- Formulaire de création avec validation du titre, de la note et de l’échéance.
- Tests unitaires du modèle et tests de widgets des interactions.

## Membres

À compléter : prénom, nom, numéro étudiant et parcours de chaque membre du binôme (GL, IASD ou ICO).

## Architecture

```text
lib/
  donnees/exemples.dart       données JSON de démarrage
  modele/taches.dart          modèle, conversion JSON et fonctions métier
  ecrans/liste_taches.dart    état de la liste, filtres et navigation
  ecrans/detail_tache.dart    consultation et action sur une tâche
  ecrans/formulaire_tache.dart création et validation
  widgets/tuile_tache.dart    tuile réutilisable sans état
test/
  modele_test.dart            tests unitaires A1–A3
  interactions_test.dart      tests de widgets B2–E2
  widget_test.dart             test de démarrage conservé
```

L’état modifiable (liste de tâches et filtre actif) appartient à `ListeTachesEcran`. Le compteur et les tâches visibles sont calculés depuis la liste source. La tuile reçoit une tâche et des rappels, sans posséder d’état. Le détail renvoie une tâche remplacée via le résultat de navigation. Le formulaire renvoie une nouvelle tâche ; l’annulation ne renvoie rien. Les identifiants ajoutés sont séquencés et vérifiés contre les identifiants déjà présents.

## Environnement de référence

- Linux Ubuntu 24.04.3 LTS
- Flutter 3.47.5 stable
- Dart 3.13.4
- Dépendances : Flutter SDK, `flutter_lints` et `cupertino_icons` ; tests avec `flutter_test`.
- VS Code / Android Studio : non renseigné.

Le poste de vérification dispose de Flutter mais n’a pas de SDK Android ni de navigateur Chrome. L’application a été compilée pour le Web, mais n’a pas pu être lancée sur Chrome ni testée sur Android depuis ce poste. Flutter Desktop Linux est détecté.

## Installation, lancement et vérification

Depuis une copie propre du dossier :

```sh
flutter create --platforms=web,android .
flutter pub get
flutter analyze
flutter test
flutter build web
```

Pour lancer dans Chrome :

```sh
flutter run -d chrome
```

Pour Android, après installation du SDK Android et acceptation des licences :

```sh
flutter devices
flutter run -d <id>
flutter build apk --debug
```

Pour lancer sur le bureau Linux (option disponible sur le poste de référence) :

```sh
flutter run -d linux
```

## État de vérification

`flutter analyze` ne signale aucun problème ; les 29 tests passent ; `flutter build web` réussit. Aucun APK ni enregistrement vidéo de démonstration n’a été produit sur le poste de référence. Ajouter dans la remise les captures et la vidéo réalisées pendant l’exécution, ainsi que le compte-rendu PDF et ce README en PDF.

## Limites et bonus

Les données sont volatiles et ne sont pas sauvegardées, conformément au périmètre du TP 1. Les bonus G1–G4 ne sont pas implémentés.

## Déclaration d’usage d’IA

Codex (modèle GPT-6) a été utilisé comme assistant pour analyser le sujet, proposer et écrire une partie du code et des tests, puis corriger les problèmes révélés par l’analyse et l’exécution. Le code a été vérifié avec `flutter analyze`, `flutter test` et `flutter build web`. Les auteurs du rendu restent responsables de comprendre et d’expliquer les choix et le code remis.

## Liens

À compléter : URL du dépôt Git et lien vidéo externe, le cas échéant.
