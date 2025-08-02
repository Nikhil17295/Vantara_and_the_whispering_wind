extends EnemyHitbox

@onready var sprite := $"../AnimatedSprite2D"

@onready var shape_1 := $"1"
@onready var shape_2 := $"2"
@onready var shape_4 := $"4"
@onready var shape_5 := $"5"
@onready var shape_6 := $"6"
@onready var shape_7 := $"7"
@onready var shape_8 := $"8"

@export var run_frames = [
	[1, 4, 5],
	[1, 4, 5],
	[1, 5, 6],
	[1, 5, 8],
	[1, 5, 7],
	[1, 5, 7]
]

# Idle = single static pose, so we just define it once
var idle_shapes = [1, 2]

func _process(_delta):
	var anim = sprite.animation
	var frame = sprite.frame
	var enabled_shapes = []

	match anim:
		"run", "jump":
			if frame < run_frames.size():
				enabled_shapes = run_frames[frame]
		"idle":
			enabled_shapes = idle_shapes
		_:
			enabled_shapes = []

	shape_1.disabled = not enabled_shapes.has(1)
	shape_2.disabled = not enabled_shapes.has(2)
	shape_4.disabled = not enabled_shapes.has(4)
	shape_5.disabled = not enabled_shapes.has(5)
	shape_6.disabled = not enabled_shapes.has(6)
	shape_7.disabled = not enabled_shapes.has(7)
	shape_8.disabled = not enabled_shapes.has(8)
