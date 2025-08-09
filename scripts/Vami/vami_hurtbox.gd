extends Area2D
class_name VamiHurtbox

@export var max_hp := 10
var current_hp := max_hp
var is_invulnerable := false

func _ready():
	# Set to only Layer 10, as planned
	
	collision_layer = 1 << 9
	collision_mask = 1 << 9

func _on_area_entered(area: Area2D):
	if is_invulnerable:
		return

	if area is EnemyHitbox:
		take_damage(area.damage)

		if area.trigger_invulnerability:
			start_invulnerability()
		if area.hitflash:
			start_flash()
		if area.screenshake:
			trigger_screenshake()
		if area.knockback:
			trigger_knockback()

func take_damage(amount: int):
	current_hp -= amount
	print("Vami took ", amount, " damage. HP left:", current_hp)

	if current_hp <= 0:
		die()

func start_invulnerability():
	pass

func start_flash():
	# To be implemented with shader or modulate
	pass

func trigger_knockback():
	pass

func trigger_screenshake():
	# To be linked with camera system later
	pass

func die():
	print("Vami died.")
	call_deferred("reload_scene")
func reload_scene():
	get_tree().reload_current_scene()
	# Call your respawn/game over system
