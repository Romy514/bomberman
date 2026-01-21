extends Node

@onready var joueur: CharacterBody3D = get_parent()
@onready var camera: Camera3D = get_tree().root.get_child(0).find_child("Camera3D")

# Paramètres de déplacement et grille
@export var grid_size: float = 1.0  # Taille d'une cellule de grille
@export var move_speed: float = 5.0  # Vitesse de déplacement
@export var move_duration: float = 0.2  # Durée du déplacement entre deux cases

# Paramètres de limites du niveau
@export var level_bounds: Vector3 = Vector3(10, 10, 10)  # Limites du niveau (demi-dimensions)

# Paramètres de la caméra
@export var camera_offset: Vector3 = Vector3(5, 5, 5)  # Offset de la caméra par rapport au joueur
@export var camera_distance: float = 8.0  # Distance de la caméra

# Variables de mouvement
var current_grid_position: Vector3  # Position actuelle sur la grille
var target_grid_position: Vector3  # Position cible sur la grille
var is_moving: bool = false  # Le joueur est-il en train de se déplacer?
var movement_progress: float = 0.0  # Progression du mouvement (0-1)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Initialiser la position sur la grille
	current_grid_position = joueur.global_position
	target_grid_position = current_grid_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Mettre à jour la caméra pour suivre le joueur (US03)
	update_camera()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# Gérer le mouvement du joueur sur la grille (US01 + US02 + US04)
	handle_player_movement(delta)
	
	# Appliquer le mouvement avec collision
	joueur.move_and_slide()


func handle_player_movement(delta: float) -> void:
	"""
	Gère le déplacement du joueur sur la grille avec collisions et limites.
	US01 - Déplacement sur grille
	US02 - Collision avec murs
	US04 - Limites du niveau
	"""
	
	# Si le joueur n'est pas en mouvement, vérifier l'input
	if not is_moving:
		var input_direction = Vector3.ZERO
		
		# Récupérer l'input du joueur
		if Input.is_action_pressed("p_front"):
			input_direction.z += 1
		if Input.is_action_pressed("p_back"):
			input_direction.z -= 1
		if Input.is_action_pressed("p_right"):
			input_direction.x += 1
		if Input.is_action_pressed("p_left"):
			input_direction.x -= 1
		
		# Normaliser la direction
		if input_direction != Vector3.ZERO:
			input_direction = input_direction.normalized()
			
			# Calculer la prochaine position sur la grille
			var next_position = current_grid_position + (input_direction * grid_size)
			
			# Vérifier les limites du niveau (US04)
			if is_within_bounds(next_position):
				# Vérifier les collisions avec les murs (US02)
				if not is_collision_at(next_position):
					# Démarrer le mouvement vers la nouvelle case
					target_grid_position = next_position
					is_moving = true
					movement_progress = 0.0
	
	# Gérer la progression du mouvement si en mouvement
	if is_moving:
		movement_progress += delta / move_duration
		
		if movement_progress >= 1.0:
			# Mouvement terminé
			movement_progress = 1.0
			current_grid_position = target_grid_position
			joueur.global_position = current_grid_position
			joueur.velocity = Vector3.ZERO
			is_moving = false
		else:
			# Interpoler entre la position actuelle et la position cible
			joueur.global_position = current_grid_position.lerp(target_grid_position, movement_progress)
			joueur.velocity = Vector3.ZERO


func is_within_bounds(position: Vector3) -> bool:
	"""
	Vérifie si une position est dans les limites du niveau (US04).
	"""
	return (abs(position.x) <= level_bounds.x and 
			abs(position.z) <= level_bounds.z)


func is_collision_at(position: Vector3) -> bool:
	"""
	Vérifie s'il y a une collision à une position donnée (US02).
	Utilise un rayon pour détecter les murs.
	"""
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsShapeQueryParameters3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(grid_size * 0.8, 2.0, grid_size * 0.8)
	
	query.shape = shape
	query.transform.origin = position
	query.collision_mask = 1  # Vérifier la couche de collision 1
	
	var result = space_state.intersect_shape(query)
	
	# Si c'est une collision avec le joueur lui-même, l'ignorer
	if result.size() > 0:
		for collision in result:
			if collision.collider != joueur:
				return true
	
	return false


func update_camera() -> void:
	"""
	Met à jour la position de la caméra pour suivre le joueur (US03).
	"""
	if camera == null:
		return
	
	# Calculer la position cible de la caméra
	var camera_target_position = joueur.global_position + camera_offset
	
	# Suivre en douceur le joueur
	camera.global_position = camera.global_position.lerp(camera_target_position, 0.1)
	
	# Faire regarder la caméra vers le joueur
	camera.look_at(joueur.global_position + Vector3(0, 1, 0), Vector3.UP)
