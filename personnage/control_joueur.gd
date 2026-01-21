extends Node

signal game_over_signal

@onready var joueur: CharacterBody3D = get_parent()

# Paramètres de déplacement et grille
@export var grid_size: float = 1.0
@export var move_duration: float = 0.2

# Paramètres de limites du niveau
@export var level_bounds: Vector3 = Vector3(10, 10, 10)

# Paramètres de la caméra
@export var camera_offset: Vector3 = Vector3(0, 15, 0)  # Vue du dessus

# Paramètres de bombes (US05)
@export var bomb_scene: PackedScene
@export var max_bombs: int = 1
@export var bomb_placement_distance: float = 2.0  # Distance devant le joueur pour poser la bombe (en mètres)
var bombs_placed: Array = []  # Liste des bombes posées

# Paramètres de bonus (US17, US18)
var current_explosion_range: int = 3  # Portée des explosions (US18)
var base_max_bombs: int = 1  # Valeur de base
var base_explosion_range: int = 3  # Valeur de base

# Timers de bonus temporaires
var bomb_bonus_timer: float = 0.0
var range_bonus_timer: float = 0.0
var bonus_duration: float = 15.0  # Durée des bonus en secondes

# Animation de bonus
var active_bonus_type: String = ""  # "bomb" ou "range" ou ""

# Paramètres de vie (US10, US11, US12)
@export var max_lives: int = 3
@export var invincibility_duration: float = 2.0  # Durée d'invincibilité après dégâts
var current_lives: int
var spawn_position: Vector3
var is_alive: bool = true
var is_invincible: bool = false
var invincibility_timer: float = 0.0

# Variables de mouvement
var current_grid_position: Vector3
var target_grid_position: Vector3
var is_moving: bool = false
var movement_progress: float = 0.0
var camera: Camera3D
var last_move_dir: Vector3 = Vector3(0, 0, -1)

func _ready() -> void:
	current_grid_position = joueur.global_position
	target_grid_position = current_grid_position
	camera = get_viewport().get_camera_3d()
	print("Script chargé, position initiale: ", current_grid_position)
	spawn_position = current_grid_position
	current_lives = max_lives
	
	# Initialiser les valeurs de base des bonus
	base_max_bombs = max_bombs
	base_explosion_range = current_explosion_range
	
	# Ajouter le joueur au groupe "joueur" pour les collisions d'explosions
	joueur.add_to_group("joueur")
	
	# Charger la scène de bombe
	if bomb_scene == null:
		bomb_scene = load("res://bombes/bombe.tscn")


func _process(delta: float) -> void:
	if camera != null:
		update_camera()
	
	# Gestion de l'invincibilité
	if is_invincible:
		invincibility_timer -= delta
		update_invincibility_animation()
		if invincibility_timer <= 0.0:
			is_invincible = false
			reset_invincibility_animation()
	
	# Gestion des timers de bonus temporaires
	update_bonus_timers(delta)
	
	# Gestion des bombes (US05, US06)
	if is_alive and Input.is_action_just_pressed("p_bomb"):
		place_bomb()


func _physics_process(delta: float) -> void:
	if not is_alive:
		return
	handle_player_movement(delta)
	joueur.move_and_slide()
	check_enemy_contact()


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
			last_move_dir = input_direction.normalized()
			update_orientation(last_move_dir)
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
	# Vérifier s'il y a une bombe à cette position
	if is_bomb_at(position):
		print("Collision avec une bombe à: ", position)
		return true
	
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


func check_enemy_contact() -> void:
	"""Detecte un contact direct avec un ennemi (US14)."""
	# Ne pas prendre de dégâts si invincible
	if is_invincible:
		return
	
	var space_state = joueur.get_world_3d().direct_space_state
	var query = PhysicsShapeQueryParameters3D.new()
	var shape = SphereShape3D.new()
	shape.radius = max(grid_size * 0.6, 0.8)

	query.shape = shape
	var origin = joueur.global_position
	origin.y = 0  # aligner au sol pour toucher les ennemis centrés à y=0
	query.transform.origin = origin

	var result = space_state.intersect_shape(query)

	for collision in result:
		if collision.collider.is_in_group("enemy"):
			apply_explosion_damage()
			return


