extends Node

# Script pour gérer l'apparence visuelle du joueur
# US25 - Rendre le joueur 2 visuellement reconnaissable

@onready var player: CharacterBody3D = get_parent()
@export var player_id: int = 1  # 1 ou 2

func _ready() -> void:
	apply_player_appearance()


func apply_player_appearance() -> void:
	"""Applique une apparence différente selon le numéro du joueur."""
	# Trouver TOUS les MeshInstance3D (body, backpack, etc.)
	var mesh_instances = find_all_mesh_instances(player)
	
	if mesh_instances.is_empty():
		print("Aucun MeshInstance3D trouvé pour le joueur ", player_id)
		return
	
	# Créer un matériau unique pour chaque joueur
	var material = StandardMaterial3D.new()
	
	if player_id == 1:
		# Joueur 1 : Violet vif
		material.albedo_color = Color(0.8, 0.2, 1.0)  # Violet vif
		material.emission_enabled = true
		material.emission = Color(0.4, 0.1, 0.5)  # Lueur violette
		material.emission_energy = 0.3
		print("Joueur 1 configuré avec la couleur violette")
	else:
		# Joueur 2 : Rose vif
		material.albedo_color = Color(1.0, 0.4, 0.8)  # Rose vif
		material.emission_enabled = true
		material.emission = Color(0.5, 0.2, 0.4)  # Lueur rose
		material.emission_energy = 0.3
		print("Joueur 2 configuré avec la couleur rose")
	
	# Appliquer le matériau sur TOUS les meshes (body, backpack, etc.)
	for mesh_instance in mesh_instances:
		if mesh_instance.mesh:
			for i in range(mesh_instance.mesh.get_surface_count()):
				mesh_instance.set_surface_override_material(i, material)
		mesh_instance.material_override = material


func find_all_mesh_instances(node: Node) -> Array:
	"""Recherche récursivement TOUS les MeshInstance3D dans l'arbre de nœuds."""
	var meshes: Array = []
	
	if node is MeshInstance3D:
		meshes.append(node)
	
	for child in node.get_children():
		meshes.append_array(find_all_mesh_instances(child))
	
	return meshes


func find_mesh_instance(node: Node) -> MeshInstance3D:
	"""Recherche récursivement un MeshInstance3D dans l'arbre de nœuds."""
	if node is MeshInstance3D:
		return node
	
	for child in node.get_children():
		var result = find_mesh_instance(child)
		if result != null:
			return result
	
	return null
