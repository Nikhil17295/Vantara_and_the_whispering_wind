# EnemyHurtbox.gd
extends Area2D
class_name EnemyHurtbox

@export var max_health := 5
var health := max_health

func _ready():
	# Hurtboxes live on layer 9 (index 8)
	collision_layer = 1 << 8
	monitoring = true
	connect("area_entered", Callable(self, "_on_area_entered"))

func take_damage(amount: int):
	health -= amount
	print("Enemy hurtbox took", amount, "damage. Remaining:", health)
	if health <= 0:
		_on_death()

func _on_death():
	print("Enemy killed")
	var enemy = get_parent()
	if enemy:
		enemy.queue_free()
