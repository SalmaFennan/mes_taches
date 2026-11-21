import 'package:material_ui/material_ui.dart';

import '../modele/taches.dart';

class DetailTachePage extends StatelessWidget {
  final Tache tache;
  final DateTime aujourdhui;

  const DetailTachePage({
    super.key,
    required this.tache,
    required this.aujourdhui,
  });

  // Transformer la priorité en texte.
  String libellePriorite(Priorite priorite) {
    if (priorite == Priorite.basse) {
      return 'Basse';
    }

    if (priorite == Priorite.normale) {
      return 'Normale';
    }

    return 'Haute';
  }

  // Modifier l'état de la tâche et retourner à la liste.
  void changerEtat(BuildContext context) {
    final Tache nouvelleTache = Tache(
      id: tache.id,
      titre: tache.titre,
      priorite: tache.priorite,
      echeance: tache.echeance,
      note: tache.note,
      faite: !tache.faite,
    );

    Navigator.pop(context, nouvelleTache);
  }

  @override
  Widget build(BuildContext context) {
    final bool enRetard = estEnRetard(tache, aujourdhui: aujourdhui);

    return Scaffold(
      appBar: AppBar(title: const Text('Détail de la tâche')),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre complet.
            Text(
              tache.titre,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 25),

            // Priorité.
            const Text(
              'Priorité',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            Text(libellePriorite(tache.priorite)),

            const SizedBox(height: 20),

            // Échéance.
            const Text(
              'Échéance',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            Text(libelleEcheance(tache.echeance)),

            const SizedBox(height: 20),

            // Retard.
            const Text('Retard', style: TextStyle(fontWeight: FontWeight.bold)),

            Text(
              enRetard ? 'Cette tâche est en retard' : 'Non',
              style: TextStyle(color: enRetard ? Colors.red : null),
            ),

            const SizedBox(height: 20),

            // Note.
            const Text('Note', style: TextStyle(fontWeight: FontWeight.bold)),

            Text(
              tache.note == null || tache.note!.trim().isEmpty
                  ? 'Aucune note'
                  : tache.note!,
            ),

            const SizedBox(height: 20),

            // État actuel.
            const Text('État', style: TextStyle(fontWeight: FontWeight.bold)),

            Text(tache.faite ? 'Terminée' : 'À faire'),

            const SizedBox(height: 30),

            // Bouton pour modifier l'état.
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  changerEtat(context);
                },
                child: Text(
                  tache.faite
                      ? 'Marquer comme à faire'
                      : 'Marquer comme terminée',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
