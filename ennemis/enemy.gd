extends CharacterBody3D

@export var move_speed: float = 3.0
@export var change_dir_time: float = 1.5
@export var grid_size: float = 1.0
@export var look_ahead_distance: float = 0.7

var move_dir: Vector3 = Vector3.FORWARD
var timer: float = 0.0

func _ready() -> void:
	add_to_group("enemy")
	set_physics_process(true)
	_randomize_dir()

func _physics_process(delta: float) -> void:
	timer -= delta
	if timer <= 0.0:
		_randomize_dir()
	
	# Vérifier s'il y a un obstacle devant
	if _has_obstacle_ahead():
		_randomize_dir()
	
	velocity = move_dir * move_speed
	move_and_slide()
	
	# Si collision, changer de direction immédiatement
	if get_slide_collision_count() > 0:
		_randomize_dir()

func _randomize_dir() -> void:
	var dirs = [Vector3(1,0,0), Vector3(-1,0,0), Vector3(0,0,1), Vector3(0,0,-1)]
	move_dir = dirs[randi() % dirs.size()]
	timer = change_dir_time

func _has_obstacle_ahead() -> bool:
	"""Vérifie s'il y a un obstacle à proximité dans la direction actuelle."""
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsShapeQueryParameters3D.new()
	var shape = SphereShape3D.new()
	shape.radius = 0.4
	
	query.shape = shape
	query.transform.origin = global_position + (move_dir * look_ahead_distance)
	
	var result = space_state.intersect_shape(query)
	
	for collision in result:
		# Ignorer les autres ennemis et le joueur
		if not (collision.collider.is_in_group("enemy") or collision.collider.is_in_group("joueur")):
			return true
	
	return false

func die() -> void:
	queue_free()
