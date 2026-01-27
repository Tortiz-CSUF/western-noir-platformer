extends Area2D

@export_multiline var CLEARANCE_MESSAGE : String = "Level Complete!"
@export var UI_PATH: NodePath
@export var PLAYER_PATH: NodePath

var triggered := false
var player: Node

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
	player = get_node_or_null(PLAYER_PATH)
	if player == null:
		push_warning('MoonGoal: PLAYER_PATH not set or invalid...')

func _on_body_entered(body: Node) -> void:
	if triggered:
		return 
	if body != player:
		return
		
	triggered = true
	
	# Stop player movement to dislay UI
	if player.has_method("freeze"):
		player.freeze()
	
	# Display Clearance UI
	var ui := get_node_or_null(UI_PATH)
	if ui != null and ui.has_method("show_message"):
		ui.show_message(CLEARANCE_MESSAGE)
