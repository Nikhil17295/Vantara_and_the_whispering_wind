extends Area2D
class_name DummyHurtbox

func _ready() -> void:
	collision_layer = 1 << 8

func take_damage(damage: int):
	var dummy = get_parent()
	if dummy and dummy.has_method("take_damage"):
		dummy.take_damage(damage)
