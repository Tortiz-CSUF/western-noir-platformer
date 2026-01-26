extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var cam: Camera2D = $Camera2D


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
	#flip sprite to correspond to movement direction
	if dir != 0.0: 
		anim.flip_h = dir < 0.0
		
	# animation state
	if not is_on_floor():
		if anim.sprite_frames.has.animation("jump"):
			_play_if_needed("jump")
			else:
				_play_if_needed("walk")
		else:
			
			
			
			
func _play_if_needed(name: String) -> void:
	if anim.animation != name:
		anim.play(name)			
	
