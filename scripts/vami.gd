extends CharacterBody2D

# Movement speeds
const SPEED = 270.0
const MAX_FALL_SPEED = 750.0

# Jump forces
const JUMP_VELOCITY = -470.0
const GRAVITY = 1100.0
const FALL_GRAVITY_MULTIPLIER = 1.5
const SHORT_JUMP_MULTIPLIER = 2.3

# Timings
const COYOTE_TIME = 0.1
const JUMP_BUFFER_TIME = 0.1

# Acceleration
const ACCELERATION = 1500.0
const FRICTION = 1800.0
const AIR_ACCELERATION = 1400.0
const AIR_FRICTION = 700.0

# Apex hang
const APEX_HANG_VELOCITY = 30.0
const APEX_GRAVITY_MULTIPLIER = 0.5

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# State variables
var jump_buffer = 0.0
var coyote_time: float = 0.0
var direction: float = 0.0

func _ready():
	animated_sprite.play("idle")
	get_viewport().size = DisplayServer.screen_get_size()

@onready var camera = $Camera2D
var cam_offset := Vector2.ZERO
var facing_direction := 1
const LOOKAHEAD_ZONE := 50
var vertical_target = -10

func _process(delta):
	if direction != 0:
		facing_direction = direction

	# Only activate lookahead if player is near center
	var player_offset = global_position.x - camera.global_position.x

	if abs(player_offset) <= LOOKAHEAD_ZONE:
		cam_offset.x = (LOOKAHEAD_ZONE * facing_direction) + player_offset
	else:
		cam_offset.x = 0  # Freeze when off-center

	# Vertical look target
	if velocity.y >= MAX_FALL_SPEED:
		vertical_target = 110.0
	elif Input.is_action_pressed("look_up"):
		vertical_target = -80.0
	elif Input.is_action_pressed("look_down"):
		vertical_target = 90.0
	else:
		vertical_target = -10.0

	# Apply vertical smoothing to cam_offset.y, not directly to camera
	cam_offset.y = move_toward(cam_offset.y, vertical_target, delta * 250.0)

	# Apply full smoothed offset to camera
	camera.offset = camera.offset.move_toward(cam_offset, delta * 180.0)


func _physics_process(delta: float) -> void:
	direction = Input.get_axis("move_left", "move_right")
	if direction != 0:
		facing_direction = direction
	var grounded: bool = is_on_floor()

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
		if direction != 0:
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
