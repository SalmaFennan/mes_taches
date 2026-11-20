/// Modèle de données de l'application « Mes tâches ».
library;

// 1. Les trois niveaux de priorité possibles.
enum Priorite { basse, normale, haute }

// 2. Les différents types d'échéance possibles.
sealed class Echeance {
  const Echeance();
}

// Une tâche sans date limite.
final class SansEcheance extends Echeance {
  const SansEcheance();
}

// Une tâche avec une date précise.
final class DateEcheance extends Echeance {
  final DateTime date;

  const DateEcheance(this.date);
}

// Une tâche qui revient chaque semaine.
final class EcheanceHebdomadaire extends Echeance {
  final int jourSemaine;

  const EcheanceHebdomadaire(this.jourSemaine)
    : assert(jourSemaine >= 1 && jourSemaine <= 7);
}

// 3. La classe qui représente une tâche.
class Tache {
  final String id;
  final String titre;
  final Priorite priorite;
  final Echeance echeance;
  final String? note;
  final bool faite;

  const Tache({
    required this.id,
    required this.titre,
    required this.priorite,
    this.echeance = const SansEcheance(),
    this.note,
    this.faite = false,
  });
}

// 4. Transformer un code texte en priorité.
Priorite? prioriteDepuisCode(String code) {
  if (code == 'low') {
    return Priorite.basse;
  }

  if (code == 'normal') {
    return Priorite.normale;
  }

  if (code == 'high') {
    return Priorite.haute;
  }

  // Le code ne correspond à aucune priorité.
  return null;
}

// 5. Transformer une date texte en DateTime.
DateTime _dateDepuisCode(String code) {
  // Vérifier que la date respecte le format AAAA-MM-JJ.
  final RegExp formatDate = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  if (!formatDate.hasMatch(code)) {
    throw FormatException('Format de date incorrect : $code');
  }

  // Transformer le texte en date.
  final DateTime? date = DateTime.tryParse(code);

  if (date == null) {
    throw FormatException('Date incorrecte : $code');
  }

  // Vérifier que la date existe réellement.
  if (date.year.toString().padLeft(4, '0') != code.substring(0, 4) ||
      date.month.toString().padLeft(2, '0') != code.substring(5, 7) ||
      date.day.toString().padLeft(2, '0') != code.substring(8, 10)) {
    throw FormatException('Date invalide : $code');
  }

  return date;
}

// 6. Transformer un objet JSON en tâche.
Tache tacheDepuisJson(Map<String, Object?> json) {
  // Récupérer et vérifier l'identifiant.
  final Object? idJson = json['id'];

  if (idJson is! String || idJson.trim().isEmpty) {
    throw FormatException('Identifiant manquant ou incorrect');
  }

  // Récupérer et vérifier le titre.
  final Object? titreJson = json['title'];

  if (titreJson is! String || titreJson.trim().isEmpty) {
    throw FormatException('Titre manquant ou incorrect');
  }

  // Récupérer et vérifier la priorité.
  final Object? prioriteJson = json['priority'];

  if (prioriteJson is! String) {
    throw FormatException('Priorité manquante ou incorrecte');
  }

  final Priorite? priorite = prioriteDepuisCode(prioriteJson);

  if (priorite == null) {
    throw FormatException('Code de priorité inconnu');
  }

  // Récupérer et vérifier l'état de la tâche.
  final Object? faiteJson = json['done'];

  if (faiteJson is! bool) {
    throw FormatException('État de la tâche incorrect');
  }

  // Récupérer l'échéance.
  Echeance echeance = const SansEcheance();

  final Object? dateJson = json['due'];

  if (dateJson != null) {
    if (dateJson is! String) {
      throw FormatException('Échéance incorrecte');
    }

    final DateTime date = _dateDepuisCode(dateJson);
    echeance = DateEcheance(date);
  }

  // Récupérer la note.
  String? note;

  final Object? noteJson = json['note'];

  if (noteJson != null) {
    if (noteJson is! String) {
      throw FormatException('Note incorrecte');
    }

    note = noteJson;
  }

  // Créer et retourner la tâche.
  return Tache(
    id: idJson,
    titre: titreJson,
    priorite: priorite,
    echeance: echeance,
    note: note,
    faite: faiteJson,
  );
}

// 7. Donner un libellé lisible à une échéance.
String libelleEcheance(Echeance echeance) {
  if (echeance is SansEcheance) {
    return 'sans échéance';
  }

  if (echeance is DateEcheance) {
    final DateTime date = echeance.date;
    return 'pour le ${date.day}/${date.month}';
  }

  if (echeance is EcheanceHebdomadaire) {
    final List<String> jours = [
      'lundi',
      'mardi',
      'mercredi',
      'jeudi',
      'vendredi',
      'samedi',
      'dimanche',
    ];

    final int numeroJour = echeance.jourSemaine;
    return 'chaque ${jours[numeroJour - 1]}';
  }

  // Cette ligne ne devrait jamais être atteinte.
  throw StateError('Type d’échéance inconnu');
}

// 8. Vérifier si une tâche est en retard.
bool estEnRetard(Tache tache, {required DateTime aujourdhui}) {
  // Une tâche déjà terminée n'est jamais en retard.
  if (tache.faite) {
    return false;
  }

  // Seule une date précise peut être dépassée.
  if (tache.echeance is DateEcheance) {
    final DateTime dateLimite = (tache.echeance as DateEcheance).date;

    // Comparer uniquement les jours, sans tenir compte de l'heure.
    final DateTime dateLimiteSansHeure = DateTime(
      dateLimite.year,
      dateLimite.month,
      dateLimite.day,
    );

    final DateTime aujourdHuiSansHeure = DateTime(
      aujourdhui.year,
      aujourdhui.month,
      aujourdhui.day,
    );

    if (dateLimiteSansHeure.isBefore(aujourdHuiSansHeure)) {
      return true;
    }
  }

  return false;
}

// 9. Calculer le nombre de tâches terminées et le nombre total.
({int faites, int total}) bilan(Iterable<Tache> taches) {
  int nombreFaites = 0;
  int nombreTotal = 0;

  for (final Tache tache in taches) {
    nombreTotal++;

    if (tache.faite) {
      nombreFaites++;
    }
  }

  return (faites: nombreFaites, total: nombreTotal);
}

// 10. Récupérer les tâches à faire selon leur priorité.
List<Tache> aFaire(
  Iterable<Tache> taches, {
  Priorite auMoins = Priorite.basse,
}) {
  // Créer une nouvelle liste vide.
  final List<Tache> resultat = [];

  // Parcourir toutes les tâches.
  for (final Tache tache in taches) {
    // Garder seulement les tâches non terminées
    // dont la priorité est suffisante.
    if (!tache.faite && tache.priorite.index >= auMoins.index) {
      resultat.add(tache);
    }
  }

  // Trier les tâches par priorité décroissante.
  resultat.sort((a, b) {
    final int comparaisonPriorite = b.priorite.index.compareTo(
      a.priorite.index,
    );

    // Si les priorités sont différentes, utiliser leur priorité.
    if (comparaisonPriorite != 0) {
      return comparaisonPriorite;
    }

    // Si les priorités sont identiques, trier par titre.
    return a.titre.compareTo(b.titre);
  });

  return resultat;
}
