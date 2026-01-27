extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0


@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var cam: Camera2D = $Camera2D

func _ready() -> void:
	# camera follow and zoom for character
	cam.enabled = true
	cam.zoom = Vector2(3,3)
	cam.position_smoothing_enabled = true
	cam.position_smoothing_speed = 8.0
	
	


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Horizontal movement
	var dir := Input.get_axis("move_left", "move_right")
	velocity.x = dir * SPEED
	
	move_and_slide()
	
	_update_anim(dir)
	
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
		if frames.has_connections("jump"):
			target = "jump"
		else:
			target = "walk"
	elif abs(dir) > 0.01:
		target = "walk"
		
	# PLay if available
	if frames.has_animation(target) and anim.animation != target:
		anim.play(target)
		
