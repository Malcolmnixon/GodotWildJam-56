extends CharacterBody3D

# gore scene
var scene = preload("res://components/animals/shark_gibs.tscn")

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
	if get_node("AnimationPlayer"): 
		get_node("AnimationPlayer").play("swim")

func _physics_process(delta : float):
	if !_player and GameManager.player: 
		_player = GameManager.player
		
	_target = _player.global_position

	# Update how long ago the player was last seen
	_memory_age += delta

	# Get some player information
	var to_player := _player.global_position - global_position
	var to_player_distance := to_player.length()
	var to_player_direction := to_player.normalized()


	# Turn to the target
	global_transform = global_transform.interpolate_with(
		global_transform.looking_at(_target),
		1 * delta)

	# Move the shark
	velocity = (_target - global_position).normalized() * 5.0
	move_and_slide()
	
	if $Mouth.global_position.distance_to(_player.global_position) < 2: 
		_player.health.apply_damage(delta)

func _on_health_health_depleted():
	gore()
	queue_free()


func gore():
	var gibs = scene.instantiate()
	var parent = self.get_parent()
	parent.add_child(gibs)
	gibs.global_position = self.global_position


func _on_mouth_body_entered(body):
	print(body)
	if body is XRToolsPlayerBody: 
		print("chop")
		body.get_parent().health.apply_damage(60)
