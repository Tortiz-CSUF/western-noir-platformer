extends Control

@export var player_path: NodePath

@onready var bar_clip: Control = $BarClip
@onready var fill: ColorRect = $BarClip/Fill

var _full_w: float
var _full_h: float

func _ready() -> void:
	_full_w = bar_clip.size.x
	_full_h = bar_clip.size.y
	
	#Must start full at scene load
	fill.position = Vector2(0, 0)
	fill.size = Vector2(_full_w, _full_h)
	
	var player:= get_node_or_null(player_path)
	if player == null:
		push_warning("HealthWidget: player_path not set or player not found!")
		return
	
	
func _on_hp_changed() -> void:
	
