extends CanvasLayer
"""
[pause_menu.gd]

Purpose:
- Manages pausing/unpausing the game and showing a pause menu UI.
- Prevents pausing while on the main menu scene.

Scene wiring expectations:
- Node tree must include:
  - Control root at $Root
- Buttons are expected to be connected to:
  - _on_resume_button_pressed()
  - _on_restart_button_pressed()
  - _on_main_menu_button_pressed()
  - _on_quit_button_pressed()

"""

@export var main_menu_scene: PackedScene
@onready var root: Control = $Root


func _ready() -> void:
	# Pause menu needs to keep processing even when paused,
	# so we can read input and unpause.
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Menu hidden by default.
	root.visible = false
	print("[Pause Menu]: ready. root path =", root.get_path())


func _input(event: InputEvent) -> void:
	# Toggle pause on the "pause" action (Tab or ESC).
	if event.is_action_pressed("pause"):
		var current := get_tree().current_scene

		# Not allowed in main menu.
		if current != null and main_menu_scene != null:
			if current.scene_file_path == main_menu_scene.resource_path:
				return

		toggle_pause()
		get_viewport().set_input_as_handled()


func toggle_pause() -> void:
	# Single source of truth: SceneTree paused state controls gameplay pause.
	var now_paused := not get_tree().paused
	get_tree().paused = now_paused
	root.visible = now_paused


func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	root.visible = false


func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
	close_pause_menu()


func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false

	if main_menu_scene:
		get_tree().change_scene_to_packed(main_menu_scene)
	else:
		push_warning(" PauseMenu: main_menu not set.")

	close_pause_menu()


func _on_quit_button_pressed() -> void:
	get_tree().quit()


### helper function
func close_pause_menu() -> void:
	# Always ensure menu is hidden and game is not paused.
	get_tree().paused = false
	root.visible = false
