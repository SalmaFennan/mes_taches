import 'dart:convert';

import 'package:material_ui/material_ui.dart';

import 'modele/taches.dart';
import 'donnees/exemples.dart';

void main() {
  runApp(const MonApplication());
}

// Classe principale de l'application.
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

// Écran qui affiche la liste des tâches.
class ListeTachesPage extends StatefulWidget {
  const ListeTachesPage({super.key});

  @override
  State<ListeTachesPage> createState() {
    return _ListeTachesPageState();
  }
}

class _ListeTachesPageState extends State<ListeTachesPage> {
  List<Tache> taches = [];

  int prochainNumero = 7;
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

  // Ajouter une nouvelle tâche temporaire.
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

  // Transformer la priorité en texte.
  String afficherPriorite(Priorite priorite) {
    if (priorite == Priorite.basse) {
      return 'Basse';
    }

    if (priorite == Priorite.normale) {
      return 'Normale';
    }

    return 'Haute';
  }

  // Construire l'interface de l'écran.
  @override
  Widget build(BuildContext context) {
    final resultatBilan = bilan(taches);

    final int nombreAFaire = resultatBilan.total - resultatBilan.faites;

    return Scaffold(
      appBar: AppBar(title: const Text('Mes tâches'), centerTitle: true),

      body: Column(
        children: [
          // Afficher le nombre de tâches restantes.
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '$nombreAFaire tâches à faire',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          // Afficher la liste des tâches.
          Expanded(
            child: ListView.builder(
              itemCount: taches.length,
              itemBuilder: (context, index) {
                final Tache tache = taches[index];

                return ListTile(
                  title: Text(tache.titre),
                  subtitle: Text(
                    'Priorité : ${afficherPriorite(tache.priorite)}',
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // Bouton pour ajouter une tâche.
      floatingActionButton: FloatingActionButton(
        onPressed: ajouterTache,
        child: const Icon(Icons.add),
      ),
    );
  }
}
