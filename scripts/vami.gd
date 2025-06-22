extends CharacterBody2D

# Movement speeds
const SPEED = 280.0
const MAX_FALL_SPEED = 750.0
const AIR_BOOST_SPEED = 200.0

# Jump forces
const JUMP_VELOCITY = -470.0
const GRAVITY = 1100.0
const FALL_GRAVITY_MULTIPLIER = 1.5
const SHORT_JUMP_MULTIPLIER = 2.3

# Timings
const COYOTE_TIME = 0.1
const JUMP_BUFFER_TIME = 0.1

# Acceleration
const ACCELERATION = 800.0
const FRICTION = 2200.0
const AIR_ACCELERATION = 1500.0
const AIR_FRICTION = 1700.0

# Apex hang
const APEX_HANG_VELOCITY = 30.0
const APEX_GRAVITY_MULTIPLIER = 0.5

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# State variables
var jump_buffer = 0.0
var coyote_time: float = 0.0
var direction: float = 0.0
var grounded: bool = is_on_floor()
var last_air_input_direction = 0

func _ready():
	animated_sprite.play("idle")
	get_viewport().size = DisplayServer.screen_get_size()

@onready var camera = $Camera2D
var cam_offset := Vector2.ZERO
var facing_direction := 1
const LOOKAHEAD_ZONE := 60.0
var vertical_target = -20.0
var horizontal_target = 0.0

func _process(delta):
	if direction != 0:
		facing_direction = direction
		
	if grounded :
		horizontal_target = LOOKAHEAD_ZONE * facing_direction
	if not grounded:
		cam_offset.x = horizontal_target

	# Vertical look target
	if velocity.y >= MAX_FALL_SPEED:
		vertical_target = 120.0
	elif grounded and Input.is_action_pressed("look_up"):
		vertical_target = -70.0
	elif grounded and Input.is_action_pressed("look_down"):
		vertical_target = 100.0
	else:
		vertical_target = 20.0

	cam_offset.y = move_toward(cam_offset.y, vertical_target, delta * 180.0)
	cam_offset.x = move_toward(cam_offset.x, horizontal_target , delta * 320.0)
	camera.offset = cam_offset

func _physics_process(delta: float) -> void:
	direction = Input.get_axis("move_left", "move_right")
	if direction != 0:
		facing_direction = direction
	grounded = is_on_floor()

	handle_horizontal_movement(delta, grounded)
	handle_gravity_and_jump(delta, grounded)
	handle_animation(grounded)

	move_and_slide()

func handle_horizontal_movement(delta: float, grounded: bool) -> void:
	if grounded:
		if direction != 0:
			velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	else:
		if direction != 0 and direction != last_air_input_direction:
			velocity.x += AIR_BOOST_SPEED * direction
			last_air_input_direction = direction

		elif direction != 0:
			velocity.x = move_toward(velocity.x, direction * SPEED, AIR_ACCELERATION * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, AIR_FRICTION * delta)

func handle_gravity_and_jump(delta: float, grounded: bool) -> void:
	# Coyote time
	if grounded:
		coyote_time = COYOTE_TIME
	else:
		coyote_time -= delta

	# Jump buffer
	if Input.is_action_just_pressed("jump"):
		jump_buffer = JUMP_BUFFER_TIME
	else:
		jump_buffer -= delta

	# Gravity
	if not grounded:
		if abs(velocity.y) < APEX_HANG_VELOCITY:
			velocity.y += GRAVITY * APEX_GRAVITY_MULTIPLIER * delta
		elif velocity.y > 0:
			velocity.y += GRAVITY * FALL_GRAVITY_MULTIPLIER * delta
		elif velocity.y < 0 and not Input.is_action_pressed("jump"):
			velocity.y += GRAVITY * SHORT_JUMP_MULTIPLIER * delta
		else:
			velocity.y += GRAVITY * delta
		
		velocity.y = min(velocity.y, MAX_FALL_SPEED)
	else:
		if velocity.y > 0:
			velocity.y = 0

	# Jump execution
	if jump_buffer > 0 and (grounded or coyote_time > 0):
		velocity.y = JUMP_VELOCITY
		jump_buffer = 0.0
		coyote_time = 0.0

func handle_animation(grounded: bool) -> void:
	if not grounded:
		if velocity.y < 0:
			animated_sprite.play("jump")
		else:
			animated_sprite.play("fall")
	elif abs(velocity.x) > 10:
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")

	if direction != 0:
		animated_sprite.flip_h = direction < 0
