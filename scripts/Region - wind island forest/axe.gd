extends Node2D

@export var speed: float = 250.0
@export var rotation_speed_min: float = 4.0
@export var rotation_speed_max: float = 20.0
@export var lifetime: float = 5.0

var velocity: Vector2
var launch_direction: Vector2
var rotation_direction := 1

func _ready():
	await get_tree().process_frame  # 🔥 Fixes transform sync

	var target = get_parent().get_parent().get_node("Vami")
	if target:
		launch_direction = (target.global_position - global_position).normalized()
		velocity = launch_direction * speed
		rotation_direction = sign(randf() - 0.5)
		rotation = launch_direction.angle()

	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _process(delta):
	position += velocity * delta

	var angle = velocity.angle()
	var axis_up = abs(sin(angle))
	var rot_speed = lerp(rotation_speed_min, rotation_speed_max, axis_up)
	rotation += rot_speed * rotation_direction * delta
