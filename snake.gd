extends CharacterBody2D


@export var move_speed: float = 50.0
@export var aggro_range: float = 150.0
@export var damage: int = 1
@export var damage_cooldown: float = 0.6
@export var gravity: float = 900.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurtbox: Area2D = $Hurtbox

var _player: Node2D = null
var _can_damage: bool = true

func _ready() -> void:
	# Hurtbox used to detect collision against player
	hurtbox.body_entered.connect(_on_hurt_body_entered)
	
	#flip sprite to intended direction 
	anim.flip_h = false
	
func _physics_process(delta: float) -> void:
	_player = _find_player()
	
	var desired_vel_x := 0.0
	var dir_x := 0.0
	
	if _player != null:
		var dist := global_position.distance_to(_player.global_position)
		if dist <= aggro_range:
			dir_x = sign(_player.global_position.x - global_position.x)
			desired_vel_x = dir_x * move_speed
			_play_walk(dir_x)
		else: 
			_play_idle()
	else: 
		_play_idle()
	
	velocity.x = desired_vel_x
	
	#gravity logic
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0.0
		
	move_and_slide()
	
func _play_idle() -> void:
	if anim.animation != "idle":
		anim.play("idle")
	
func _play_walk(dir_x: float) -> void:
	if anim.animation != "walk":
		anim.play("walk")
	#flip sprite	
	if dir_x != 0.0:
		anim.flip_h = (dir_x > 0.0)

func _find_player() -> Node2D:
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0] as Node2D
	return null
	
	
func _on_hurt_body_entered(body: Node) -> void:
	if not _can_damage:
		return 
	if body.is_in_group("player"):
		_try_damage_player(body)
	
func _try_damage_player(player: Node) -> void:
	#need to create a "take damage" funciton in player movement
	if player.has_method("take_damage"):
		player.call("take_damage", damage)
	
	#cooldown	
	_can_damage = false
	var t := get_tree().create_timer(damage_cooldown)
	await t.timeout
	_can_damage = true
