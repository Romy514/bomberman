extends CanvasLayer

@onready var panel: Control = $Panel
@onready var title_label: Label = $Panel/VBox/Title
@onready var info_label: Label = $Panel/VBox/Info
@onready var restart_button: Button = $Panel/VBox/Buttons/RestartButton
@onready var quit_button: Button = $Panel/VBox/Buttons/QuitButton

func show_game_over() -> void:
	"""Affiche l'écran de défaite."""
	show_defeat()

func show_victory() -> void:
	"""Affiche l'écran de victoire (US21)."""
	visible = true
	get_tree().paused = true
	title_label.text = "VICTOIRE!"
	title_label.add_theme_color_override("font_color", Color.GREEN)
	info_label.text = "Tous les ennemis sont éliminés!"
	restart_button.text = "Recommencer"
	quit_button.text = "Quitter"

func show_defeat() -> void:
	"""Affiche l'écran de défaite (US21)."""
	visible = true
	get_tree().paused = true
	title_label.text = "GAME OVER"
	title_label.add_theme_color_override("font_color", Color.RED)
	info_label.text = "Tu as perdu toutes tes vies."
	restart_button.text = "Recommencer"
	quit_button.text = "Quitter"

func hide_ui() -> void:
	visible = false
	get_tree().paused = false

func _ready() -> void:
	visible = false
	restart_button.pressed.connect(_on_restart_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_pressed() -> void:
	get_tree().quit()
