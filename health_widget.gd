extends Control
"""
[health_widget.gd]

Purpose:
- Displays the player's HP via a clipped fill bar + text label.
- Automatically locates the player via the "player" group and connects to:
  - player.hp_changed(current_hp, max_hp)

Scene wiring expectations:
- Node tree must include:
  - Control at $BarClip
  - ColorRect at $BarClip/Fill
  - Label at $HPtext
- Player must:
  - be in group "player"
  - define signal: hp_changed(current_hp: int, max_hp: int)
  - expose vars: HP, MAX_HP


"""

@onready var bar_clip: Control = $BarClip
@onready var fill: ColorRect = $BarClip/Fill
@onready var hp_text: Label = $HPtext

var _full_w: float
var _full_h: float


func _ready() -> void:
	# Caches "full" dimensions once at scene load.
	_full_w = bar_clip.size.x
	_full_h = bar_clip.size.y

	# Must start full at scene load (visual reset).
	fill.position = Vector2(0, 0)
	fill.size = Vector2(_full_w, _full_h)

	# Find the player by group.
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		push_warning("HealthWidget: player_path not set or player not found!")
		return

	# Validate expected signal.
	if not player.has_signal("hp_changed"):
		push_warning("HealthWidget: Player is missing hp_changed signal!")
		return

	# Connect and immediately sync UI to the current HP.
	player.hp_changed.connect(_on_hp_changed)
	_on_hp_changed(player.HP, player.MAX_HP)


func _on_hp_changed(current_hp: int, max_hp: int) -> void:
	# Convert HP into a 0:1 ratio.
	var ratio := 0.0
	if max_hp > 0:
		ratio = float(current_hp) / float(max_hp)

	ratio = clamp(ratio, 0.0, 1.0)

	# Compute new height based on ratio (anchored bottom).
	var new_h := _full_h * ratio

	# Bottom remains constant.
	fill.position.y = _full_h - new_h

	fill.size = Vector2(_full_w, _full_h)

	# Update text label.
	hp_text.text = str("HP: ") + str(current_hp) + "/" + str(max_hp)
