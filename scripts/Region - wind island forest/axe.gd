extends Node2D

@export var speed: float = 300.0
@export var rotation_speed_min: float = 2.0
@export var rotation_speed_max: float = 10.0
@export var lifetime: float = 5.0

var velocity: Vector2
var rotation_direction := 1

@onready var sprite := $Sprite2D

func _ready():
	# Rotate towards target (Vami)
	var target = get_tree().get_first_node_in_group("Vami")  # You should add Vami to group "vami"
	if target:
		look_at(target.global_position)
		velocity = (target.global_position - global_position).normalized() * speed
		rotation_direction = sign(randf() - 0.5)  # Random CW or CCW
	# Auto-remove after time
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _process(delta):
	position += velocity * delta

	# Rotate based on angle of flight
	var angle = velocity.angle()
	var axis_up = abs(sin(angle))
	var rot_speed = lerp(rotation_speed_min, rotation_speed_max, axis_up)
	rotation += rot_speed * rotation_direction * delta
