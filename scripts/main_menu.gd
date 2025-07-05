extends CanvasLayer

@onready var panel := $Panel
@onready var start_button := $Panel/VBoxContainer/Start
@onready var exit_button := $Panel/VBoxContainer/Exit

func _ready():
	start_button.pressed.connect(_on_start_game)
	exit_button.pressed.connect(_on_exit_game)

func _on_start_game():
	self.visible = false
	get_node("../FadeOverlay").visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED  # Optional for gameplay

func _on_exit_game():
	get_tree().quit()
