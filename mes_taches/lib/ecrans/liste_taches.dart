import 'package:flutter/material.dart';

import '../donnees/exemples.dart';
import '../modele/taches.dart';
import '../widgets/tuile_tache.dart';
import 'detail_tache.dart';
import 'formulaire_tache.dart';

enum FiltreTaches { toutes, aFaire, faites }

class ListeTachesEcran extends StatefulWidget {
  const ListeTachesEcran({super.key});

  @override
  State<ListeTachesEcran> createState() => _ListeTachesEcranState();
}

class _ListeTachesEcranState extends State<ListeTachesEcran> {
  late List<Tache> _taches;
  FiltreTaches _filtre = FiltreTaches.toutes;
  var _sequenceId = 0;

  @override
  void initState() {
    super.initState();
    _taches = tachesDepuisJson(tachesExempleJson);
  }

  List<Tache> get _tachesVisibles => switch (_filtre) {
    FiltreTaches.toutes => _taches,
    FiltreTaches.aFaire => _taches.where((tache) => !tache.faite).toList(),
    FiltreTaches.faites => _taches.where((tache) => tache.faite).toList(),
  };

  int get _nombreAFaire {
    final resultat = bilan(_taches);
    return resultat.total - resultat.faites;
  }

  void _remplacer(Tache nouvelle) {
    setState(() {
      final index = _taches.indexWhere((tache) => tache.id == nouvelle.id);
      if (index >= 0) _taches[index] = nouvelle;
    });
  }

  void _basculer(Tache tache) =>
      _remplacer(tache.copyWith(faite: !tache.faite));

  String _nouvelId() {
    String id;
    do {
      _sequenceId++;
      id = 'local-$_sequenceId';
    } while (_taches.any((tache) => tache.id == id));
    return id;
  }

  Future<void> _ouvrirDetail(Tache tache) async {
    final resultat = await Navigator.of(context).push<Tache>(
      MaterialPageRoute(builder: (_) => DetailTacheEcran(tache: tache)),
    );
    if (!mounted) return;
    if (resultat != null) _remplacer(resultat);
  }

  Future<void> _ajouter() async {
    final resultat = await Navigator.of(context).push<Tache>(
      MaterialPageRoute(builder: (_) => FormulaireTacheEcran(id: _nouvelId())),
    );
    if (!mounted || resultat == null) return;
    setState(() => _taches.insert(0, resultat.copyWith()));
  }

  @override
  Widget build(BuildContext context) {
    final visibles = _tachesVisibles;
    final aujourdhui = DateTime.now();
    return Scaffold(
      appBar: AppBar(title: const Text('Mes tâches')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '$_nombreAFaire à faire',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const Icon(Icons.check_circle_outline, size: 20),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SegmentedButton<FiltreTaches>(
              segments: const [
                ButtonSegment(
                  value: FiltreTaches.toutes,
                  label: Text('Toutes'),
                ),
                ButtonSegment(
                  value: FiltreTaches.aFaire,
                  label: Text('À faire'),
                ),
                ButtonSegment(
                  value: FiltreTaches.faites,
                  label: Text('Faites'),
                ),
              ],
              selected: {_filtre},
              onSelectionChanged: (selection) =>
                  setState(() => _filtre = selection.first),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: visibles.isEmpty
                ? Center(child: Text(_messageVide))
                : ListView.builder(
                    itemCount: visibles.length,
                    itemBuilder: (context, index) {
                      final tache = visibles[index];
                      return TuileTache(
                        tache: tache,
                        aujourdhui: aujourdhui,
                        onToggle: () => _basculer(tache),
                        onOuvrir: () => _ouvrirDetail(tache),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _ajouter,
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
    );
  }

  String get _messageVide => switch (_filtre) {
    FiltreTaches.toutes => 'Aucune tâche',
    FiltreTaches.aFaire => 'Aucune tâche à faire',
    FiltreTaches.faites => 'Aucune tâche faite',
  };
}
