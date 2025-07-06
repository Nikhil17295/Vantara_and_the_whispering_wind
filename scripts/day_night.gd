extends CanvasModulate

@export var gradient: GradientTexture1D
@export var blend_speed: float = 1.0

func _ready():
	update_color_immediate()
func update_color_immediate():
	var t := GameManager.current_time / 24.0
	color = gradient.gradient.sample(t)
	self.color = color

func _process(delta):
	if not gradient:
		return

	var t : float = clamp(GameManager.current_time / 24.0, 0.0, 1.0)

	var target_color : Color = gradient.gradient.sample(t)
	self.color = self.color.lerp(target_color, delta * blend_speed)
