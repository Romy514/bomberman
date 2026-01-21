extends StaticBody3D

class_name MurDestructible

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var collision: CollisionShape3D = $CollisionShape3D

# Paramètres de bonus (US16)
@export var bonus_drop_chance: float = 0.15  # 15% de chance de drop
var bonus_scene: PackedScene


func _ready() -> void:
	# Ajouter ce mur au groupe "destructible_wall" pour les explosions (US09)
	add_to_group("destructible_wall")
	
	# Charger la scène de bonus
	bonus_scene = load("res://bonus/bonus.tscn")


func destroy() -> void:
	"""Détruit le mur (US09) et peut faire apparaître un bonus (US16)."""
	print("Mur destructible détruit à: ", global_position)
	
	# Sauvegarder la position avant destruction
	var wall_position = global_position
	
	# Chance de faire apparaître un bonus (US16)
	spawn_bonus(wall_position)
	
	# Animation de destruction
	var tween = create_tween()
	tween.tween_property(mesh, "scale", Vector3.ZERO, 0.3)
	tween.tween_callback(queue_free)


func spawn_bonus(wall_position: Vector3) -> void:
	"""Fait apparaître un bonus aléatoirement (US16)."""
	# Vérifier si on doit faire apparaître un bonus
	if randf() > bonus_drop_chance:
		return
	
	if bonus_scene == null:
		print("Erreur: Scène de bonus non chargée!")
		return
	
	# Créer le bonus
	var bonus = bonus_scene.instantiate()
	
	# Type de bonus aléatoire (US17 ou US18)
	if randf() < 0.5:
		bonus.bonus_type = Bonus.BonusType.BOMB_COUNT  # US17
	else:
		bonus.bonus_type = Bonus.BonusType.EXPLOSION_RANGE  # US18
	
	# Positionner le bonus à l'emplacement du mur
	bonus.position = wall_position
	
	# Ajouter à la scène de manière différée pour éviter les erreurs de transform
	if is_inside_tree():
		get_tree().root.get_child(0).call_deferred("add_child", bonus)
		print("Bonus apparu à: ", wall_position, " de type: ", bonus.bonus_type)
