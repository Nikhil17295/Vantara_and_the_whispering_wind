extends CharacterBody2D

var speed = 200.0
var  jump_velocity= -450.0
var gravity:float = 981.0
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready():
	animated_sprite.play("idle")
	
func _physics_process(delta: float) -> void:
	handle_horizontal_movement(delta)
	handle_gravity_and_jump(delta)
	move_and_slide()
	
	
func handle_horizontal_movement(delta: float) -> void:
	var direction = Input.get_axis("move_left","move_right")
	velocity.x= direction * speed
	
	if direction != 0:
		animated_sprite.play("idle")
		animated_sprite.flip_h = direction < 0
	else:
		animated_sprite.play("idle")
		
		
	# for the jump, basic
func handle_gravity_and_jump(delta)-> void:
	if not is_on_floor():
		velocity.y += gravity * delta
		if velocity.y > 0 :
			velocity.y += gravity * 0.9 * delta
		elif velocity.y<0 and not Input.is_action_pressed("jump"):
			velocity.y += gravity * delta * 1.5
			
	if is_on_floor():
		velocity.y = 0
	if Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity
