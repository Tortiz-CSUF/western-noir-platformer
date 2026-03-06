extends CharacterBody2D
"""
[snake.gd]

Purpose:
- Basic enemy AI that chases a player within aggro_range.
- Deals contact damage via a Hurtbox Area2D with a cooldown.

Scene wiring expectations:
- Node tree must include:
  - AnimatedSprite2D at $AnimatedSprite2D
  - Area2D (hurtbox) at $Hurtbox
- Player must be in group: "player"
- Player should implement: take_damage(amount: int, source_pos: Vector2)

Important constraints:
- Variable names, exported names, and methods must be kept the same to avoid 
  breaking existing hooks.
"""

# --- Tunables ---
@export var move_speed: float = 50.0
@export var aggro_range: float = 150.0
@export var damage: int = 1
@export var damage_cooldown: float = 0.6
@export var gravity: float = 900.0

# --- Cached nodes ---
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurtbox: Area2D = $Hurtbox

# --- Internal state ---
var _player: Node2D = null
var _can_damage: bool = true


func _ready() -> void:
	# Hurtbox is used to detect collision against player.
	# We keep this connection in code to make wiring explicit
	hurtbox.body_entered.connect(_on_hurt_body_entered)

	# Flip sprite to intended direction (default facing).
	anim.flip_h = false


func _physics_process(delta: float) -> void:
	# Refresh player reference each physics frame.
	_player = _find_player()

	# If on damage cooldown: stop horizontal movement and idle.
	if not _can_damage:
		_play_idle()
		velocity.x = 0.0

		# Gravity handling while "paused" in cooldown.
		if not is_on_floor():
			velocity.y += gravity * delta
		else:
			velocity.y = 0.0

		move_and_slide()
		return

	# Decide movement based on player distance.
	var desired_vel_x: float = 0.0
	var dir_x: float = 0.0

	if _player != null:
		var dist: float = global_position.distance_to(_player.global_position)
		if dist <= aggro_range:
			dir_x = sign(_player.global_position.x - global_position.x)
			desired_vel_x = dir_x * move_speed
			_play_walk(dir_x)
		else:
			_play_idle()
	else:
		_play_idle()

	velocity.x = desired_vel_x

	# Gravity logic (manual, using CharacterBody2D velocity).
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0.0

	move_and_slide()


# --- Animation helpers ---
func _play_idle() -> void:
	if anim.animation != "idle":
		anim.play("idle")


func _play_walk(dir_x: float) -> void:
	if anim.animation != "walk":
		anim.play("walk")

	# Flip sprite based on movement direction.
	if dir_x != 0.0:
		anim.flip_h = (dir_x > 0.0)


# --- Player lookup ---
func _find_player() -> Node2D:
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0] as Node2D
	return null


# --- Hurtbox callbacks / damage application ---
func _on_hurt_body_entered(body: Node) -> void:
	# Debug print kept as-is; collaborators can remove once stable.
	print("HURTBOX ENTER:", body, name, " groups:", body.get_groups())

	if not _can_damage:
		return

	if body.is_in_group("player"):
		_try_damage_player(body)


func _try_damage_player(player: Node) -> void:
	# Calls into player.take_damage(amount, source_pos) if available.
	if player.has_method("take_damage"):
		player.call("take_damage", damage, global_position)

	# Damage cooldown (prevents rapid re-damage on contact).
	_can_damage = false
	var t := get_tree().create_timer(damage_cooldown)
	await t.timeout
	_can_damage = true
