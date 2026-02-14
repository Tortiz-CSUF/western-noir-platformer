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
	
	resume_button.pressed.connect(())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_resume_button_pressed() -> void:
	pass # Replace with function body.


func _on_restart_button_pressed() -> void:
	pass # Replace with function body.


func _on_main_menu_button_pressed() -> void:
	pass # Replace with function body.


func _on_quit_button_pressed() -> void:
	pass # Replace with function body.
