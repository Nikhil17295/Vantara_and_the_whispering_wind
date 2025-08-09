extends CharacterBody2D

@export var axe_scene: PackedScene
@export var attack_interval_min := 1.5
@export var attack_interval_max := 2.5
@onready var axe_spawn_point: Marker2D = $AxeSpawnPoint
@onready var raycasts_node := $Raycasts
@onready var axe_spawn := $AxeSpawnPoint
@onready var sprite := $AnimatedSprite2D
@onready var touch_hitbox = $TouchHitbox
@onready var original_direction = true

@export var move_speed := 300.0
@export var jump_force := -400.0
@export var gravity := 1000.0

var dir = 0.0
var chase_timer_on = false
var is_chasing := false
var dash_cutoff_timer := 0.0
var dash_timer := 0.0
var next_dash_time = 0.0
var jump_timer := 0.0
var next_jump_time := 0.0
var last_known_vami_position: Vector2 = Vector2.ZERO

var vami: Node2D = null
var frame_counter := 0
var can_see_vami := false
var attack_timer := 0.0

func _ready():
	next_jump_time = randf_range(2.0, 3.0)
	next_dash_time = randf_range(2.0, 4.0)


	for ray in raycasts_node.get_children():
		if ray is RayCast2D:
			ray.collision_mask = 1 << 1  # Layer 2 (shifted bit)
	attack_timer = randf_range(attack_interval_min, attack_interval_max)

func _physics_process(delta):
	# ✅ Lazy-load Vami after she's added to the scene tree
	if can_see_vami:
		# Random jump
		if is_on_floor():
			jump_timer += delta
		if jump_timer >= next_jump_time:
			velocity.y += jump_force
			jump_timer = 0.0
			next_jump_time = randf_range(1.0, 2.0)

		# Random dash
		dash_timer += delta
		dash_cutoff_timer += delta
		if dash_timer >= next_dash_time:
			dash_timer = 0.0
			next_dash_time = randf_range(2.0, 4.0)
			dash_cutoff_timer = 0.0 
			dir = sign(vami.global_position.x - global_position.x)

		if dash_cutoff_timer < 1.0:
			velocity.x = dir * move_speed
		else :
			velocity.x = 0.0
	if not can_see_vami:
		velocity.x = 0.0

	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	if is_on_floor() and velocity.y > 0.0:
		velocity.y = 0.0

# Animation control
	if not is_on_floor():
		sprite.play("Run")
	elif abs(velocity.x) > 0.1:
		sprite.play("Run")
	else:
		sprite.play("idle")

	move_and_slide()

	if vami == null:
		vami = get_parent().get_parent().get_node("Vami")

	frame_counter += 1
	if frame_counter == 20:
		_check_vision()
		frame_counter = 0

	if can_see_vami:
		var vami_on_right = vami.global_position.x > global_position.x
		var vami_is_behind = (original_direction and vami_on_right) or (not original_direction and not vami_on_right)
		if vami_is_behind:
			_face_vami()

		attack_timer -= delta
		if attack_timer <= 0:
			_throw_axe()
			attack_timer = randf_range(attack_interval_min, attack_interval_max)

func _face_vami():
	for ray in raycasts_node.get_children():
			if ray is RayCast2D:
				ray.target_position.x *= -1
	if original_direction == true:
		original_direction = false
		sprite.flip_h = true
		axe_spawn_point.position.x = 50.0
		for shape in touch_hitbox.get_children():
			if shape is CollisionShape2D:
				shape.rotation *= -1
				var pos = shape.position
				pos.x *= -1
				shape.position = pos

	else :
		sprite.flip_h = false
		original_direction = true
		axe_spawn_point.position.x = -50.0
		for shape in touch_hitbox.get_children():
			if shape is CollisionShape2D:
				shape.rotation *= -1
				var pos = shape.position
				pos.x *= -1
				shape.position = pos

	
func _check_vision():
	can_see_vami = false  # default to false

	for ray in raycasts_node.get_children():
		if ray is RayCast2D and ray.is_colliding():
			var hit = ray.get_collider()
			if hit == vami:
				can_see_vami = true
				break

func _throw_axe():
	if not axe_scene:
		return
	var axe = axe_scene.instantiate()
	get_parent().add_child(axe)
	axe.global_position = axe_spawn.global_position
