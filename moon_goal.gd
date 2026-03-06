extends Area2D
"""
[moon_goal.gd]

Purpose:
- Level completion trigger.
- When the designated player enters:
  - prevents re-triggering
  - freezes the player (if supported)
  - tells the clearance UI to show a message (if supported)

Scene wiring expectations:
- PLAYER_PATH should point to the player node (the exact node instance).
- UI_PATH should point to a UI node that implements:
  - show_message(message: String)
- Player should implement:
  - freeze()

"""

@export_multiline var CLEARANCE_MESSAGE: String = "Level Complete!"
@export var UI_PATH: NodePath
@export var PLAYER_PATH: NodePath

var triggered := false
var player: Node


func _ready() -> void:
	# Signal connection to avoid requiring editor wiring.
	body_entered.connect(_on_body_entered)

	# Caches the intended player node from PLAYER_PATH.
	player = get_node_or_null(PLAYER_PATH)
	if player == null:
		push_warning("MoonGoal: PLAYER_PATH not set or invalid...")


func _on_body_entered(body: Node) -> void:
	# Prevent double triggers.
	if triggered:
		return

	# Only trigger when the correct player node enters.
	if body != player:
		return

	triggered = true

	# Stop player movement to display UI.
	if player.has_method("freeze"):
		player.freeze()

	# Display Clearance UI.
	var ui := get_node_or_null(UI_PATH)
	if ui != null and ui.has_method("show_message"):
		ui.show_message(CLEARANCE_MESSAGE)
