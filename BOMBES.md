# Système de Bombes - Bomberman

## Implémentation des User Stories

### US05 - Poser une bombe
- **Action**: Appuyer sur la touche ESPACE (p_bomb)
- **Fonctionnement**: Pose une bombe à la position actuelle du joueur
- **Limite**: Maximum de bombes définissable (par défaut: 1)

### US06 - Explosion après délai fixe
- **Délai**: 3 secondes (configurable dans la scène)
- **Animation**: La bombe scintille avant d'exploser
- **Effet**: Une sphère rouge apparaît lors de l'explosion

### US07 - Propagation de l'explosion en croix
- **Portée**: 3 cases (configurable)
- **Directions**: Droite, Gauche, Avant, Arrière
- **Cas à cas**: L'explosion se propage progressivement

### US08 - Blocage par murs indestructibles
- **Comportement**: L'explosion s'arrête au premier mur indestructible
- **Utilité**: Empêche la propagation infinie

### US09 - Destruction des murs destructibles
- **Animation**: Les murs disparaissent en 0.3 secondes
- **Effet**: L'explosion s'arrête après le mur destructible

## Comment utiliser

### 1. Ajouter des murs au niveau
Dans `main.tscn`, ajouter des instances de:
- **Murs destructibles**: `res://murs/mur_destructible.tscn` (jaunes)
- **Murs indestructibles**: `res://murs/mur_indestructible.tscn` (gris)

### 2. Configuration du joueur
Dans `personnage/personnage.tscn`, le script `control_joueur.gd` gère:
- `max_bombs`: Nombre maximum de bombes simultanées
- `bomb_scene`: Lien vers la scène de bombe

### 3. Touches de contrôle
- Flèches: Déplacement
- ESPACE: Poser une bombe

## Fichiers créés

```
bombes/
  ├── bombe.gd         # Script principal de la bombe
  └── bombe.tscn       # Scène de la bombe

murs/
  ├── mur_destructible.gd   # Script des murs destructibles
  ├── mur_destructible.tscn  # Scène des murs destructibles
  ├── mur_indestructible.gd  # Script des murs indestructibles
  └── mur_indestructible.tscn # Scène des murs indestructibles
```

## Paramètres configurables

### Dans le script de la bombe (`bombe.gd`)
- `explosion_delay`: Délai avant explosion (défaut: 3.0 secondes)
- `explosion_range`: Portée de l'explosion (défaut: 3 cases)
- `grid_size`: Taille d'une case (défaut: 1.0)

### Dans le script du joueur (`control_joueur.gd`)
- `max_bombs`: Nombre maximum de bombes (défaut: 1)

## Prochaines étapes possibles
- Augmenter le nombre max de bombes quand les obstacles sont détruits
- Ajouter des bonus pour améliorer les stats
- Implémenter les dégâts aux joueurs
- Ajouter des modes multijoueur
