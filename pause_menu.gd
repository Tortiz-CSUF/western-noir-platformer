extends CanvasLayer

@export var main_menu_scene: PackedScene

@onready var root: Control = $Root
@onready var resume_button: Button = $Root/Panel/VBox/ResumeButton
@onready var restart_button: Button = $Root/Panel/VBox/RestartButton
@onready var main_menu_button: Button = $Root/Panel/VBox/MainMenuButton
@onready var quit_button: Button = $Root/Panel/VBox/QuitButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	root.visible = false
	
	resume_button.pressed.connect(_on_resume_button_pressed)
	restart_button.pressed.connect(_on_restart_button_pressed)
	main_menu_button.pressed.connect(_on_main_menu_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()
		get_viewport().set_input_as_handled()
	
func toggle_pause() -> void:
	var now_paused := not get_tree().paused
	get_tree().paused = now_paused
	root.visible = false

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
