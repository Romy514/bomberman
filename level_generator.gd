extends Node3D

var level_width: int = 20
var level_length: int = 20
var tile_size: int = 2

var game_state: String = "playing"  # playing, victory, defeat

# Ressources
@export var destructible_wall_scene: PackedScene
@export var indestructible_wall_scene: PackedScene
@export var enemy_scene: PackedScene

# Paramètres
@export var wall_removal_probability: float = 0.40  # Probabilité d'enlever une case destructible
@export var indestructible_wall_probability: float = 0.20  # Probabilité d'ajouter un mur indestructible sur une case vide
@export var num_enemies: int = 3

# Grille 10x10 : 0 = vide, 1 = mur destructible, 2 = mur indestructible
var level_grid: Array = [
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
	[1, 1, 1, 1, 0, 0, 1, 1, 1, 1],
	[1, 1, 1, 1, 0, 0, 1, 1, 1, 1],
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
	[1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
]

func _ready() -> void:
	generate_level()

func generate_level() -> void:
	"""Convertit l'array en murs 3D et enlève quelques cases pour créer un parcours."""
	# Enlever aléatoirement quelques cases (sauf la zone de spawn)
	for y in range(10):
		for x in range(10):
			# Éviter la zone de spawn au centre
			if x >= 3 and x <= 6 and y >= 4 and y <= 6:
				continue
			
			# Aléatoirement enlever une case
			if level_grid[y][x] == 1 and randf() < wall_removal_probability:
				level_grid[y][x] = 0
			
			# Ajouter quelques murs indestructibles sur les cases vides
			if level_grid[y][x] == 0 and randf() < indestructible_wall_probability:
				level_grid[y][x] = 2
	
	# Placer les murs
	for y in range(10):
		for x in range(10):
			if level_grid[y][x] == 1:
				spawn_wall(x, y)
			elif level_grid[y][x] == 2:
				spawn_indestructible_wall(x, y)
	
	# Placer les ennemis
	spawn_enemies()

func spawn_wall(x: int, z: int) -> void:
	"""Instancie un mur à une position de grille."""
	if destructible_wall_scene == null:
		destructible_wall_scene = load("res://murs/mur_destructible.tscn")
	
	var wall = destructible_wall_scene.instantiate()
	# Position mondiale : chaque index = 1 case de 2m
	# Centrer la grille: (0,0) est au centre
	var world_x = (x - 4.5) * tile_size
	var world_z = (z - 4.5) * tile_size
	wall.position = Vector3(world_x, 0, world_z)
	add_child(wall)

func spawn_indestructible_wall(x: int, z: int) -> void:
	"""Instancie un mur indestructible à une position de grille."""
	if indestructible_wall_scene == null:
		indestructible_wall_scene = load("res://murs/mur_indestructible.tscn")

	if indestructible_wall_scene == null:
		return

	var wall = indestructible_wall_scene.instantiate()
	var world_x = (x - 4.5) * tile_size
	var world_z = (z - 4.5) * tile_size
	wall.position = Vector3(world_x, 0, world_z)
	add_child(wall)

func spawn_enemies() -> void:
	"""Place les ennemis sur les cases vides."""
	if enemy_scene == null:
		enemy_scene = load("res://ennemis/enemy.tscn")
	
	if enemy_scene == null:
		return
	
	var spawn_count = 0
	
	# Parcourir la grille et placer les ennemis aléatoirement sur les cases vides
	for y in range(10):
		for x in range(10):
			if spawn_count >= num_enemies:
				return
			
			# Placer un ennemi que sur les cases vides, loin de la zone de spawn
			if level_grid[y][x] == 0:
				# Éviter la zone de spawn au centre
				if x >= 3 and x <= 6 and y >= 4 and y <= 6:
					continue
				
				# Probabilité de spawn
				if randf() < 0.3:
					var world_x = (x - 4.5) * tile_size
					var world_z = (y - 4.5) * tile_size
					var enemy = enemy_scene.instantiate()
					enemy.position = Vector3(world_x, 0, world_z)
					add_child(enemy)
					spawn_count += 1
