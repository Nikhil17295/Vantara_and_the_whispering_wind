extends Area2D
class_name EnemyHitbox

@export var damage: int = 1
@export var knockback: Vector2 = Vector2.ZERO
@export var trigger_invulnerability: bool = true
@export var screenshake: bool = true
@export var hitflash: bool = true

func _ready() -> void:
	collision_layer= 1 << 9
	collision_mask = 1 << 9
