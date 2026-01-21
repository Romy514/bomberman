extends Node

signal game_over_signal

@onready var joueur: CharacterBody3D = get_parent()

# Paramètres de déplacement et grille
@export var grid_size: float = 1.0
@export var move_duration: float = 0.2

# Paramètres de limites du niveau
@export var level_bounds: Vector3 = Vector3(10, 10, 10)

# Paramètres de la caméra
@export var camera_offset: Vector3 = Vector3(5, 5, 5)

# Paramètres de bombes (US05)
@export var bomb_scene: PackedScene
@export var max_bombs: int = 1
var bombs_placed: Array = []  # Liste des bombes posées

# Paramètres de vie (US10, US11, US12)
@export var max_lives: int = 3
var current_lives: int
var spawn_position: Vector3
var is_alive: bool = true

# Variables de mouvement
var current_grid_position: Vector3
var target_grid_position: Vector3
var is_moving: bool = false
var movement_progress: float = 0.0
var camera: Camera3D

func _ready() -> void:
	current_grid_position = joueur.global_position
	target_grid_position = current_grid_position
	camera = get_viewport().get_camera_3d()
	print("Script chargé, position initiale: ", current_grid_position)
	spawn_position = current_grid_position
	current_lives = max_lives
	
	# Ajouter le joueur au groupe "joueur" pour les collisions d'explosions
	joueur.add_to_group("joueur")
	
	# Charger la scène de bombe
	if bomb_scene == null:
		bomb_scene = load("res://bombes/bombe.tscn")


func _process(delta: float) -> void:
	if camera != null:
		update_camera()
	
	# Gestion des bombes (US05, US06)
	if is_alive and Input.is_action_just_pressed("p_bomb"):
		place_bomb()


func _physics_process(delta: float) -> void:
	if not is_alive:
		return
	handle_player_movement(delta)
	joueur.move_and_slide()


func handle_player_movement(delta: float) -> void:
	"""Gère le déplacement du joueur sur la grille."""
	if not is_alive:
		return
	# Si pas en mouvement, vérifier les inputs
	if not is_moving:
		var input_direction = Vector3.ZERO
		
		# Récupérer les entrées
		if Input.is_action_pressed("p_front"):
			input_direction.z -= 1
		elif Input.is_action_pressed("p_back"):
			input_direction.z += 1
		elif Input.is_action_pressed("p_right"):
			input_direction.x += 1
		elif Input.is_action_pressed("p_left"):
			input_direction.x -= 1
		
		# Si une direction est pressée
		if input_direction != Vector3.ZERO:
			# Calculer la prochaine position
			var next_position = current_grid_position + (input_direction * grid_size)
			
			# Vérifier les limites
			if is_within_bounds(next_position):
				# Vérifier les collisions
				if not is_collision_at(next_position):
					# Démarrer le mouvement
					target_grid_position = next_position
					is_moving = true
					movement_progress = 0.0
					print("Déplacement vers: ", next_position)
	
	# Gérer la progression du mouvement
	if is_moving:
		movement_progress += delta / move_duration
		
		if movement_progress >= 1.0:
			# Mouvement terminé
			movement_progress = 1.0
			current_grid_position = target_grid_position
			joueur.global_position = current_grid_position
			joueur.velocity = Vector3.ZERO
			is_moving = false
			print("Arrivée à: ", current_grid_position)
		else:
			# Interpolation
			joueur.global_position = current_grid_position.lerp(target_grid_position, movement_progress)
			joueur.velocity = Vector3.ZERO


func is_within_bounds(position: Vector3) -> bool:
	"""Vérifie si une position est dans les limites du niveau."""
	var within = (abs(position.x) <= level_bounds.x and 
				 abs(position.z) <= level_bounds.z)
	if not within:
		print("Hors limites: ", position)
	return within


func is_collision_at(position: Vector3) -> bool:
	"""Vérifie s'il y a une collision à une position donnée."""
	var space_state = joueur.get_world_3d().direct_space_state
	var query = PhysicsShapeQueryParameters3D.new()
	var shape = SphereShape3D.new()
	shape.radius = grid_size * 0.3
	
	query.shape = shape
	query.transform.origin = position
	
	var result = space_state.intersect_shape(query)
	
	for collision in result:
		if collision.collider != joueur:
			print("Collision détectée à: ", position)
			return true
	
	return false


func update_camera() -> void:
	"""Met à jour la position de la caméra pour suivre le joueur."""
	if camera == null:
		return
	
	var camera_target_position = joueur.global_position + camera_offset
	camera.global_position = camera.global_position.lerp(camera_target_position, 0.1)
	camera.look_at(joueur.global_position + Vector3(0, 1, 0), Vector3.UP)


func apply_explosion_damage() -> void:
	"""Applique des dégâts au joueur lorsqu'il est touché par une explosion (US10)."""
	if not is_alive:
		return
	current_lives -= 1
	print("Joueur touché! Vies restantes: ", current_lives)
	if current_lives <= 0:
		game_over()
	else:
		respawn_player()


func respawn_player() -> void:
	"""Réapparition du joueur à la position de départ (US12)."""
	is_moving = false
	movement_progress = 0.0
	current_grid_position = spawn_position
	target_grid_position = spawn_position
	joueur.global_position = spawn_position
	joueur.velocity = Vector3.ZERO
	print("Réapparition à: ", spawn_position)


func game_over() -> void:
	"""Fin de partie quand il n'y a plus de vies (US11)."""
	is_alive = false
	is_moving = false
	joueur.velocity = Vector3.ZERO
	print("Game Over - plus de vies")
	emit_signal("game_over_signal")


func place_bomb() -> void:
	"""Place une bombe à la position actuelle du joueur (US05)."""
	# Vérifier si on a atteint la limite de bombes
	if bombs_placed.size() >= max_bombs:
		print("Nombre maximum de bombes atteint!")
		return
	
	# Vérifier s'il y a déjà une bombe à cette position
	if is_bomb_at(current_grid_position):
		print("Une bombe existe déjà à cette position!")
		return
	
	# Créer la bombe
	if bomb_scene == null:
		print("Erreur: Scène de bombe non chargée!")
		return
	
	var bomb = bomb_scene.instantiate()
	bomb.set_position_from_grid(current_grid_position)
	bomb.grid_size = grid_size
	
	# Ajouter la bombe à la scène
	get_tree().root.get_child(0).add_child(bomb)
	bombs_placed.append(bomb)
	
	print("Bombe posée à: ", current_grid_position)
	
	# Retirer la bombe de la liste quand elle explose
	await bomb.tree_exited
	bombs_placed.erase(bomb)


func is_bomb_at(position: Vector3) -> bool:
	"""Vérifie s'il y a une bombe à une position donnée."""
	for bomb in bombs_placed:
		if bomb.grid_position.distance_to(position) < grid_size * 0.5:
			return true
	return false
