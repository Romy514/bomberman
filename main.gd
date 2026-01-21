extends Node3D

signal victory_signal
signal defeat_signal

@onready var player_control: Node = $Personnage/control_joueur
@onready var game_over_ui: CanvasLayer = $GameOverUI

var enemies_alive: int = 0
var game_state: String = "playing"  # playing, victory, defeat

func _ready() -> void:
	# Placer le joueur à la position (0, 0, 0)
	var player = get_node_or_null("Personnage")
	if player:
		player.global_position = Vector3(0, 0, 0)
	
	if player_control and player_control.has_signal("game_over_signal"):
		player_control.connect("game_over_signal", Callable(self, "_on_game_over"))
	
	# Compter les ennemis initiaux
	enemies_alive = get_tree().get_nodes_in_group("enemy").size()
	print("Ennemis à éliminer: ", enemies_alive)


func _process(delta: float) -> void:
	# Vérifier la condition de victoire (US20)
	if game_state == "playing":
		check_victory_condition()


func check_victory_condition() -> void:
	"""Vérifie si tous les ennemis sont éliminés (US20)."""
	var current_enemies = get_tree().get_nodes_in_group("enemy").size()
	
	if current_enemies == 0 and enemies_alive > 0:
		victory()


func victory() -> void:
	"""Le joueur gagne le niveau (US21)."""
	game_state = "victory"
	get_tree().paused = true
	print("Victoire!")
	if game_over_ui:
		game_over_ui.show_victory()
	emit_signal("victory_signal")


func _on_game_over() -> void:
	"""Le joueur perd (US21)."""
	game_state = "defeat"
	if game_over_ui:
		game_over_ui.show_defeat()
	emit_signal("defeat_signal")
