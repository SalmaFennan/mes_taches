import 'package:material_ui/material_ui.dart';

import '../modele/taches.dart';

class LigneTache extends StatelessWidget {
  final Tache tache;
  final DateTime aujourdhui;
  final ValueChanged<bool?> onChangerEtat;
  final VoidCallback onOuvrir;

  const LigneTache({
    super.key,
    required this.tache,
    required this.aujourdhui,
    required this.onChangerEtat,
    required this.onOuvrir,
  });

  @override
  Widget build(BuildContext context) {
    final bool enRetard = estEnRetard(tache, aujourdhui: aujourdhui);

    return ListTile(
      // Case à cocher.
      leading: Checkbox(value: tache.faite, onChanged: onChangerEtat),

      // Titre de la tâche.
      title: Text(
        tache.titre,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          decoration: tache.faite
              ? TextDecoration.lineThrough
              : TextDecoration.none,
        ),
      ),

      // Priorité et échéance.
      subtitle: Text(
        '${libellePriorite(tache.priorite)} - '
        '${libelleEcheance(tache.echeance)}'
        '${enRetard ? ' - En retard' : ''}',
        style: TextStyle(color: enRetard ? Colors.red : null),
      ),

      // Ouvrir le détail quand on clique sur la ligne.
      onTap: onOuvrir,

      trailing: const Icon(Icons.chevron_right),
    );
  }
}

// Transformer la priorité en texte.
String libellePriorite(Priorite priorite) {
  if (priorite == Priorite.basse) {
    return 'Priorité basse';
  }

  if (priorite == Priorite.normale) {
    return 'Priorité normale';
  }

  return 'Priorité haute';
}
