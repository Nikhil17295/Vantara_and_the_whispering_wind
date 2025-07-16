extends Node
class_name RoomManager

@export var left_exit_scene: PackedScene
@export var right_exit_scene: PackedScene
@export var left_spawn_position: Vector2
@export var right_spawn_position: Vector2

@export var camera_limit_left: int
@export var camera_limit_right: int
@export var camera_limit_top: int
@export var camera_limit_bottom: int

func _ready():
	var vami = get_parent().get_node("Vami")
	var cam = vami.get_node("Camera2D")
	cam.set_camera_limits(
		camera_limit_left,
		camera_limit_right,
		camera_limit_top,
		camera_limit_bottom
		)
