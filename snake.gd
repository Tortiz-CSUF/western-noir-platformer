extends CharacterBody2D


@export var move_speed: float = 50.0
@export var aggro_range: float = 150.0
@export var damage: int = 1
@export var damage_cooldown: float = 0.6

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurtbox: Area2D = $Hurtbox

var _player: Node2D = null
var _can_damage: bool = true

func _ready() -> void:
	# Hurtbox used to detect collision against player
	hurtbox.body_entered.connect(_on_hurt_body_entered)
	


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
