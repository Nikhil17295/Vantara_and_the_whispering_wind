extends ParallaxLayer




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	motion_offset.x +=  5*delta  
