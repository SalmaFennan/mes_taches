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
      leading: Checkbox(
        key: ValueKey('case-${tache.id}'),
        value: tache.faite,
        onChanged: onChangerEtat,
      ),
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
      subtitle: Text(
        '${libellePriorite(tache.priorite)} - '
        '${libelleEcheance(tache.echeance)}'
        '${enRetard ? ' - En retard' : ''}',
        style: TextStyle(color: enRetard ? Colors.red : null),
      ),
      onTap: onOuvrir,
      trailing: const Icon(Icons.chevron_right),
    );
  }
}

String libellePriorite(Priorite priorite) {
  if (priorite == Priorite.basse) {
    return 'Priorité basse';
  }

  if (priorite == Priorite.normale) {
    return 'Priorité normale';
  }

  return 'Priorité haute';
}
