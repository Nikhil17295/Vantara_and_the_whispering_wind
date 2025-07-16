extends Resource
class_name VamiMemory

### 🩺 CORE STATS
var current_health: int = 5
var max_health: int = 5
var geo: int = 0  

### 🌀 ABILITIES / SKILLS
var has_wind_dash: bool = false
var has_glide: bool = false
var has_wall_jump: bool = false
var has_slam: bool = false

# Optional upgrades
var wind_dash_level: int = 0
var slam_power_level: int = 0

### 🎒 KEY ITEMS / INVENTORY
var has_sun_charm: bool = false
var has_training_scroll: bool = false

# Optional item tracking
var collected_keys: Array[String] = []  
### 🗺️ WORLD PROGRESSION
var unlocked_islands: Array[String] = []    
var explored_rooms: Array[String] = []      

### 👑 BOSSES / EVENTS / NPC FLAGS
var defeated_bosses: Array[String] = []     
var flags: Dictionary = {
	"helped_npc_1": false,
	"opened_temple_gate": false,
	"met_wind_shrine": false,
}

### 🔮 CHARMS / EQUIPMENT
var charm_slots: int = 3
var equipped_charms: Array[String] = []      

### 🚪 FAST TRAVEL / CHECKPOINTS (Optional)
var unlocked_travel_points: Array[String] = []  
