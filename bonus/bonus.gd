extends Area3D

class_name Bonus

enum BonusType {
	BOMB_COUNT,  # US17 - Augmente le nombre de bombes
	EXPLOSION_RANGE  # US18 - Augmente la portée des explosions
}

@export var bonus_type: BonusType = BonusType.BOMB_COUNT

@onready var mesh: MeshInstance3D = $MeshInstance3D


func _ready() -> void:
	# Ajouter au groupe bonus
	add_to_group("bonus")
	
	# Connecter le signal de collision
	body_entered.connect(_on_body_entered)
	
	# Colorer le bonus selon son type
	update_bonus_appearance()
	
	print("Bonus créé de type: ", bonus_type)


func update_bonus_appearance() -> void:
	"""Change l'apparence du bonus selon son type."""
	if mesh == null:
		return
	
	var material = StandardMaterial3D.new()
	
	match bonus_type:
		BonusType.BOMB_COUNT:
			# Bleu pour le bonus de bombes
			material.albedo_color = Color(0.2, 0.5, 1.0)
		BonusType.EXPLOSION_RANGE:
			# Orange pour le bonus de portée
			material.albedo_color = Color(1.0, 0.6, 0.2)
	
	material.emission_enabled = true
	material.emission = material.albedo_color
	material.emission_energy = 0.5
	
	mesh.set_surface_override_material(0, material)


func _process(delta: float) -> void:
	"""Animation du bonus (rotation et lévitation)."""
	rotate_y(delta * 2.0)
	
	# Lévitation
	var time = Time.get_ticks_msec() / 1000.0
	position.y = 0.5 + sin(time * 3.0) * 0.2


func _on_body_entered(body: Node3D) -> void:
	"""Appelé quand un corps entre en collision avec le bonus."""
	# Vérifier si c'est le joueur
	if body.is_in_group("joueur"):
		collect(body)


func collect(player: Node3D) -> void:
	"""Collecte le bonus et applique son effet."""
	print("Bonus collecté de type: ", bonus_type)
	
	# Récupérer le script de contrôle du joueur (attaché au CharacterBody3D)
	var control_script = player.get_node("control_joueur")
	if control_script == null:
		print("Erreur: Script de contrôle du joueur non trouvé!")
		queue_free()
		return
	
	# Appliquer l'effet du bonus
	match bonus_type:
		BonusType.BOMB_COUNT:
			control_script.increase_max_bombs()
		BonusType.EXPLOSION_RANGE:
			control_script.increase_explosion_range()
	
	# Effet visuel de collecte
	create_collect_effect()
	
	# Supprimer le bonus
	queue_free()


func create_collect_effect() -> void:
	"""Crée un effet visuel de collecte."""
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3.ZERO, 0.2)
