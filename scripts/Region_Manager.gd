extends Node
class_name RegionManager

var current_room: Node = null
@export var starting_room: PackedScene
@onready var game_root = get_tree().current_scene
@onready var vami = get_node("/root/GameManager/Vami") # adjust as needed

func _ready():
	load_room(starting_room, Vector2.ZERO)

func load_room(scene: PackedScene, spawn_pos: Vector2):
	if current_room:
		current_room.queue_free()

	current_room = scene.instantiate()
	game_root.add_child(current_room)

	vami.global_position = spawn_pos
