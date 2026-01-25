# Bomberman 3D – Programmation Multimédia TD2

Projet réalisé dans le cadre du **TD 2 de Programmation Multimédia**  
Janvier 2026  
Encadrant : **Gaël Fenet-Garde**

Equipe : **Naila Bon**, **Nolhan Biblocque**, **Romy Chauvière**

## 🎮 Présentation du jeu

Le projet consiste à développer un **clone simple de Bomberman (NES)**, transposé en **3D**.

Le joueur évolue sur une **grille**, pose des bombes, détruit des obstacles, évite des ennemis et collecte des bonus afin d’éliminer tous les ennemis du niveau.

Un vote sera organisé en fin de projet pour récompenser le jeu le plus fun.

## 🛠️ Technologies utilisées

- Moteur : Godot
- Langage : GScript
- Plateforme cible : **Web**
- Gestion de version : **Git / GitHub**
- Gestion de projet : **GitHub Projects (Kanban)**

## 📦 Organisation du projet

Le projet est organisé autour de :
- **User Stories** implémentées progressivement
- Un **tableau Kanban** sur GitHub Projects
- Des **commits réguliers et justifiés**

## 🧩 Fonctionnalités implémentées

### Déplacement et caméra
- Déplacement du joueur sur une grille 3D
- Collision avec les murs
- Caméra suivant le joueur
- Limites du niveau bloquantes

### Bombes
- Pose de bombes
- Explosion après un délai
- Propagation en croix
- Blocage par murs indestructibles
- Destruction des murs destructibles

### Joueur et vies
- Perte de vie en cas d’explosion
- Réapparition après une mort
- Fin de partie lorsque toutes les vies sont perdues

### Ennemis
- Déplacement automatique des ennemis
- Dégâts au contact
- Élimination par explosion

### Bonus
- Apparition de bonus après destruction de murs
- Augmentation du nombre de bombes
- Augmentation de la portée des explosions

### Niveau et victoire
- Génération du niveau à partir d’une grille
- Victoire lorsque tous les ennemis sont éliminés
- Écran de victoire ou de défaite

### Gameplay avancé
- Possibilité de **pousser les bombes** avec un coup de pied

### Multijoueur local
- Ajout d’un second joueur en cours de partie
- Différenciation visuelle du joueur 2
- Écran de fin de partie prenant en compte plusieurs joueurs

## 🚀 Lancement du projet

1. Cloner le dépôt :
   ```bash
   git clone https://github.com/nom-du-groupe/bomberman-3d.git
2. Ouvrir le projet dans le moteur de jeu
3. Lancer la scène principale

OU 

1. Cliquer sur ce lien : https://romyy514.itch.io/bomberman
2. Appuyer sur 'Run Game'
