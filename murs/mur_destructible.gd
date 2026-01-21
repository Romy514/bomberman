extends StaticBody3D

class_name MurDestructible

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var collision: CollisionShape3D = $CollisionShape3D


func _ready() -> void:
	# Ajouter ce mur au groupe "destructible_wall" pour les explosions (US09)
	add_to_group("destructible_wall")


func destroy() -> void:
	"""Détruit le mur (US09)."""
	print("Mur destructible détruit à: ", global_position)
	
	# Animation de destruction
	var tween = create_tween()
	tween.tween_property(mesh, "scale", Vector3.ZERO, 0.3)
	tween.tween_callback(queue_free)
