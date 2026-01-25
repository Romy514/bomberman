extends Node

# Script pour gérer l'apparence visuelle du joueur
# US25 - Rendre le joueur 2 visuellement reconnaissable

@onready var player: CharacterBody3D = get_parent()
@export var player_id: int = 1  # 1 ou 2

func _ready() -> void:
	apply_player_appearance()


func apply_player_appearance() -> void:
	"""Applique une apparence différente selon le numéro du joueur."""
	# Chercher le MeshInstance3D dans les enfants du joueur
	var mesh_instance = find_mesh_instance(player)
	
	if mesh_instance == null:
		print("Aucun MeshInstance3D trouvé pour le joueur ", player_id)
		return
	
	# Créer un matériau pour différencier les joueurs
	var material = StandardMaterial3D.new()
	
	if player_id == 1:
		# Joueur 1 : Bleu vif
		material.albedo_color = Color(0.0, 0.4, 1.0)  # Bleu vif
		material.emission_enabled = true
		material.emission = Color(0.0, 0.2, 0.5)  # Lueur bleue
		material.emission_energy = 0.3
		print("Joueur 1 configuré avec la couleur bleue")
	else:
		# Joueur 2 : Rouge vif
		material.albedo_color = Color(1.0, 0.2, 0.0)  # Rouge vif
		material.emission_enabled = true
		material.emission = Color(0.5, 0.1, 0.0)  # Lueur rouge
		material.emission_energy = 0.3
		print("Joueur 2 configuré avec la couleur rouge")
	
	# Appliquer le matériau
	mesh_instance.set_surface_override_material(0, material)


func find_mesh_instance(node: Node) -> MeshInstance3D:
	"""Recherche récursivement un MeshInstance3D dans l'arbre de nœuds."""
	if node is MeshInstance3D:
		return node
	
	for child in node.get_children():
		var result = find_mesh_instance(child)
		if result != null:
			return result
	
	return null
