extends CharacterBody2D

# Movement speeds
const SPEED = 280.0
const MAX_FALL_SPEED = 800.0

# Jump forces
const JUMP_VELOCITY = -470.0
const GRAVITY = 1100.0
const FALL_GRAVITY_MULTIPLIER = 1.6
const SHORT_JUMP_MULTIPLIER = 2.4

# Timings
const COYOTE_TIME = 0.1
const JUMP_BUFFER_TIME = 0.1

# Acceleration
const ACCELERATION = 2100.0
const FRICTION = 1700.0
const AIR_ACCELERATION = 1200.0
const AIR_FRICTION = 700.0

# Apex hang
const APEX_HANG_VELOCITY = 30.0
const APEX_GRAVITY_MULTIPLIER = 0.5

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_left: RayCast2D = $Node2D/Rayleft
@onready var ray_center: RayCast2D = $Node2D/Raycenter
@onready var ray_right: RayCast2D = $Node2D/Rayright


var jump_buffer=0.0
var coyote_time:float=0.0
var direction : float = 0.0
var grounded : bool = true

func _ready():
	animated_sprite.play("idle")
	
	# used physics process to execute my functions as awhole while making the functions seperately 
func _physics_process(delta: float) -> void:
	direction = Input.get_axis("move_left","move_right")
	grounded = is_grounded()
	handle_horizontal_movement(delta)
	handle_animation()
	handle_gravity_and_jump(delta)
	move_and_slide()

	# making the custom grounded func instead of is on floor
func is_grounded() -> bool:
	return ray_left.is_colliding() or ray_center.is_colliding() or ray_right.is_colliding()
	
func handle_horizontal_movement(delta : float) -> void:
	# making horizontal movement
	if grounded:
	# Ground movement
		if direction != 0:
			velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	else:
	# Air movement
		if direction != 0:
			velocity.x = move_toward(velocity.x, direction * SPEED, AIR_ACCELERATION * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, AIR_FRICTION * delta)

func handle_animation():
	# need to add sprite animations in it
	if direction != 0:
		animated_sprite.play("idle")
		animated_sprite.flip_h = direction < 0
	else:
		animated_sprite.play("idle")
		
		
	# for the jump, basic
func handle_gravity_and_jump(delta) -> void:
	
	# in not grounded section:
	#    there are gravity controls 
	
	if not grounded:
		coyote_time -= delta
		# apex hanging of the jump
		if abs(velocity.y) < APEX_HANG_VELOCITY :
			velocity.y += GRAVITY * delta * APEX_GRAVITY_MULTIPLIER
		else:
			velocity.y += GRAVITY * delta
		
			
			if velocity.y > 0:
				velocity.y += GRAVITY * (FALL_GRAVITY_MULTIPLIER - 1) * delta
			elif velocity.y < 0 and not Input.is_action_pressed("jump"):
				velocity.y += GRAVITY * (SHORT_JUMP_MULTIPLIER - 1) * delta
		velocity.y = min( velocity.y , MAX_FALL_SPEED )


	else: # this is the grounded section
		if velocity.y > 0: # Only reset if not in jump
			velocity.y = 0
		coyote_time = COYOTE_TIME


	  # this here is for jump buffer and with this there is no need to check many times about the jump is pressed or not
	if Input.is_action_just_pressed("jump"):
		jump_buffer=JUMP_BUFFER_TIME
	else :
		jump_buffer -= delta
		
	 # this is the main code that executes the jump
	if jump_buffer > 0 and (grounded or coyote_time > 0):
		velocity.y = JUMP_VELOCITY
		coyote_time = 0.0  
		jump_buffer = 0.0
