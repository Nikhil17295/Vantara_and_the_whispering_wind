extends CharacterBody2D

@export var axe_scene: PackedScene
@export var attack_interval_min := 1.5
@export var attack_interval_max := 2.5

@onready var raycasts_node := $Raycasts
@onready var axe_spawn := $AxeSpawnPoint
@onready var sprite := $AnimatedSprite2D

var vami: Node2D = null
var frame_counter := 0
var can_see_vami := false
var attack_timer := 0.0

func _ready():
	add_to_group("Vami")
	attack_timer = randf_range(attack_interval_min, attack_interval_max)

func _physics_process(delta):
	# ✅ Lazy-load Vami after she's added to the scene tree
	if vami == null:
		vami = get_tree().get_first_node_in_group("Vami")
		if vami:
			print("vami found")
		else :
			print("vami not found")


	frame_counter += 1
	if frame_counter == 20:
		_check_vision()
		frame_counter = 0

	if can_see_vami:
		_face_vami()
		attack_timer -= delta
		if attack_timer <= 0:
			_throw_axe()
			attack_timer = randf_range(attack_interval_min, attack_interval_max)

func _face_vami():
	if not vami:
		return

	var vami_dir = sign(vami.global_position.x - global_position.x)

func _check_vision():
	can_see_vami = false
	for ray in raycasts_node.get_children():
		if ray is RayCast2D:
			ray.force_raycast_update()
			if ray.is_colliding() and ray.get_collider() == vami:
				can_see_vami = true
				break
	if can_see_vami:
		print("👁️ Orc sees Vami")
	else:
		print("🙈 Orc does not see Vami")

func _throw_axe():
	if not axe_scene:
		return
	var axe = axe_scene.instantiate()
	get_parent().add_child(axe)
	axe.global_position = axe_spawn.global_position
	if axe.has_method("launch_direction"):
		axe.launch_direction = (vami.global_position - global_position).normalized()
