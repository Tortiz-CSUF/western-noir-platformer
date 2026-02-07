extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_game_pressed() -> void:
	print("Start Game Pressed...")
	get_tree().change_scene_to_file("res://Sample_Scene.tscn")


func _on_exit_game_pressed() -> void:
	print("Exit Pressed...")
	get_tree().quit()
