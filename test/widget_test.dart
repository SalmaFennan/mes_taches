// Un premier test de widget qui vérifie que l'application démarre.
// Gardez-le (adaptez-le si votre écran change de titre)
// et écrivez vos propres tests dans ce dossier
// (partie F du sujet, fiche « Tests » de l'annexe).

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mes_taches/main.dart';

import 'dart:ui' show Size;

void main() {
  testWidgets("L'application démarre et affiche son titre", (tester) async {
    await tester.pumpWidget(const MonApplication());

    expect(find.text('Mes tâches'), findsOneWidget);
  });

  testWidgets('Le compteur diminue quand une tâche est terminée', (
    tester,
  ) async {
    await tester.pumpWidget(const MonApplication());

    expect(find.text('5 tâches à faire'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('case-t2')));
    await tester.pumpAndSettle();

    expect(find.text('4 tâches à faire'), findsOneWidget);
  });

  testWidgets('Le filtre Faites affiche les tâches terminées', (tester) async {
    await tester.pumpWidget(const MonApplication());

    await tester.tap(find.text('Faites'));
    await tester.pumpAndSettle();

    expect(find.text('Installer Flutter'), findsOneWidget);
    expect(find.text('Relire le CM 01'), findsNothing);
    expect(find.text('5 tâches à faire'), findsOneWidget);
  });

  testWidgets('Une tâche terminée depuis le détail est mise à jour', (
    tester,
  ) async {
    await tester.pumpWidget(const MonApplication());

    await tester.tap(find.text('À faire'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Relire le CM 01'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Marquer comme terminée'));
    await tester.pumpAndSettle();

    expect(find.text('Relire le CM 01'), findsNothing);
    expect(find.text('4 tâches à faire'), findsOneWidget);
  });

  testWidgets('Le formulaire refuse un titre vide', (tester) async {
    // Augmenter la hauteur de l'écran pour afficher le formulaire.
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MonApplication());

    await tester.tap(find.byKey(const ValueKey('boutonAjouterTache')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    expect(find.text('Le titre est obligatoire.'), findsOneWidget);
    expect(find.text('Ajouter une tâche'), findsOneWidget);
  });

  testWidgets('Une nouvelle tâche valide apparaît dans la liste', (
    tester,
  ) async {
    // Augmenter la hauteur de l'écran pour afficher le formulaire.
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MonApplication());

    // Ouvrir le formulaire.
    await tester.tap(find.byKey(const ValueKey('boutonAjouterTache')));
    await tester.pumpAndSettle();

    // Trouver le champ du titre.
    final champTitre = find.byKey(const ValueKey('champTitreTache'));

    // Cliquer sur le champ puis saisir le titre.
    await tester.tap(champTitre);
    await tester.enterText(champTitre, 'Préparer le TP Flutter');
    await tester.pumpAndSettle();

    // Enregistrer la nouvelle tâche.
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    // Vérifier que le formulaire s'est fermé.
    expect(find.text('Ajouter une tâche'), findsNothing);

    // Vérifier que la nouvelle tâche apparaît dans la liste.
    expect(find.text('Préparer le TP Flutter'), findsOneWidget);

    // Vérifier que le compteur a augmenté.
    expect(find.text('6 tâches à faire'), findsOneWidget);
  });
}
