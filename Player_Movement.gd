extends CharacterBody2D

# Movement Variables 
@export var MOVE_SPEED = 300.0
@export var JUMP_VELOCITY = -400.0

# Camera Variables 
@export var CAMERA_ZOOM: Vector2 = Vector2(3, 3)
@export var CAMERA_SMOOTH_SPEED: float = 8.0

#Health
@export var HP: int = 10


@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var cam: Camera2D = $Camera2D

var frozen: bool = false

func _ready() -> void:
	# camera follow and zoom for character
	cam.enabled = true
	cam.zoom = CAMERA_ZOOM
	cam.position_smoothing_enabled = true
	cam.position_smoothing_speed = CAMERA_SMOOTH_SPEED
	
	


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Horizontal movement
	var dir := Input.get_axis("move_left", "move_right")
	velocity.x = dir * MOVE_SPEED
	
	move_and_slide()
	
	_update_anim(dir)
	
	if frozen:
		velocity = Vector2.ZERO
		MOVE_SPEED = 0
		JUMP_VELOCITY = 0
		move_and_slide()
		anim.play("idle")
		return
	
func _update_anim(dir: float) -> void:
	if anim == null:
		return 
	
	var frames := anim.sprite_frames
	if frames == null:
		return 
		
	#flip sprite to correspond to movement direction
	if dir != 0.0: 
		anim.flip_h = dir < 0.0
		
	# animation state (chooses correct animation)
	var target := "idle"
	
	if not is_on_floor():
		if frames.has_animation("jump"):
			target = "jump"
		else:
			target = "walk"
	elif abs(dir) > 0.01:
		target = "walk"
		
	# PLay if available
	if frames.has_animation(target) and anim.animation != target:
		anim.play(target)
		
		
func freeze() -> void:
	frozen = true
	velocity = Vector2.ZERO

func take_damage(amount: int) -> void:
	HP -= amount
	print("Player HP:", HP)
