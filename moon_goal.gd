extends Area2D

@export_multiline var CLEARANCE_MESSAGE : String = "Level Complete!"
@export var UI_PATH: NodePath
@export var PLAYER_GROUP: String = "Player"

var triggered := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if triggered:
		return 
	if not body.is_in_group(PLAYER_GROUP):
		return
		
	# Stop player movement to dislay UI
	if body.has_method("freeze"):
		body.freeze()
	
	# Display Clearance UI
	var ui := get_node_or_null(UI_PATH)
	if ui != null:
		ui.show_message(CLEARANCE_MESSAGE)
