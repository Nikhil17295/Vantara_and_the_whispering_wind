extends Node

# 📅 Time System
var current_time: float = 0.0  # In-game hours (0–24)
const TIME_SPEED: float = 0.04 # Controls how fast in-game time passes
enum TimeZone { DAWN, DUSK, NIGHT }

# 💤 Fatigue System
var fatigue: float = 0.0  # 0.0 to 1.0
var hours_since_sleep: float = 0.0
const FATIGUE_MAX: float = 1.0

# 🗺️ World Tracking
var current_room_id: int = 101
var current_region_id: int = 1
const TRAINING_GROUND_ROOM_ID = 101

func _ready():
	start_game()

func _process(delta):
	update_time_and_fatigue(delta)

func start_game():
	load_room(TRAINING_GROUND_ROOM_ID)
	fatigue = 0.0
	hours_since_sleep = 0.0
	current_time = 0.0

func load_room(room_id: int):
	current_room_id = room_id
	# current_region_id = RoomRegistry.ROOMS[room_id].region  # Optional for later
	print("Room loaded:", room_id)

func get_current_time_zone() -> TimeZone:
	if current_time < 8.0:
		return TimeZone.DAWN
	elif current_time < 16.0:
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
		return 0.025  # 10% over 4 hrs
	elif hours <= 16.0:
		return 0.0375  # 15% over 4 hrs
	elif hours <= 20.0:
		return 0.0625  # 25% over 4 hrs
	else:
		return 0.10    # 10% per hour

func sleep():
	fatigue = 0.0
	hours_since_sleep = 0.0
	print("Vami has rested.")

func get_fatigue_penalty_factor() -> float:
	return 1.0 - (fatigue * 0.20)
