extends Area2D

@onready var sprite := $"../AnimatedSprite2D"

@onready var shape_1 := $1
@onready var shape_2 := $2
@onready var shape_3 := $3
@onready var shape_4 := $4

@export var run_frames: Array[Array[int]] = []
@export var idle_frames: Array[Array[int]] = []
@export var jump_frames: Array[Array[int]] = []

func _process(_delta):
	var anim := sprite.animation
	var frame := sprite.frame
	var enabled_shapes: Array[int] = []

	match anim:
		"run":
			if frame < run_frames.size():
				enabled_shapes = run_frames[frame]
		"idle":
			if frame < idle_frames.size():
				enabled_shapes = idle_frames[frame]
		"jump":
			if frame < jump_frames.size():
				enabled_shapes = jump_frames[frame]
		_:  # fallback
			enabled_shapes = []

	shape_1.disabled = not enabled_shapes.has(1)
	shape_2.disabled = not enabled_shapes.has(2)
	shape_3.disabled = not enabled_shapes.has(3)
	shape_4.disabled = not enabled_shapes.has(4)
