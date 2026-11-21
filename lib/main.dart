import 'dart:convert';

import 'package:material_ui/material_ui.dart';

import 'modele/taches.dart';
import 'donnees/exemples.dart';
import 'widgets/ligne_tache.dart';
import 'pages/detail_tache.dart';

void main() {
  runApp(const MonApplication());
}

class MonApplication extends StatelessWidget {
  const MonApplication({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mes tâches',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ListeTachesPage(),
    );
  }
}

class ListeTachesPage extends StatefulWidget {
  const ListeTachesPage({super.key});

  @override
  State<ListeTachesPage> createState() {
    return _ListeTachesPageState();
  }
}

class _ListeTachesPageState extends State<ListeTachesPage> {
  // Liste de toutes les tâches.
  List<Tache> taches = [];

  // Filtre sélectionné.
  String filtreSelectionne = 'Toutes';

  // Numéro pour créer des identifiants uniques.
  int prochainNumero = 7;

  @override
  void initState() {
    super.initState();
    chargerTaches();
  }

  // Charger les tâches depuis le JSON.
  void chargerTaches() {
    final List<dynamic> donneesJson =
        jsonDecode(tachesExempleJson) as List<dynamic>;

    final List<Tache> listeTaches = [];

    for (final dynamic element in donneesJson) {
      final Map<String, Object?> json = Map<String, Object?>.from(
        element as Map,
      );

      final Tache nouvelleTache = tacheDepuisJson(json);

      listeTaches.add(nouvelleTache);
    }

    taches = listeTaches;
  }

  // Ajouter une nouvelle tâche.
  void ajouterTache() {
    final Tache nouvelleTache = Tache(
      id: 't$prochainNumero',
      titre: 'Nouvelle tâche',
      priorite: Priorite.normale,
    );

    setState(() {
      taches.add(nouvelleTache);
      prochainNumero++;
    });
  }

  // Modifier l'état d'une tâche depuis la liste.
  void changerEtatTache(Tache tache, bool? nouvelleValeur) {
    if (nouvelleValeur == null) {
      return;
    }

    int indexTache = -1;

    for (int i = 0; i < taches.length; i++) {
      if (taches[i].id == tache.id) {
        indexTache = i;
        break;
      }
    }

    if (indexTache == -1) {
      return;
    }

    final Tache ancienneTache = taches[indexTache];

    final Tache nouvelleTache = Tache(
      id: ancienneTache.id,
      titre: ancienneTache.titre,
      priorite: ancienneTache.priorite,
      echeance: ancienneTache.echeance,
      note: ancienneTache.note,
      faite: nouvelleValeur,
    );

    setState(() {
      taches[indexTache] = nouvelleTache;
    });
  }

  // Récupérer les tâches correspondant au filtre.
  List<Tache> obtenirTachesAffichees() {
    final List<Tache> resultat = [];

    for (final Tache tache in taches) {
      if (filtreSelectionne == 'Toutes') {
        resultat.add(tache);
      } else if (filtreSelectionne == 'À faire' && !tache.faite) {
        resultat.add(tache);
      } else if (filtreSelectionne == 'Faites' && tache.faite) {
        resultat.add(tache);
      }
    }

    return resultat;
  }

  // Construire un bouton de filtre.
  Widget construireFiltre(String nomFiltre) {
    return ChoiceChip(
      label: Text(nomFiltre),
      selected: filtreSelectionne == nomFiltre,
      onSelected: (bool selectionne) {
        if (selectionne) {
          setState(() {
            filtreSelectionne = nomFiltre;
          });
        }
      },
    );
  }

  // Ouvrir le détail et récupérer la tâche modifiée.
  Future<void> ouvrirDetail(Tache tache) async {
    final Tache? resultat = await Navigator.push<Tache>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DetailTachePage(tache: tache, aujourdhui: DateTime.now()),
      ),
    );

    // Vérifier que la page existe toujours.
    if (!mounted) {
      return;
    }

    // Si aucune modification n'a été retournée, ne rien faire.
    if (resultat == null) {
      return;
    }

    // Chercher la tâche dans la liste complète.
    int indexTache = -1;

    for (int i = 0; i < taches.length; i++) {
      if (taches[i].id == resultat.id) {
        indexTache = i;
        break;
      }
    }

    if (indexTache == -1) {
      return;
    }

    // Remplacer l'ancienne tâche par la nouvelle.
    setState(() {
      taches[indexTache] = resultat;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculer le bilan global.
    final resultatBilan = bilan(taches);

    final int nombreAFaire = resultatBilan.total - resultatBilan.faites;

    // Récupérer les tâches filtrées.
    final List<Tache> tachesAffichees = obtenirTachesAffichees();

    final DateTime aujourdhui = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: const Text('Mes tâches'), centerTitle: true),

      body: Column(
        children: [
          // Compteur global.
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '$nombreAFaire tâches à faire',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          // Filtres.
          Wrap(
            spacing: 8,
            children: [
              construireFiltre('Toutes'),
              construireFiltre('À faire'),
              construireFiltre('Faites'),
            ],
          ),

          const SizedBox(height: 10),

          // Liste des tâches.
          Expanded(
            child: tachesAffichees.isEmpty
                ? const Center(child: Text('Aucune tâche à afficher'))
                : ListView.builder(
                    itemCount: tachesAffichees.length,
                    itemBuilder: (context, index) {
                      final Tache tache = tachesAffichees[index];

                      return LigneTache(
                        tache: tache,
                        aujourdhui: aujourdhui,
                        onChangerEtat: (bool? valeur) {
                          changerEtatTache(tache, valeur);
                        },
                        onOuvrir: () {
                          ouvrirDetail(tache);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: ajouterTache,
        child: const Icon(Icons.add),
      ),
    );
  }
}
