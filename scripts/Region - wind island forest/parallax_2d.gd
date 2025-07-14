extends ParallaxBackground

@export var mirror_x: bool = true
@export var mirror_y: bool = false

func _ready():
	var mirror = Vector2(1024, 0) 
	for child in get_children():
		if child is ParallaxLayer:
			child.motion_mirroring = mirror
