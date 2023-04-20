extends CharacterBody3D

# How far can the shark see
const SHARK_VISION_DISTANCE := 40.0

# What angle can the shark see
const SHARK_VISION_ANGLE := deg_to_rad(70.0)

# How long will the shark remember the player
const SHARK_MEMORY := 10.0

# Distance at whish shark flees player and is gone
const SHARK_ESCAPE_DISTANCE := 200.0

# Shark speed when swimming
const SHARK_SWIM_SPEED := 6.0

# Shark speed when roaming
const SHARK_ROAM_SPEED := 2.0


# The shark mode
enum SharkMode {
	ROAMING,		# Randomly moving
	HUNTING,		# Hunting the player
	FLEEING			# Fleeing the player
}


# Path to the player node
@export_node_path("CharacterBody3D", "XRToolsPlayerBody") var player : NodePath

# Shark mode
@export var mode : SharkMode = SharkMode.ROAMING


# Player node
var _player : Node3D

# Duration for sharks current action
var _memory_age := SHARK_MEMORY

# Where was the player last seen
var _last_seen_position := Vector3.ZERO

# Shark target
var _target := Vector3.ZERO


func _ready():
	_player = GameManager.player
	
	if get_node("AnimationPlayer"): 
		get_node("AnimationPlayer").play("Swim")

func _physics_process(delta : float):
	# Update how long ago the player was last seen
	_memory_age += delta

	# Get some player information
	var to_player := _player.global_position - global_position
	var to_player_distance := to_player.length()
	var to_player_direction := to_player.normalized()

	# Handle fleeing
	if mode == SharkMode.FLEEING:
		# Detect if shark has escaped
		if to_player_distance >= SHARK_ESCAPE_DISTANCE:
			queue_free()
			return

		# Pick direction away from player
		_target = global_position - to_player * 100.0
		_target.y = 30.0
	else:
		# Test if the shark can see the player
		var to_player_angle := global_transform.basis.z.angle_to(to_player_direction)
		var can_see_player := (
			to_player_distance < SHARK_VISION_DISTANCE and 
			to_player_angle < SHARK_VISION_ANGLE)

		# Handle shark update
		if can_see_player:
			# Player visible, target player
			mode = SharkMode.HUNTING
			_memory_age = 0.0
			_target = _player.global_position
		elif _memory_age >= SHARK_MEMORY:
			# Roam to a new random position
			mode = SharkMode.ROAMING
			_memory_age = 0.0
			_target = Vector3(
				randf_range(-100.0, 100.0),
				randf_range(10.0, 30.0),
				randf_range(-100.0, 100.0))

	# Turn to the target
	global_transform = global_transform.interpolate_with(
		global_transform.looking_at(_target),
		1 * delta)

	# Pick the speed
	var speed := SHARK_ROAM_SPEED if mode == SharkMode.ROAMING else SHARK_SWIM_SPEED
	
	# Move the shark
	velocity = (_target - global_position).normalized() * speed
	move_and_slide()

func _on_health_health_depleted():
	queue_free()
