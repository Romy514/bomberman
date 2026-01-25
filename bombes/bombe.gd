extends Node3D

class_name Bombe

# Paramètres de la bombe
@export var explosion_delay: float = 3.0  # Délai avant explosion (US06)
@export var explosion_range: int = 3  # Portée de l'explosion en cases (US07)
@export var grid_size: float = 1.0

# État de la bombe
var time_until_explosion: float = 0.0
var has_exploded: bool = false
var grid_position: Vector3  # Position sur la grille

# État de glissement
var is_sliding: bool = false
var slide_direction: Vector3
var slide_speed: float = 5.0

# Références
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var collision: CollisionShape3D = $CollisionShape3D


func _ready() -> void:
	grid_position = global_position
	time_until_explosion = explosion_delay
	print("Bombe posée à: ", grid_position)


func start_sliding(direction: Vector3) -> void:
	"""Démarre le glissement de la bombe dans une direction donnée."""
	if is_sliding or has_exploded:
		return

	is_sliding = true
	slide_direction = direction.normalized()
	print("Bombe commence à glisser dans la direction: ", slide_direction)


func _process(delta: float) -> void:
	if not has_exploded:
		# Gérer le glissement si en cours
		if is_sliding:
			handle_sliding(delta)
		else:
			# Compter le temps avant explosion (US06)
			time_until_explosion -= delta

			# Animation de la bombe (scintillement)
			update_bomb_animation()

			# Exploser si délai écoulé
			if time_until_explosion <= 0.0:
				explode()


func update_bomb_animation() -> void:
	"""Anime la bombe (scintillement)."""
	var animation_speed = 0.1
	var pulse = sin(get_tree().get_frame() * animation_speed) * 0.2 + 0.8
	if mesh:
		mesh.scale = Vector3.ONE * pulse


func handle_sliding(delta: float) -> void:
	"""Gère le mouvement de glissement de la bombe."""
	var move_distance = slide_speed * delta
	var new_position = global_position + slide_direction * move_distance

	# Vérifier si on peut glisser à cette position
	if can_slide_to(new_position):
		global_position = new_position
		grid_position = global_position
	else:
		# Obstacle détecté, exploser
		print("Bombe heurte un obstacle et explose à: ", grid_position)
		explode()


func can_slide_to(position: Vector3) -> bool:
	"""Vérifie si la bombe peut glisser à une position donnée."""
	# Vérifier les limites du niveau (utiliser les mêmes que le joueur)
	var level_bounds = Vector3(10, 10, 10)  # À adapter selon vos besoins
	if abs(position.x) > level_bounds.x or abs(position.z) > level_bounds.z:
		return false

	# Vérifier s'il y a un mur (indestructible OU destructible)
	if is_wall_at(position) or is_destructible_wall_at(position):
		return false

	return true


func explode() -> void:
	"""Explose et propage l'explosion en croix (US07, US08, US09)."""
	if has_exploded:
		return
	
	has_exploded = true
	print("Explosion à: ", grid_position)
	
	# Créer l'effet d'explosion
	create_explosion_effect()
	
	# Propager l'explosion en croix
	propagate_explosion()
	
	# Détruire la bombe
	queue_free()


func create_explosion_effect() -> void:
	"""Crée un effet visuel d'explosion."""
	# Si la bombe est déjà sortie de l'arbre, ne pas créer d'effet
	if not is_inside_tree():
		return
	# Créer une sphère rouge pour l'explosion
	var explosion_mesh = SphereMesh.new()
	explosion_mesh.radius = 0.5
	explosion_mesh.height = 1.0
	
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = explosion_mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color.RED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh_instance.set_surface_override_material(0, material)
	
	var particle = Node3D.new()
	particle.add_child(mesh_instance)
	particle.position = grid_position
	
	# Vérifier que le parent existe avant d'ajouter
	var parent = get_parent()
	if parent == null:
		return
	
	parent.add_child(particle)
	
	# Animer et supprimer après 0.5 secondes
	get_tree().create_timer(0.5).timeout.connect(func(): particle.queue_free())


