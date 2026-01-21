extends CanvasLayer

@onready var panel: Control = $Panel
@onready var title_label: Label = $Panel/VBox/Title
@onready var info_label: Label = $Panel/VBox/Info
@onready var restart_button: Button = $Panel/VBox/Buttons/RestartButton
@onready var quit_button: Button = $Panel/VBox/Buttons/QuitButton

func show_game_over() -> void:
	visible = true
	get_tree().paused = true

func hide_ui() -> void:
	visible = false
	get_tree().paused = false

func _ready() -> void:
	visible = false
	# Texte par défaut
	title_label.text = "GAME OVER"
	restart_button.pressed.connect(_on_restart_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()

func _on_quit_pressed() -> void:
	get_tree().quit()
