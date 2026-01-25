extends Node3D

signal victory_signal
signal defeat_signal

@onready var player_control: Node = $Personnage/control_joueur
@onready var game_over_ui: CanvasLayer = $GameOverUI

# Variables pour le multijoueur (US23, US24, US25)
@export var player2_scene: PackedScene  # Scène du joueur 2
var player2_instance = null
var player2_control = null
var player2_joined: bool = false

var enemies_alive: int = 0
var game_state: String = "playing"  # playing, victory, defeat

# Victimes pour gérer qui a gagné/perdu (US24)
var player1_alive: bool = true
var player2_alive: bool = true

func _ready() -> void:
	# Placer le joueur à la position (0, 0, 0)
	var player = get_node_or_null("Personnage")
	if player:
		player.global_position = Vector3(0, 0, 0)
		
		# Appliquer l'apparence visuelle au joueur 1 (violet)
		var visual_script = load("res://personnage/player_visual.gd")
		if visual_script:
			var visual_node = Node.new()
			visual_node.set_script(visual_script)
			visual_node.set("player_id", 1)
			player.add_child(visual_node)
	
	if player_control and player_control.has_signal("game_over_signal"):
		player_control.connect("game_over_signal", Callable(self, "_on_player1_game_over"))
	
	# Charger la scène du joueur 2
	if player2_scene == null:
		player2_scene = load("res://personnage/personnage.tscn")
	
	# Compter les ennemis initiaux
	enemies_alive = get_tree().get_nodes_in_group("enemy").size()
	print("Ennemis à éliminer: ", enemies_alive)
	print("Appuyez sur ENTRÉE pour que le joueur 2 rejoigne la partie!")


func _process(delta: float) -> void:
	# Permettre au joueur 2 de rejoindre (US23)
	if not player2_joined and Input.is_action_just_pressed("p2_join"):
		spawn_player2()
	
	# Vérifier la condition de victoire (US20)
	if game_state == "playing":
		check_victory_condition()


func check_victory_condition() -> void:
	"""Vérifie si tous les ennemis sont éliminés (US20, US24)."""
	var current_enemies = get_tree().get_nodes_in_group("enemy").size()
	
	if current_enemies == 0 and enemies_alive > 0:
		victory()
	
	# Vérifier si les deux joueurs sont morts (US24)
	if player2_joined and not player1_alive and not player2_alive:
		defeat_all_players()


func victory() -> void:
	"""Les joueurs gagnent le niveau (US21, US24)."""
	game_state = "victory"
	get_tree().paused = true
	print("Victoire!")
	if game_over_ui:
		# Déterminer qui a gagné (US24)
		if player2_joined:
			game_over_ui.show_multiplayer_victory(player1_alive, player2_alive)
		else:
			game_over_ui.show_victory()
	emit_signal("victory_signal")


func _on_player1_game_over() -> void:
	"""Le joueur 1 perd (US21, US24)."""
	player1_alive = false
	print("Joueur 1 éliminé!")
	
	# Si joueur 2 n'a pas rejoint ou est aussi mort, défaite totale
	if not player2_joined or not player2_alive:
		game_state = "defeat"
		if game_over_ui:
			if player2_joined:
				game_over_ui.show_multiplayer_defeat(player1_alive, player2_alive)
			else:
				game_over_ui.show_defeat()
		emit_signal("defeat_signal")


func _on_player2_game_over() -> void:
	"""Le joueur 2 perd (US24)."""
	player2_alive = false
	print("Joueur 2 éliminé!")
	
	# Si joueur 1 est aussi mort, défaite totale
	if not player1_alive:
		game_state = "defeat"
		if game_over_ui:
			game_over_ui.show_multiplayer_defeat(player1_alive, player2_alive)
		emit_signal("defeat_signal")


func defeat_all_players() -> void:
	"""Les deux joueurs ont perdu (US24)."""
	game_state = "defeat"
	if game_over_ui:
		game_over_ui.show_multiplayer_defeat(player1_alive, player2_alive)
	emit_signal("defeat_signal")


func spawn_player2() -> void:
	"""Fait apparaître le joueur 2 en cours de partie (US23)."""
	if player2_joined:
		print("Le joueur 2 a déjà rejoint!")
		return
	
	if player2_scene == null:
		print("Erreur: Scène du joueur 2 non chargée!")
		return
	
	# Créer le joueur 2
	player2_instance = player2_scene.instantiate()
	add_child(player2_instance)
	
	# Positionner le joueur 2 une case derrière le joueur 1 (Z+1)
	player2_instance.global_position = Vector3(0, 0, 1)
	
	# Récupérer le contrôleur du joueur 2
	player2_control = player2_instance.get_node_or_null("control_joueur")
	
	if player2_control:
		# Configurer comme joueur 2
		player2_control.player_id = 2
		player2_control.spawn_position = Vector3(0, 0, 1)
		
		# Connecter le signal game_over
		if player2_control.has_signal("game_over_signal"):
			player2_control.connect("game_over_signal", Callable(self, "_on_player2_game_over"))
		
		# Ajouter le script visuel pour différencier le joueur 2 (US25)
		var visual_script = load("res://personnage/player_visual.gd")
		if visual_script:
			var visual_node = Node.new()
			visual_node.set_script(visual_script)
			visual_node.set("player_id", 2)
			player2_instance.add_child(visual_node)
			visual_node.set_owner(player2_instance)
	
	player2_joined = true
	player2_alive = true
	print("Joueur 2 a rejoint la partie à la position: ", player2_instance.global_position)
