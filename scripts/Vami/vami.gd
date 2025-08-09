extends CharacterBody2D

# Movement speeds
const SPEED = 250.0
const MAX_FALL_SPEED = 900.0
const AIR_BOOST_SPEED = 180.0

# Jump forces
const JUMP_VELOCITY = -500.0
const GRAVITY = 1000.0
const FALL_GRAVITY_MULTIPLIER = 1.5
const SHORT_JUMP_MULTIPLIER = 3

# Timings
const COYOTE_TIME = 0.07
const JUMP_BUFFER_TIME = 0.1

# Acceleration
const ACCELERATION = 1500.0
const FRICTION = 2200.0
const AIR_ACCELERATION = 1400.0
const AIR_FRICTION = 2000.0

# Apex hang
const APEX_HANG_VELOCITY = 30.0
const APEX_GRAVITY_MULTIPLIER = 0.5

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurtbox_1: CollisionShape2D = $VamiHurtbox/hurtbox_1
@onready var hitbox_1: CollisionShape2D = $VamiHitbox/hitbox_1

# State variables
var fatigue_factor = 1.0
var speed= SPEED * fatigue_factor
var jump_speed= JUMP_VELOCITY * fatigue_factor
var air_boost_speed = AIR_BOOST_SPEED * fatigue_factor
var jump_buffer = 0.0
var coyote_time: float = 0.0
var direction: float = 0.0
var grounded: bool = false
var last_air_input_direction = 0
static var last_direction := 1.0


func _ready():
	animated_sprite.play("idle")
	get_viewport().size = DisplayServer.screen_get_size()


func _physics_process(delta: float) -> void:
	fatigue_factor = GameManager.get_fatigue_penalty_factor()
	speed= SPEED * fatigue_factor
	jump_speed= JUMP_VELOCITY * fatigue_factor
	air_boost_speed = AIR_BOOST_SPEED * fatigue_factor
	grounded = is_on_floor()
	direction = Input.get_axis("move_left", "move_right")
	if grounded:
		if direction != 0 and (sign(velocity.x) == direction or velocity.x == 0):
			last_direction = direction

	handle_horizontal_movement(delta)
	handle_gravity_and_jump(delta)
	handle_animation()

	move_and_slide()
	
func handle_horizontal_movement(delta: float) -> void:
	if grounded:
		last_air_input_direction = direction
		if direction != 0:
			velocity.x = move_toward(velocity.x, direction * speed, ACCELERATION * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	else:
		if direction != 0 and direction != last_air_input_direction:
			velocity.x = air_boost_speed * direction
			last_air_input_direction = direction

		elif direction != 0:
			velocity.x = move_toward(velocity.x, direction * speed, AIR_ACCELERATION * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, AIR_FRICTION * delta)

func handle_gravity_and_jump(delta: float) -> void:
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
		velocity.y = jump_speed
		jump_buffer = 0.0
		coyote_time = 0.0

func handle_animation() -> void:
	#if not grounded:
		#if velocity.y < 0:
			#animated_sprite.play("idle")
		#else:
			#animated_sprite.play("idle")
	#elif abs(velocity.x) > 10:
		#animated_sprite.play("idle")
	#else:
		#animated_sprite.play("idle")
	animated_sprite.play("idle")

	#if last_dire1ction!= 0:
	

	if last_direction < 0 :
		animated_sprite.flip_h = true
		collision_shape_2d.position.x = -3.0
		hurtbox_1.position.x = -3.0
		hitbox_1.position.x = -43.5
	else:
		animated_sprite.flip_h = false
		collision_shape_2d.position.x = 3.0
		hurtbox_1.position.x = 3.0
		hitbox_1.position.x = 43.5