func update_camera() -> void:
	"""Met à jour la position de la caméra pour suivre le joueur - vue du dessus."""
	if camera == null:
		return
	
	# Positionner la caméra directement au-dessus du joueur
	var camera_target_position = joueur.global_position + camera_offset
	camera.global_position = camera.global_position.lerp(camera_target_position, 0.1)
	
	# Regarder directement vers le bas
	camera.look_at(joueur.global_position, Vector3(0, 0, -1))


func apply_explosion_damage() -> void:
	"""Applique des dégâts au joueur lorsqu'il est touché par une explosion (US10)."""
	if not is_alive or is_invincible:
		return
	current_lives -= 1
	print("Joueur touché! Vies restantes: ", current_lives)
	
	if current_lives <= 0:
		game_over()
	else:
		# Réapparition à la position de spawn (US12)
		respawn_player()
		is_invincible = true
		invincibility_timer = invincibility_duration


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
	is_invincible = false
	joueur.velocity = Vector3.ZERO
	print("Game Over - plus de vies")
	reset_invincibility_animation()
	emit_signal("game_over_signal")


func place_bomb() -> void:
	"""Place une bombe 1 case (2m) devant le joueur (US05)."""
	# Vérifier si on a atteint la limite de bombes
	if bombs_placed.size() >= max_bombs:
		print("Nombre maximum de bombes atteint!")
		return
	
	# Calculer la position cible devant le joueur
	var dir = last_move_dir
	if dir == Vector3.ZERO:
		dir = Vector3(0, 0, -1)
	var bomb_position = current_grid_position + dir.normalized() * bomb_placement_distance
	
	# Arrondir à la grille pour placer au centre de la case 2x2m
	bomb_position.x = round(bomb_position.x / grid_size) * grid_size
	bomb_position.z = round(bomb_position.z / grid_size) * grid_size

	# Vérifier qu'il n'y a pas de mur à cette position (destructible OU indestructible)
	if is_wall_at_position(bomb_position):
		print("Impossible de placer une bombe dans un mur!")
		return

	# Vérifier s'il y a déjà une bombe à cette position
	if is_bomb_at(bomb_position):
		print("Une bombe existe déjà à cette position!")
		return

	# Vérifier les limites
	if not is_within_bounds(bomb_position):
		print("Position de bombe hors limites: ", bomb_position)
		return
	
	# Créer la bombe
	if bomb_scene == null:
		print("Erreur: Scène de bombe non chargée!")
		return
	
	var bomb = bomb_scene.instantiate()
	bomb.grid_size = grid_size
	bomb.explosion_range = current_explosion_range  # Appliquer la portée actuelle (US18)

	# Ajouter d'abord à la scène, puis positionner en global
	get_tree().root.get_child(0).add_child(bomb)
	bomb.grid_position = bomb_position
	bomb.global_position = bomb_position + Vector3(0, 0.25, 0)
	bombs_placed.append(bomb)
	
	print("Bombe posée à: ", bomb_position)
	
	# Retirer la bombe de la liste quand elle explose
	await bomb.tree_exited
	bombs_placed.erase(bomb)


func is_bomb_at(position: Vector3) -> bool:
	"""Vérifie s'il y a une bombe à une position donnée."""
	for bomb in bombs_placed:
		if bomb.grid_position.distance_to(position) < grid_size * 0.5:
			return true
	return false


func is_wall_at_position(position: Vector3) -> bool:
	"""Vérifie s'il y a un mur (destructible ou indestructible) à une position."""
	var space_state = joueur.get_world_3d().direct_space_state
	var query = PhysicsShapeQueryParameters3D.new()
	var shape = SphereShape3D.new()
	shape.radius = grid_size * 0.3
	
	query.shape = shape
	query.transform.origin = position
	
	var result = space_state.intersect_shape(query)
	
	for collision in result:
		if collision.collider.is_in_group("destructible_wall") or collision.collider.is_in_group("indestructible_wall"):
			return true
	
	return false


