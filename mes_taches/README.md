# Mes tâches — HAI912I, TP 1

## Projet

« Mes tâches » est une application personnelle développée en Flutter dans le cadre du TP 1 **Fondamentaux de Dart et Flutter** de l’année universitaire 2026–2027.

Elle permet de lire des tâches depuis un document JSON, consulter un compteur global, filtrer les tâches, les cocher ou les décocher, ouvrir leur détail et créer une nouvelle tâche avec validation. Les données restent en mémoire pendant l’exécution et sont réinitialisées au démarrage suivant.

## Fonctionnalités

- Lecture des tâches d’exemple depuis le JSON fourni.
- Modèle Dart immuable, priorités, échéances datées ou hebdomadaires, détection des retards et bilan.
- Liste avec compteur global, filtres « Toutes », « À faire » et « Faites », changement d’état et repérage visuel des retards.
- Écran de détail avec toutes les informations et action pour cocher ou décocher.
- Formulaire de création avec validation du titre, de la note et de l’échéance.
- Tests unitaires du modèle et tests de widgets des interactions.

## Membres du binôme

Léo Ponchon, Yasser Razzaki, Léo Faucon

## Architecture

```text
lib/
  donnees/exemples.dart        données JSON de démarrage
  modele/taches.dart           modèle, conversion JSON et fonctions métier
  ecrans/liste_taches.dart     état de la liste, filtres et navigation
  ecrans/detail_tache.dart     consultation et action sur une tâche
  ecrans/formulaire_tache.dart création et validation
  widgets/tuile_tache.dart     tuile réutilisable sans état
test/
  modele_test.dart             tests unitaires A1–A3
  interactions_test.dart       tests de widgets B2–E2
  widget_test.dart             test de démarrage conservé
```

L’état modifiable, la liste des tâches et le filtre actif appartiennent à `ListeTachesEcran`. Le compteur et les tâches visibles sont calculés depuis la liste source. La tuile reçoit une tâche et des rappels, sans posséder d’état. Le détail renvoie une tâche remplacée via le résultat de navigation. Le formulaire renvoie une nouvelle tâche ou rien en cas d’annulation. Les identifiants ajoutés sont séquencés sous la forme `local-N` puis vérifiés contre les identifiants déjà présents.

## Environnement de référence

- **Système** : Linux Ubuntu 24.04.3 LTS
- **Flutter** : 3.50.1 stable
- **Dart** : 3.14.0
- **Éditeur** : VS Code
- **Tests** : `flutter_test`

## Plateformes

- **Web** : la compilation Web réussit et l’application a été vérifiée visuellement dans Chrome. Cette vérification a été réalisée lorsque les émulateurs des ordinateurs de la faculté n’étaient pas utilisables.
- **Android** : l’APK debug est construit avec succès et a été installé puis testé sur un téléphone Android personnel.

## Installation depuis une copie propre

```sh
cd mes_taches
flutter create --platforms=web,android .
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter build web
flutter build apk --debug
```

## Exécution

### Web dans Chrome

```sh
flutter run -d chrome
```

### Web avec Chrome lancé séparément

```sh
flutter run -d web-server
```

### Android

Après installation du SDK Android, des licences et des outils requis :

```sh
flutter doctor -v
flutter devices
flutter run -d <id>
flutter build apk --debug
```

### Linux Desktop

```sh
flutter run -d linux
```

## Tests

```sh
flutter test
flutter test test/modele_test.dart
flutter test test/interactions_test.dart
flutter test test/widget_test.dart
```

## État de vérification

- `dart format --output=none --set-exit-if-changed lib test` : 10 fichiers vérifiés, aucun changement.
- `flutter test` : 29 tests réussis sur 29.
- `flutter build web` : compilation réussie.
- `flutter build apk --debug` : APK debug construit avec succès.
- `flutter analyze` : 6 messages informatifs de dépréciation concernant `package:flutter/material.dart`. Ce résultat doit être ramené à zéro avant remise selon le point F2.