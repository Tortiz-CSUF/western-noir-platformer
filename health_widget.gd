extends Control

@onready var bar_clip: Control = $BarClip
@onready var fill: ColorRect = $BarClip/Fill
@onready var hp_text: Label = $HPtext

var _full_w: float
var _full_h: float

func _ready() -> void:
	_full_w = bar_clip.size.x
	_full_h = bar_clip.size.y
	
	#Must start full at scene load
	fill.position = Vector2(0, 0)
	fill.size = Vector2(_full_w, _full_h)
	
	var player:= get_tree().get_first_node_in_group("player")
	if player == null:
		push_warning("HealthWidget: player_path not set or player not found!")
		return
	if not player.has_signal("hp_changed"):
		push_warning("HealthWidget: Player is missing hp_changed signal!")
		return
		
	player.hp_changed.connect(_on_hp_changed)
	_on_hp_changed(player.HP, player.MAX_HP)
	
	
func _on_hp_changed(current_hp: int, max_hp: int) -> void:
	var ratio := 0.0
	
	if max_hp > 0:
		ratio = float(current_hp) / float(max_hp)
		
	ratio = clamp(ratio, 0.0, 1.0)
	
	var new_h := _full_h * ratio
	
	#bottom remains constant
	fill.position.y = _full_h - new_h
	fill.size = Vector2(_full_w, _full_h)
	
	hp_text.text = str("HP: ") + str(current_hp) + "/" + str(max_hp)