func update_invincibility_animation() -> void:
	"""Anime le joueur pendant l'invincibilité (pulsing de la scale)."""
	# Faire pulser la scale du joueur
	var animation_speed = 0.1
	var pulse = sin(get_tree().get_frame() * animation_speed) * 0.15 + 0.85
	joueur.scale = Vector3.ONE * pulse


func reset_invincibility_animation() -> void:
	"""Restaure l'apparence normale du joueur."""
	joueur.scale = Vector3.ONE


func update_orientation(dir: Vector3) -> void:
	"""Tourne le joueur dans la direction du déplacement."""
	if dir == Vector3.ZERO:
		return
	# Godot : forward = -Z. Yaw pour faire face à la direction entrée
	var yaw = atan2(dir.x, -dir.z)
	joueur.rotation.y = yaw


func increase_max_bombs() -> void:
	"""Augmente temporairement le nombre de bombes que le joueur peut poser (US17)."""
	max_bombs += 1
	bomb_bonus_timer = bonus_duration
	active_bonus_type = "bomb"
	print("Bonus bombes collecté! Nouveau max: ", max_bombs, " pour ", bonus_duration, "s")


func increase_explosion_range() -> void:
	"""Augmente temporairement la portée des explosions (US18)."""
	current_explosion_range += 1
	range_bonus_timer = bonus_duration
	active_bonus_type = "range"
	print("Bonus portée collecté! Nouvelle portée: ", current_explosion_range, " pour ", bonus_duration, "s")


func update_bonus_timers(delta: float) -> void:
	"""Met à jour les timers des bonus temporaires."""
	# Timer du bonus de bombes
	if bomb_bonus_timer > 0.0:
		bomb_bonus_timer -= delta
		if bomb_bonus_timer <= 0.0:
			# Restaurer la valeur de base
			max_bombs = base_max_bombs
			bomb_bonus_timer = 0.0
			print("Bonus bombes expiré! Retour à: ", max_bombs)
			# Si c'était le bonus actif, retirer l'animation
			if active_bonus_type == "bomb":
				active_bonus_type = ""
				reset_bonus_animation()
	
	# Timer du bonus de portée
	if range_bonus_timer > 0.0:
		range_bonus_timer -= delta
		if range_bonus_timer <= 0.0:
			# Restaurer la valeur de base
			current_explosion_range = base_explosion_range
			range_bonus_timer = 0.0
			print("Bonus portée expiré! Retour à: ", current_explosion_range)
			# Si c'était le bonus actif, retirer l'animation
			if active_bonus_type == "range":
				active_bonus_type = ""
				reset_bonus_animation()
	
	# Appliquer l'animation de bonus si un bonus est actif
	if active_bonus_type != "":
		update_bonus_animation()


func update_bonus_animation() -> void:
	"""Applique une animation visuelle selon le bonus actif."""
	var mesh_nodes = joueur.find_children("*", "MeshInstance3D")
	if mesh_nodes.is_empty():
		return
	
	for mesh_node in mesh_nodes:
		var mesh_instance = mesh_node as MeshInstance3D
		if mesh_instance == null:
			continue
		
		# Créer un matériau avec une couleur selon le type de bonus
		var material = StandardMaterial3D.new()
		
		if active_bonus_type == "bomb":
			# Bleu pour le bonus de bombes
			var pulse = sin(Time.get_ticks_msec() / 100.0) * 0.3 + 0.7
			material.albedo_color = Color(0.2 * pulse, 0.5 * pulse, 1.0 * pulse)
		elif active_bonus_type == "range":
			# Orange pour le bonus de portée
			var pulse = sin(Time.get_ticks_msec() / 100.0) * 0.3 + 0.7
			material.albedo_color = Color(1.0 * pulse, 0.6 * pulse, 0.2 * pulse)
		
		material.emission_enabled = true
		material.emission = material.albedo_color
		material.emission_energy = 0.3
		
		mesh_instance.set_surface_override_material(0, material)


func reset_bonus_animation() -> void:
	"""Restaure l'apparence normale du joueur après expiration du bonus."""
	var mesh_nodes = joueur.find_children("*", "MeshInstance3D")
	for mesh_node in mesh_nodes:
		var mesh_instance = mesh_node as MeshInstance3D
		if mesh_instance:
			mesh_instance.set_surface_override_material(0, null)
