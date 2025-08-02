extends Node

# 📅 Time System
const WAKE_TIME = 5.0
var current_time: float = 0.0  # In-game hours (0–24)
const TIME_SPEED: float = 0.25 # Controls how fast in-game time passes
enum TimeZone { DAWN, DUSK, NIGHT }
static var game_started  : bool = false


# 💤 Fatigue System
var fatigue: float = 0.0  # 0.0 to 1.0
var hours_since_sleep: float = 0.0
const FATIGUE_MAX: float = 1.0

# 🗺️ World Tracking
var current_room_id: int = 101
var current_region_id: int = 1
const TRAINING_GROUND_ROOM_ID = 101

func _ready():
	load_room(TRAINING_GROUND_ROOM_ID)
	current_time = 4.0

func _process(delta):
	if game_started == true:
		update_time_and_fatigue(delta)

func start_game():
	load_room(TRAINING_GROUND_ROOM_ID)
	fatigue = 0.0
	hours_since_sleep = 0.0
	current_time = WAKE_TIME
	game_started = true

func load_room(room_id: int):
	current_room_id = room_id

func get_current_time_zone() -> TimeZone:
	if current_time >= 4.0  and current_time < 12.0:
		return TimeZone.DAWN
	elif current_time < 20.0 and current_time >= 12.0:
		return TimeZone.DUSK
	else:
		return TimeZone.NIGHT

func update_time_and_fatigue(delta: float):
	# Update time
	var time_advance = delta * TIME_SPEED
	current_time += time_advance
	if current_time >= 24.0:
		current_time -= 24.0

	# Update fatigue
	hours_since_sleep += time_advance
	var zone = get_current_time_zone()

	if hours_since_sleep > 8.0 and fatigue < FATIGUE_MAX:
		var rate := get_fatigue_rate(hours_since_sleep)

		# Night amplification
		if zone == TimeZone.NIGHT:
			rate *= 1.5

		fatigue += rate * time_advance
		fatigue = clamp(fatigue, 0.0, FATIGUE_MAX)

func get_fatigue_rate(hours: float) -> float:
	if hours <= 12.0:
		return 0.02  # 10% over 4 hrs
	elif hours <= 16.0:
		return 0.035  # 15% over 4 hrs
	elif hours <= 20.0:
		return 0.05  # 25% over 4 hrs
	else:
		return 0.075    # 10% per hour

func sleep():
	current_time = current_time + 8.0
	fatigue = 0.0
	hours_since_sleep = 0.0

func get_fatigue_penalty_factor() -> float:
	return 1.0 - (fatigue * 0.15)


func _on_start_pressed() -> void:
	start_game()
