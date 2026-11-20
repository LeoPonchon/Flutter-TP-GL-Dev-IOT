import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../modele/taches.dart';

class FormulaireTacheEcran extends StatefulWidget {
  const FormulaireTacheEcran({required this.id, super.key});

  final String id;

  @override
  State<FormulaireTacheEcran> createState() => _FormulaireTacheEcranState();
}

class _FormulaireTacheEcranState extends State<FormulaireTacheEcran> {
  final _formKey = GlobalKey<FormState>();
  final _titreController = TextEditingController();
  final _noteController = TextEditingController();
  Priorite _priorite = Priorite.normale;
  DateTime? _echeance;

  DateTime get _aujourdhui {
    final maintenant = DateTime.now();
    return DateTime(maintenant.year, maintenant.month, maintenant.day);
  }

  @override
  void dispose() {
    _titreController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String? _validerTitre(String? valeur) {
    final titre = valeur?.trim() ?? '';
    if (titre.isEmpty) return 'Le titre est obligatoire';
    if (titre.length > 60) return 'Le titre ne peut pas dépasser 60 caractères';
    return null;
  }

  String? _validerNote(String? valeur) => (valeur?.length ?? 0) > 200
      ? 'La note ne peut pas dépasser 200 caractères'
      : null;

  Future<void> _choisirDate(FormFieldState<DateTime?> field) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _echeance ?? _aujourdhui,
      firstDate: _aujourdhui,
      lastDate: DateTime(_aujourdhui.year + 20),
      helpText: 'Choisir une échéance',
    );
    if (date == null || !mounted) return;
    setState(() => _echeance = date);
    field.didChange(date);
  }

  void _enregistrer() {
    if (!_formKey.currentState!.validate()) return;
    final note = _noteController.text.trim();
    final tache = Tache(
      id: widget.id,
      titre: _titreController.text.trim(),
      priorite: _priorite,
      echeance: _echeance == null
          ? const SansEcheance()
          : EcheanceDatee(_echeance!),
      note: note.isEmpty ? null : note,
    );
    Navigator.of(context).pop(tache);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Nouvelle tâche')),
    body: Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextFormField(
            key: const Key('champ-titre'),
            controller: _titreController,
            decoration: const InputDecoration(
              labelText: 'Titre',
              border: OutlineInputBorder(),
            ),
            maxLength: 60,
            maxLengthEnforcement: MaxLengthEnforcement.none,
            textInputAction: TextInputAction.next,
            validator: _validerTitre,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<Priorite>(
            key: const Key('champ-priorite'),
            initialValue: _priorite,
            decoration: const InputDecoration(
              labelText: 'Priorité',
              border: OutlineInputBorder(),
            ),
            items: Priorite.values
                .map((p) => DropdownMenuItem(value: p, child: Text(p.libelle)))
                .toList(),
            onChanged: (valeur) {
              if (valeur != null) setState(() => _priorite = valeur);
            },
          ),
          const SizedBox(height: 12),
          FormField<DateTime?>(
            initialValue: _echeance,
            validator: (date) => date != null && date.isBefore(_aujourdhui)
                ? 'L’échéance ne peut pas être passée'
                : null,
            builder: (field) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Échéance',
                    border: const OutlineInputBorder(),
                    errorText: field.errorText,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _echeance == null
                              ? 'Aucune échéance'
                              : '${_echeance!.day}/${_echeance!.month}/${_echeance!.year}',
                        ),
                      ),
                      TextButton.icon(
                        key: const Key('choisir-echeance'),
                        onPressed: () => _choisirDate(field),
                        icon: const Icon(Icons.calendar_month),
                        label: const Text('Choisir'),
                      ),
                      if (_echeance != null)
                        IconButton(
                          tooltip: 'Effacer l’échéance',
                          onPressed: () {
                            setState(() => _echeance = null);
                            field.didChange(null);
                          },
                          icon: const Icon(Icons.clear),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: const Key('champ-note'),
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: 'Note (facultative)',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            minLines: 3,
            maxLines: 5,
            maxLength: 200,
            maxLengthEnforcement: MaxLengthEnforcement.none,
            validator: _validerNote,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            key: const Key('enregistrer-tache'),
            onPressed: _enregistrer,
            icon: const Icon(Icons.save),
            label: const Text('Enregistrer'),
          ),
        ],
      ),
    ),
  );
}
