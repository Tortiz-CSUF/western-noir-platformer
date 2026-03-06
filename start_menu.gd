extends Control
"""
[start_menu.gd]

Purpose:
- Handles Start Menu button callbacks.

Scene wiring expectations:
- This script is attached to a Control-based Start Menu scene.
- Buttons in the UI should be connected to:
  - _on_start_game_pressed()
  - _on_exit_game_pressed()

Important constraints:
- DO NOT rename these functions since
  they are connected via the editor signals.
"""


func _ready() -> void:
	# Intentionally empty. 
	pass


func _process(delta: float) -> void:
	# Intentionally empty. 
	pass


func _on_start_game_pressed() -> void:
	# Button signal callback: Start the game by loading the gameplay scene.
	print("Start Game Pressed...")
	get_tree().change_scene_to_file("res://Sample_Scene.tscn")


func _on_exit_game_pressed() -> void:
	# Button signal callback: Quit the application.
	print("Exit Pressed...")
	get_tree().quit()
