extends StaticBody3D

class_name MurIndestructible


func _ready() -> void:
	# Ajouter ce mur au groupe "indestructible_wall" pour les explosions (US08)
	add_to_group("indestructible_wall")
