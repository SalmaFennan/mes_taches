import 'dart:convert';

import 'package:material_ui/material_ui.dart';

import 'modele/taches.dart';
import 'donnees/exemples.dart';
import 'widgets/ligne_tache.dart';
import 'pages/detail_tache.dart';
import 'pages/ajouter_tache.dart';

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
  List<Tache> taches = [];
  String filtreSelectionne = 'Toutes';

  @override
  void initState() {
    super.initState();
    chargerTaches();
  }

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

  Future<void> ouvrirFormulaire() async {
    final Tache? nouvelleTache = await Navigator.push<Tache>(
      context,
      MaterialPageRoute(builder: (context) => const AjouterTachePage()),
    );

    if (!mounted) {
      return;
    }

    if (nouvelleTache != null) {
      setState(() {
        taches.add(nouvelleTache);
      });
    }
  }

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

  Future<void> ouvrirDetail(Tache tache) async {
    final Tache? resultat = await Navigator.push<Tache>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DetailTachePage(tache: tache, aujourdhui: DateTime.now()),
      ),
    );

    if (!mounted) {
      return;
    }

    if (resultat == null) {
      return;
    }

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

    setState(() {
      taches[indexTache] = resultat;
    });
  }

  @override
  Widget build(BuildContext context) {
    final resultatBilan = bilan(taches);
    final int nombreAFaire = resultatBilan.total - resultatBilan.faites;
    final List<Tache> tachesAffichees = obtenirTachesAffichees();
    final DateTime aujourdhui = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: const Text('Mes tâches'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '$nombreAFaire tâches à faire',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Wrap(
            spacing: 8,
            children: [
              construireFiltre('Toutes'),
              construireFiltre('À faire'),
              construireFiltre('Faites'),
            ],
          ),
          const SizedBox(height: 10),
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
        key: const ValueKey('boutonAjouterTache'),
        onPressed: ouvrirFormulaire,
        child: const Icon(Icons.add),
      ),
    );
  }
}
