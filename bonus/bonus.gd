extends Area3D

class_name Bonus

enum BonusType {
	BOMB_COUNT,      # US17 - Augmente le nombre de bombes
	EXPLOSION_RANGE  # US18 - Augmente la portée des explosions
}

@export var bonus_type: BonusType = BonusType.BOMB_COUNT
@onready var model: Node3D = $Star  
var mesh: MeshInstance3D = null

func _ready() -> void:
	# Ajouter au groupe "bonus"
	add_to_group("bonus")
	
	# Connecter le signal de collision
	body_entered.connect(_on_body_entered)
	
	# Chercher le MeshInstance3D dans le modèle importé
	mesh = _find_mesh(model)
	if mesh == null:
		print("Erreur Aucun MeshInstance3D trouvé dans le modèle !")
	else:
		update_bonus_appearance()
	
	print("Bonus créé de type: ", bonus_type)

func _find_mesh(node: Node) -> MeshInstance3D:
	"""Cherche récursivement un MeshInstance3D dans le node ou ses enfants."""
	if node is MeshInstance3D:
		return node
	for child in node.get_children():
		var m = _find_mesh(child)
		if m != null:
			return m
	return null

func update_bonus_appearance() -> void:
	"""Change l'apparence du bonus selon son type."""
	if mesh == null:
		return
	
	var material = StandardMaterial3D.new()
	
	match bonus_type:
		BonusType.BOMB_COUNT:
			material.albedo_color = Color(0.2, 0.5, 1.0)  # Bleu
		BonusType.EXPLOSION_RANGE:
			material.albedo_color = Color(1.0, 0.6, 0.2)  # Orange
	
	material.emission_enabled = true
	material.emission = material.albedo_color
	material.emission_energy = 0.5
	
	# Appliquer le matériau sur toutes les surfaces
	for i in mesh.mesh.get_surface_count():
		mesh.set_surface_override_material(i, material)

func _process(delta: float) -> void:
	"""Animation du bonus : rotation et lévitation."""
	if model != null:
		model.rotate_y(delta * 2.0)
	
	# Lévitation
	var time = Time.get_ticks_msec() / 1000.0
	position.y = 0.5 + sin(time * 3.0) * 0.2

func _on_body_entered(body: Node3D) -> void:
	"""Appelé quand un corps entre en collision avec le bonus."""
	if body.is_in_group("joueur"):
		collect(body)

func collect(player: Node3D) -> void:
	"""Collecte le bonus et applique son effet."""
	print("Bonus collecté de type: ", bonus_type)
	
	# Récupérer le script de contrôle du joueur
	var control_script = player.get_node_or_null("control_joueur")
	if control_script == null:
		print("Erreur: Script de contrôle du joueur non trouvé!")
		queue_free()
		return
	
	# Appliquer l'effet
	match bonus_type:
		BonusType.BOMB_COUNT:
			control_script.increase_max_bombs()
		BonusType.EXPLOSION_RANGE:
			control_script.increase_explosion_range()
	
	# Effet visuel de collecte
	create_collect_effect()

func create_collect_effect() -> void:
	"""Crée un effet visuel de collecte (scale vers 0)."""
	var tween = create_tween()
	tween.tween_property(model, "scale", Vector3.ZERO, 0.2)
	tween.finished.connect(queue_free)
