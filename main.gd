extends Node3D

@onready var player_control: Node = $Personnage/control_joueur
@onready var game_over_ui: CanvasLayer = $GameOverUI

func _ready() -> void:
	if player_control and player_control.has_signal("game_over_signal"):
		player_control.connect("game_over_signal", Callable(self, "_on_game_over"))

func _on_game_over() -> void:
	if game_over_ui:
		game_over_ui.show_game_over()
