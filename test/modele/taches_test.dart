import 'package:flutter_test/flutter_test.dart';
import 'package:mes_taches/modele/taches.dart';

void main() {
  // -----------------------------------------
  // 1. Tests de la méthode prioriteDepuisCode
  // -----------------------------------------

  group('Tests des priorités', () {
    test('Reconnaître les trois codes de priorité', () {
      expect(prioriteDepuisCode('low'), Priorite.basse);
      expect(prioriteDepuisCode('normal'), Priorite.normale);
      expect(prioriteDepuisCode('high'), Priorite.haute);
    });

    test('Retourner null pour un code inconnu', () {
      expect(prioriteDepuisCode('urgent'), isNull);
    });
  });

  // -----------------------------------------
  // 2. Tests de la méthode tacheDepuisJson
  // -----------------------------------------

  group('Tests de création d’une tâche depuis JSON', () {
    test('Créer une tâche avec tous les champs', () {
      final Map<String, Object?> json = {
        'id': 't1',
        'title': 'Installer Flutter',
        'priority': 'high',
        'done': false,
        'due': '2026-12-01',
        'note': 'Terminer l’installation',
      };

      final Tache tache = tacheDepuisJson(json);

      expect(tache.id, 't1');
      expect(tache.titre, 'Installer Flutter');
      expect(tache.priorite, Priorite.haute);
      expect(tache.faite, false);
      expect(tache.note, 'Terminer l’installation');
      expect(tache.echeance, isA<DateEcheance>());
    });

    test('Créer une tâche sans date et sans note', () {
      final Map<String, Object?> json = {
        'id': 't2',
        'title': 'Relire le cours',
        'priority': 'normal',
        'done': true,
      };

      final Tache tache = tacheDepuisJson(json);

      expect(tache.id, 't2');
      expect(tache.titre, 'Relire le cours');
      expect(tache.echeance, isA<SansEcheance>());
      expect(tache.note, isNull);
      expect(tache.faite, true);
    });

    test('Refuser un identifiant manquant', () {
      final Map<String, Object?> json = {
        'title': 'Faire les courses',
        'priority': 'low',
        'done': false,
      };

      expect(() => tacheDepuisJson(json), throwsA(isA<FormatException>()));
    });

    test('Refuser un titre vide', () {
      final Map<String, Object?> json = {
        'id': 't3',
        'title': '   ',
        'priority': 'low',
        'done': false,
      };

      expect(() => tacheDepuisJson(json), throwsA(isA<FormatException>()));
    });

    test('Refuser une priorité inconnue', () {
      final Map<String, Object?> json = {
        'id': 't4',
        'title': 'Faire les courses',
        'priority': 'urgent',
        'done': false,
      };

      expect(() => tacheDepuisJson(json), throwsA(isA<FormatException>()));
    });

    test('Refuser un état qui n’est pas un booléen', () {
      final Map<String, Object?> json = {
        'id': 't5',
        'title': 'Réviser',
        'priority': 'normal',
        'done': 'non',
      };

      expect(() => tacheDepuisJson(json), throwsA(isA<FormatException>()));
    });

    test('Refuser une date incorrecte', () {
      final Map<String, Object?> json = {
        'id': 't6',
        'title': 'Réviser',
        'priority': 'normal',
        'done': false,
        'due': '2026-15-40',
      };

      expect(() => tacheDepuisJson(json), throwsA(isA<FormatException>()));
    });

    test('Refuser une note qui n’est pas du texte', () {
      final Map<String, Object?> json = {
        'id': 't7',
        'title': 'Réviser',
        'priority': 'normal',
        'done': false,
        'note': 123,
      };

      expect(() => tacheDepuisJson(json), throwsA(isA<FormatException>()));
    });
  });

  // -----------------------------------------
  // 3. Tests de la méthode libelleEcheance
  // -----------------------------------------

  group('Tests des libellés des échéances', () {
    test('Afficher une tâche sans échéance', () {
      expect(libelleEcheance(const SansEcheance()), 'sans échéance');
    });

    test('Afficher une date précise', () {
      final Echeance echeance = DateEcheance(DateTime(2026, 12, 1));

      expect(libelleEcheance(echeance), 'pour le 1/12');
    });

    test('Afficher une échéance hebdomadaire', () {
      expect(libelleEcheance(const EcheanceHebdomadaire(6)), 'chaque samedi');
    });
  });

  // -----------------------------------------
  // 4. Tests de la méthode estEnRetard
  // -----------------------------------------

  group('Tests des retards', () {
    final DateTime aujourdhui = DateTime(2026, 11, 21);

    test('Une tâche avec une date dépassée est en retard', () {
      final Tache tache = Tache(
        id: 't1',
        titre: 'Rendre le devoir',
        priorite: Priorite.haute,
        echeance: DateEcheance(DateTime(2026, 11, 20)),
      );

      expect(estEnRetard(tache, aujourdhui: aujourdhui), true);
    });

    test('Une tâche dont la date est aujourd’hui n’est pas en retard', () {
      final Tache tache = Tache(
        id: 't2',
        titre: 'Réviser',
        priorite: Priorite.normale,
        echeance: DateEcheance(DateTime(2026, 11, 21)),
      );

      expect(estEnRetard(tache, aujourdhui: aujourdhui), false);
    });

    test('Une tâche terminée n’est jamais en retard', () {
      final Tache tache = Tache(
        id: 't3',
        titre: 'Devoir terminé',
        priorite: Priorite.haute,
        echeance: DateEcheance(DateTime(2026, 11, 20)),
        faite: true,
      );

      expect(estEnRetard(tache, aujourdhui: aujourdhui), false);
    });

    test('Une tâche sans échéance n’est pas en retard', () {
      final Tache tache = Tache(
        id: 't4',
        titre: 'Lire un livre',
        priorite: Priorite.basse,
      );

      expect(estEnRetard(tache, aujourdhui: aujourdhui), false);
    });

    test('Une échéance hebdomadaire n’est pas en retard', () {
      final Tache tache = Tache(
        id: 't5',
        titre: 'Faire du sport',
        priorite: Priorite.normale,
        echeance: const EcheanceHebdomadaire(6),
      );

      expect(estEnRetard(tache, aujourdhui: aujourdhui), false);
    });
  });

  // -----------------------------------------
  // 5. Tests de la méthode bilan
  // -----------------------------------------

  group('Tests du bilan', () {
    test('Retourner zéro pour une liste vide', () {
      final resultat = bilan([]);

      expect(resultat.faites, 0);
      expect(resultat.total, 0);
    });

    test('Compter les tâches terminées et le total', () {
      final List<Tache> taches = [
        Tache(
          id: 't1',
          titre: 'Installer Flutter',
          priorite: Priorite.haute,
          faite: true,
        ),
        Tache(id: 't2', titre: 'Réviser', priorite: Priorite.normale),
        Tache(
          id: 't3',
          titre: 'Faire les courses',
          priorite: Priorite.basse,
          faite: true,
        ),
      ];

      final resultat = bilan(taches);

      expect(resultat.faites, 2);
      expect(resultat.total, 3);
    });
  });

  // -----------------------------------------
  // 6. Tests de la méthode aFaire
  // -----------------------------------------

  group('Tests des tâches à faire', () {
    test('Garder seulement les tâches non terminées', () {
      final List<Tache> taches = [
        Tache(
          id: 't1',
          titre: 'Tâche terminée',
          priorite: Priorite.haute,
          faite: true,
        ),
        Tache(id: 't2', titre: 'Tâche à faire', priorite: Priorite.normale),
      ];

      final List<Tache> resultat = aFaire(taches);

      expect(resultat.length, 1);
      expect(resultat.first.id, 't2');
    });

    test('Filtrer selon la priorité minimale', () {
      final List<Tache> taches = [
        Tache(id: 't1', titre: 'Petite tâche', priorite: Priorite.basse),
        Tache(id: 't2', titre: 'Tâche normale', priorite: Priorite.normale),
        Tache(id: 't3', titre: 'Grande tâche', priorite: Priorite.haute),
      ];

      final List<Tache> resultat = aFaire(taches, auMoins: Priorite.normale);

      expect(resultat.length, 2);
      expect(resultat[0].priorite, Priorite.haute);
      expect(resultat[1].priorite, Priorite.normale);
    });

    test('Trier par priorité puis par ordre alphabétique', () {
      final List<Tache> taches = [
        Tache(id: 't1', titre: 'Zèbre', priorite: Priorite.haute),
        Tache(id: 't2', titre: 'Banane', priorite: Priorite.haute),
        Tache(id: 't3', titre: 'Pomme', priorite: Priorite.normale),
      ];

      final List<Tache> resultat = aFaire(taches);

      expect(resultat[0].titre, 'Banane');
      expect(resultat[1].titre, 'Zèbre');
      expect(resultat[2].titre, 'Pomme');
    });

    test('Ne pas modifier la liste de départ', () {
      final List<Tache> taches = [
        Tache(id: 't1', titre: 'Zèbre', priorite: Priorite.haute),
        Tache(id: 't2', titre: 'Banane', priorite: Priorite.normale),
      ];

      final List<String> titresAvant = [];

      for (final Tache tache in taches) {
        titresAvant.add(tache.titre);
      }

      aFaire(taches);

      final List<String> titresApres = [];

      for (final Tache tache in taches) {
        titresApres.add(tache.titre);
      }

      expect(titresApres, titresAvant);
    });
  });
}
