extends Area2D
class_name Dummy

enum DummyLevel { LEVEL_1, LEVEL_2, LEVEL_3 }

@export var normal_texture: Texture2D
@export var broken_texture: Texture2D

var current_health: int
var max_health: int
var current_level: DummyLevel = DummyLevel.LEVEL_1
var is_broken = false

@onready var sprite: Sprite2D = $Sprite2D
#@onready var hit_particles = $HitParticles
#@onready var break_particles = $BreakParticles
#@onready var restore_particles = $RestoreParticles

func _ready():
	apply_level(current_level)

func apply_level(level: DummyLevel) -> void:
	current_level = level
	max_health = get_max_health_for_level(level)
	current_health = max_health
	sprite.texture = normal_texture
	is_broken = false

func take_damage(amount: int) -> void:
	if is_broken:
		return
	else:
		current_health -= amount
		flash_white()
		shake_on_hit()
		#play_particles(hit_particles)

	if current_health <= 0:
		break_dummy()

func break_dummy():
	is_broken = true
	current_health = 0
	sprite.texture = broken_texture
	#play_particles(break_particles)

func restore_dummy():
	if not is_broken:
		return
	apply_level(current_level)
	#play_particles(restore_particles)

func flash_white():
	var original_modulate = sprite.modulate
	sprite.modulate = Color(1, 1, 1)
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = original_modulate

func play_particles(particle_node):
	if particle_node and particle_node is GPUParticles2D:
		particle_node.restart()

func shake_on_hit():
	var tween = create_tween()
	var original_pos = position
	tween.tween_property(self, "position", position + Vector2(4, 0), 0.05)
	tween.tween_property(self, "position", original_pos, 0.05)

func get_max_health_for_level(level: DummyLevel) -> int:
	match level:
		DummyLevel.LEVEL_1: return 10
		DummyLevel.LEVEL_2: return 20
		DummyLevel.LEVEL_3: return 30
		_: return 10
