extends Area2D
class_name VamiHitbox

@export var active_time := 0.5
@export var damage := 1
@onready var hitbox_1: CollisionShape2D = $hitbox_1

var _active := false

func _ready():
	# Only check collisions on the 9th layer
	collision_mask = 1 << 8  # Layer 9 is index 8 (0-based)
	monitoring = false
	connect("area_entered", Callable(self, "_on_area_entered"))

func _process(_delta):
	if Input.is_action_just_pressed("attack") and not _active:
		_activate()

func _activate():
	_active = true
	monitoring = true
	hitbox_1.disabled = false
	await get_tree().create_timer(active_time).timeout
	monitoring = false
	hitbox_1.disabled = true
	_active = false

func _on_area_entered(area: Area2D):
	if _active and area.has_method("take_damage"):
		area.take_damage(damage)
