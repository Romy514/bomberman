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
	#get_tree().paused = true
	title_label.text = "VICTOIRE!"
	title_label.add_theme_color_override("font_color", Color.GREEN)
	info_label.text = "Tous les ennemis sont éliminés!"
	restart_button.text = "Recommencer"
	quit_button.text = "Quitter"

func show_multiplayer_victory(player1_alive: bool, player2_alive: bool) -> void:
	"""Affiche l'écran de victoire en mode multijoueur (US24)."""
	visible = true
	#get_tree().paused = true
	title_label.text = "VICTOIRE!"
	title_label.add_theme_color_override("font_color", Color.GREEN)
	
	# Déterminer qui a survécu
	if player1_alive and player2_alive:
		info_label.text = "Les deux joueurs ont gagné!\nTous les ennemis sont éliminés!"
	elif player1_alive:
		info_label.text = "Joueur 1 a gagné!\nJoueur 2 a été éliminé."
	elif player2_alive:
		info_label.text = "Joueur 2 a gagné!\nJoueur 1 a été éliminé."
	else:
		# Ce cas ne devrait pas arriver dans la victoire
		info_label.text = "Victoire! Tous les ennemis sont éliminés!"
	
	restart_button.text = "Recommencer"
	quit_button.text = "Quitter"

func show_defeat() -> void:
	"""Affiche l'écran de défaite (US21)."""
	visible = true
	#get_tree().paused = true
	title_label.text = "GAME OVER"
	title_label.add_theme_color_override("font_color", Color.RED)
	info_label.text = "Tu as perdu toutes tes vies."
	restart_button.text = "Recommencer"
	quit_button.text = "Quitter"

func show_multiplayer_defeat(player1_alive: bool, player2_alive: bool) -> void:
	"""Affiche l'écran de défaite en mode multijoueur (US24)."""
	visible = true
	#get_tree().paused = true
	title_label.text = "GAME OVER"
	title_label.add_theme_color_override("font_color", Color.RED)
	
	# Déterminer ce qui s'est passé
	if not player1_alive and not player2_alive:
		info_label.text = "Les deux joueurs ont été éliminés!\nDéfaite totale."
	elif not player1_alive:
		info_label.text = "Joueur 1 a été éliminé!\nJoueur 2 continue seul."
	elif not player2_alive:
		info_label.text = "Joueur 2 a été éliminé!\nJoueur 1 continue seul."
	else:
		info_label.text = "Défaite!"
	
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
	get_tree().reload_current_scene()

func _on_quit_pressed() -> void:
	get_tree().quit()
