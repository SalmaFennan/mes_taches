import 'package:material_ui/material_ui.dart';

import '../modele/taches.dart';

class AjouterTachePage extends StatefulWidget {
  const AjouterTachePage({super.key});

  @override
  State<AjouterTachePage> createState() => _AjouterTachePageState();
}

class _AjouterTachePageState extends State<AjouterTachePage> {
  final GlobalKey<FormState> cleFormulaire = GlobalKey<FormState>();

  final TextEditingController titreController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  Priorite prioriteSelectionnee = Priorite.normale;
  DateTime? dateEcheance;

  @override
  void dispose() {
    titreController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> choisirDate() async {
    final DateTime aujourdHui = DateTime.now();
    final DateTime dateMinimum = DateTime(
      aujourdHui.year,
      aujourdHui.month,
      aujourdHui.day,
    );

    final DateTime? dateChoisie = await showDatePicker(
      context: context,
      initialDate: dateEcheance ?? dateMinimum,
      firstDate: dateMinimum,
      lastDate: DateTime(2100),
    );

    if (dateChoisie != null) {
      setState(() {
        dateEcheance = dateChoisie;
      });
    }
  }

  String libellePriorite(Priorite priorite) {
    if (priorite == Priorite.basse) {
      return 'Basse';
    } else if (priorite == Priorite.normale) {
      return 'Normale';
    } else {
      return 'Haute';
    }
  }

  String? validerTitre(String? valeur) {
    final String titre = valeur?.trim() ?? '';

    if (titre.isEmpty) {
      return 'Le titre est obligatoire.';
    }

    if (titre.length > 60) {
      return 'Le titre ne doit pas dépasser 60 caractères.';
    }

    return null;
  }

  String? validerNote(String? valeur) {
    final String note = valeur?.trim() ?? '';

    if (note.length > 200) {
      return 'La note ne doit pas dépasser 200 caractères.';
    }

    return null;
  }

  void enregistrerTache() {
    final bool formulaireValide = cleFormulaire.currentState!.validate();

    if (!formulaireValide) {
      return;
    }

    final String titre = titreController.text.trim();
    final String note = noteController.text.trim();

    final Tache nouvelleTache = Tache(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      titre: titre,
      priorite: prioriteSelectionnee,
      echeance: dateEcheance == null
          ? const SansEcheance()
          : DateEcheance(dateEcheance!),
      note: note.isEmpty ? null : note,
      faite: false,
    );

    Navigator.pop(context, nouvelleTache);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter une tâche')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: cleFormulaire,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Titre de la tâche',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                key: const ValueKey('champTitreTache'),
                controller: titreController,
                maxLength: 60,
                validator: validerTitre,
                decoration: const InputDecoration(
                  hintText: 'Exemple : Réviser le cours',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Priorité',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButton<Priorite>(
                value: prioriteSelectionnee,
                isExpanded: true,
                items: Priorite.values.map((Priorite priorite) {
                  return DropdownMenuItem<Priorite>(
                    value: priorite,
                    child: Text(libellePriorite(priorite)),
                  );
                }).toList(),
                onChanged: (Priorite? nouvellePriorite) {
                  if (nouvellePriorite != null) {
                    setState(() {
                      prioriteSelectionnee = nouvellePriorite;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Échéance',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (dateEcheance == null)
                const Text('Aucune date sélectionnée')
              else
                Text(
                  'Date choisie : ${dateEcheance!.day}/'
                  '${dateEcheance!.month}/${dateEcheance!.year}',
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: choisirDate,
                      child: const Text('Choisir une date'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          dateEcheance = null;
                        });
                      },
                      child: const Text('Sans échéance'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Note (facultative)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: noteController,
                maxLength: 200,
                maxLines: 4,
                validator: validerNote,
                decoration: const InputDecoration(
                  hintText: 'Ajouter une précision...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: enregistrerTache,
                  child: const Text('Enregistrer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
