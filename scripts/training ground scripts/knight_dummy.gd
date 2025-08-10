extends Dummy

func get_max_health_for_level(level: DummyLevel) -> int:
	match level:
		DummyLevel.LEVEL_1: return 5
		DummyLevel.LEVEL_2: return 10
		DummyLevel.LEVEL_3: return 15
		_: return 15