func propagate_explosion() -> void:
	"""Propage l'explosion en croix sur plusieurs cases (US07, US08, US09)."""
	var directions = [
		Vector3(1, 0, 0),   # Droite
		Vector3(-1, 0, 0),  # Gauche
		Vector3(0, 0, 1),   # Avant
		Vector3(0, 0, -1)   # Arrière
	]
	
	# Impact immédiat sur la case de la bombe
	hit_player_at(grid_position)
	hit_enemy_at(grid_position)

	# Pour chaque direction
	for direction in directions:
		# Propager jusqu'à explosion_range cases
		for distance in range(1, explosion_range + 1):
			var explosion_position = grid_position + (direction * grid_size * distance)
			
			# Vérifier s'il y a un mur indestructible (US08)
			if is_wall_at(explosion_position):
				break  # Arrêter la propagation si mur indestructible
			
			# Créer une explosion à cette position
			create_explosion_at(explosion_position)
			hit_player_at(explosion_position)
			hit_enemy_at(explosion_position)
			
			# Vérifier s'il y a un mur destructible et l'explosion s'arrête après (US09)
			if is_destructible_wall_at(explosion_position):
				break  # Arrêter après avoir touché un mur destructible


func create_explosion_at(position: Vector3) -> void:
	"""Crée une explosion à une position donnée."""
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsShapeQueryParameters3D.new()
	var shape = SphereShape3D.new()
	shape.radius = grid_size * 0.3
	
	query.shape = shape
	query.transform.origin = position
	
	var result = space_state.intersect_shape(query)
	
	# Chercher les murs destructibles à cette position
	for collision in result:
		if collision.collider.is_in_group("destructible_wall"):
			collision.collider.destroy()
			print("Mur destructible détruit à: ", position)


func is_wall_at(position: Vector3) -> bool:
	"""Vérifie s'il y a un mur indestructible à une position (US08)."""
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsShapeQueryParameters3D.new()
	var shape = SphereShape3D.new()
	shape.radius = grid_size * 0.3
	
	query.shape = shape
	query.transform.origin = position
	
	var result = space_state.intersect_shape(query)
	
	for collision in result:
		if collision.collider.is_in_group("indestructible_wall"):
			return true
	
	return false


func is_destructible_wall_at(position: Vector3) -> bool:
	"""Vérifie s'il y a un mur destructible à une position (US09)."""
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsShapeQueryParameters3D.new()
	var shape = SphereShape3D.new()
	shape.radius = grid_size * 0.3
	
	query.shape = shape
	query.transform.origin = position
	
	var result = space_state.intersect_shape(query)
	
	for collision in result:
		if collision.collider.is_in_group("destructible_wall"):
			return true
	
	return false


func hit_player_at(position: Vector3) -> void:
	"""Vérifie si le joueur est touché par l'explosion à une position donnée (US10)."""
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsShapeQueryParameters3D.new()
	var shape = SphereShape3D.new()
	shape.radius = grid_size * 0.45

	query.shape = shape
	query.transform.origin = position

	var result = space_state.intersect_shape(query)

	for collision in result:
		if collision.collider.is_in_group("joueur"):
			print("Le joueur est touché par l'explosion!")
			var control = collision.collider.get_node_or_null("control_joueur")
			if control and control.has_method("apply_explosion_damage"):
				control.apply_explosion_damage()


func hit_enemy_at(position: Vector3) -> void:
	"""Vérifie si un ennemi est touché par l'explosion (US15)."""
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsShapeQueryParameters3D.new()
	var shape = SphereShape3D.new()
	shape.radius = grid_size * 0.45

	query.shape = shape
	query.transform.origin = position

	var result = space_state.intersect_shape(query)

	for collision in result:
		if collision.collider.is_in_group("enemy"):
			print("Ennemi touché par l'explosion!")
			if collision.collider.has_method("die"):
				collision.collider.die()


func set_position_from_grid(pos: Vector3) -> void:
	"""Place la bombe à une position de grille."""
	grid_position = pos
	global_position = pos
