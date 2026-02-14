extends CanvasLayer

@export var main_menu_scene: PackedScene

@onready var root: Control = $Root

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	root.visible = false
	print("[Pause Menu]: ready. root path =", root.get_path())
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()
		get_viewport().set_input_as_handled()
	
func toggle_pause() -> void:
	var now_paused := not get_tree().paused
	get_tree().paused = now_paused
	root.visible = now_paused

func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	root.visible = false

func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	if main_menu_scene:
		get_tree().change_scene_to_packed(main_menu_scene)
	else:
		push_warning(" PauseMenu: main_menu not set.")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
