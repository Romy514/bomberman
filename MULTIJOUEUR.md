# Mode Multijoueur - Bomberman

## User Stories Implémentées

### US23 - Rejoindre une partie en cours
Le joueur 2 peut rejoindre à tout moment pendant la partie en appuyant sur **ENTRÉE**.

### US24 - Écran de victoire/défaite multijoueur
L'écran de fin de partie affiche maintenant des informations spécifiques au mode multijoueur :
- Si les deux joueurs gagnent ensemble
- Si un seul joueur survit à la victoire
- Si les deux joueurs sont éliminés
- Si un seul joueur est éliminé

### US25 - Différenciation visuelle
- **Joueur 1** : Couleur **BLEUE**
- **Joueur 2** : Couleur **ROUGE**

## Contrôles

### Joueur 1 (Bleu)
- **Flèches directionnelles** : Déplacement
  - ↑ : Haut
  - ↓ : Bas
  - → : Droite
  - ← : Gauche
- **ESPACE** : Poser une bombe

### Joueur 2 (Rouge)
- **ZQSD** : Déplacement
  - Z : Haut
  - S : Bas
  - D : Droite
  - Q : Gauche
- **A** : Poser une bombe
- **ENTRÉE** : Rejoindre la partie

## Comment jouer en multijoueur

1. Lancer le jeu (le joueur 1 commence seul)
2. Le joueur 2 appuie sur **ENTRÉE** pour rejoindre
3. Le joueur 2 apparaît en rouge à la position (8, 0, 8)
4. Les deux joueurs peuvent jouer simultanément
5. Si un joueur meurt, l'autre peut continuer
6. La victoire est partagée si tous les ennemis sont éliminés
7. La défaite survient uniquement si les deux joueurs sont éliminés

## Positions de départ

- **Joueur 1** : Position (0, 0, 0) - Coin supérieur gauche
- **Joueur 2** : Position (8, 0, 8) - Coin inférieur droit

## Fonctionnalités

- ✅ Rejoindre en cours de partie
- ✅ Couleurs différentes pour chaque joueur
- ✅ Contrôles indépendants
- ✅ Gestion des vies individuelles
- ✅ Écrans de victoire/défaite adaptés au multijoueur
- ✅ Continuation possible si un seul joueur meurt
- ✅ Invincibilité individuelle après dégâts
- ✅ Bombes et bonus indépendants

## Notes techniques

### Fichiers modifiés

1. **project.godot**
   - Ajout des actions d'input pour le joueur 2
   - Actions : p2_left, p2_right, p2_front, p2_back, p2_bomb, p2_join

2. **personnage/control_joueur.gd**
   - Ajout de la variable `player_id` pour identifier le joueur
   - Adaptation des inputs selon le joueur
   - Ajout aux groupes "joueur1" ou "joueur2"

3. **personnage/player_visual.gd** (nouveau)
   - Gère l'apparence visuelle du joueur
   - Applique la couleur selon player_id

4. **main.gd**
   - Gestion du spawn du joueur 2
   - Tracking de l'état des deux joueurs
   - Logique de victoire/défaite multijoueur

5. **ui/game_over_ui.gd**
   - Nouvelles méthodes : `show_multiplayer_victory()` et `show_multiplayer_defeat()`
   - Affichage adapté selon l'état des joueurs

## Configuration dans l'éditeur Godot

Pour que le mode multijoueur fonctionne correctement :

1. Ouvrir la scène `main.tscn`
2. Sélectionner le nœud racine "Main"
3. Dans l'inspecteur, vérifier que `player2_scene` pointe vers `res://personnage/personnage.tscn`
4. Sauvegarder la scène

## Améliorations futures possibles

- Ajouter des positions de spawn aléatoires
- Permettre plus de 2 joueurs
- Ajouter un système de score
- Compteur de kills par joueur
- Mode versus (joueurs s'affrontent)
- Configuration des couleurs dans les paramètres
