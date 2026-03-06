extends CharacterBody2D
"""
[Player_Movement.gd]

Purpose:
- Player movement (walk/jump) + camera follow setup
- Damage handling:
  - reduces HP
  - emits hp_changed(current_hp, max_hp)
  - applies knockback
  - flashes sprite red
  - hides HealthWidget via a relative scene path

Scene wiring expectations:
- Node tree must include:
  - AnimatedSprite2D at $AnimatedSprite2D
  - Camera2D at $Camera2D
- Player node must be in group: "player"
- Health UI is currently referenced by relative path:
  $"../HealthUI/HealthWidget"

Signals:
- hp_changed(current_hp: int, max_hp: int)


"""


# --- Movement Variables ---

@export var MOVE_SPEED: float = 300.0
@export var JUMP_VELOCITY: float = -400.0


# --- Camera Variables ---

@export var CAMERA_ZOOM: Vector2 = Vector2(3, 3)
@export var CAMERA_SMOOTH_SPEED: float = 8.0


# --- Damage Indicator (flash) ---

@export var flash_color: Color = Color(1, 0.2, 0.2, 1)
@export var flash_time: float = 0.08
var _flash_tween: Tween


# --- Player Knockback on damage taken ---

@export var knockback_force: float = 250.0
@export var knockback_up_force: float = 150.0
@export var knockback_time: float = 0.2

var _is_knockback: bool = false


# --- Cached nodes ---

@onready var visuals: CanvasItem = $AnimatedSprite2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var cam: Camera2D = $Camera2D


# --- Frozen state (Used for scene completion TEMP) ---

var frozen: bool = false


# --- Health / UI integration ---

signal hp_changed(current_hp: int, max_hp: int)
@export var MAX_HP: int = 10
@export var HP: int = 10


func _ready() -> void:
	# Camera follow and zoom for character.
	cam.enabled = true
	cam.zoom = CAMERA_ZOOM
	cam.position_smoothing_enabled = true
	cam.position_smoothing_speed = CAMERA_SMOOTH_SPEED

	print("PLAYER READY")

	# Initialize HP and inform listeners (HealthWidget listens for this).
	HP = MAX_HP
	hp_changed.emit(HP, MAX_HP)


func _physics_process(delta: float) -> void:
	# If we are currently being knocked back, do not accept new movement input.
	if _is_knockback:
		move_and_slide()
		return

	# Adds the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Horizontal movement
	var dir: float = Input.get_axis("move_left", "move_right")
	velocity.x = dir * MOVE_SPEED

	move_and_slide()

	_update_anim(dir)

	# Frozen state: stop all motion + force idle.
	if frozen:
		velocity = Vector2.ZERO
		MOVE_SPEED = 0
		JUMP_VELOCITY = 0
		move_and_slide()
		anim.play("idle")
		return


func _update_anim(dir: float) -> void:
	# Defensive checks (Prevents null errors).
	if anim == null:
		return

	var frames := anim.sprite_frames
	if frames == null:
		return

	# Flip sprite to correspond to movement direction.
	if dir != 0.0:
		anim.flip_h = dir < 0.0

	# Animation state selection.
	var target: String = "idle"

	if not is_on_floor():
		if frames.has_animation("jump"):
			target = "jump"
		else:
			target = "walk"
	elif abs(dir) > 0.01:
		target = "walk"

	# Play if available and not already playing.
	if frames.has_animation(target) and anim.animation != target:
		anim.play(target)

# Externally used by moon_goal.gd to stop player movement.
func freeze() -> void:
	frozen = true
	velocity = Vector2.ZERO

# Externally used by snake.gd (eventually other enemies).
func take_damage(amount: int, source_pos: Vector2) -> void:

	# Apply HP change.
	HP -= amount
	print("Player HP:", HP)

	# Notify UI listeners.
	hp_changed.emit(HP, MAX_HP)
	print("EMIT hp_changed:", HP, "/", MAX_HP)

	# Effects.
	_apply_knockback(source_pos)
	_flash_red()


func _apply_knockback(source_pos: Vector2) -> void:
	_is_knockback = true

	# Directional signal for knockback direction.
	var dir: int = signi(global_position.x - source_pos.x)
	if dir == 0:
		dir = 1

	velocity.x = dir * knockback_force
	velocity.y = -knockback_up_force

	await get_tree().create_timer(knockback_time).timeout
	_is_knockback = false


func _flash_red() -> void:
	# Avoid stacking multiple tweens.
	if _flash_tween and _flash_tween.is_running():
		_flash_tween.kill()

	# Flash logic: immediate red -> fade back to white.
	visuals.modulate = Color.WHITE
	_flash_tween = create_tween()
	_flash_tween.tween_property(visuals, "modulate", flash_color, 0.0)
	_flash_tween.tween_property(visuals, "modulate", Color.WHITE, flash_time)
