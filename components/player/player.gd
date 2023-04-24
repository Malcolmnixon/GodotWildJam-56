extends XROrigin3D

enum PlayerBehaviour { 
	swim, 
	land
}



@export var player_behaviour: PlayerBehaviour = PlayerBehaviour.land

@onready var health: Health = $Health
var swim_node = preload("res://game/swimming_level/movement/movement_swimming.tscn")
var current_oxygen: float = 100.0


func _enter_tree():
	GameManager.player = self

func _ready():
	set_behaviour(player_behaviour)
	center_player_on(global_transform)
	
func _process(delta):
	if player_behaviour == PlayerBehaviour.swim: 
		current_oxygen -= delta * 2
	
	
	if health.current_health <= 50: 
		$XRCamera3D/HurtScreen.visible = true
	else: 
		$XRCamera3D/HurtScreen.visible = false
		
func set_behaviour(behaviour: PlayerBehaviour):
	player_behaviour = behaviour
	
	if player_behaviour == PlayerBehaviour.swim: 
		$LeftHand/MovementDirect.enabled = false 
		$RightHand/MovementDirect.enabled = false 
		$RightHand/MovementJump.enabled = false 
		$RightHand/MovementTurn.enabled = true 
		$MovementSwimming.enabled = true
	else: 
		$LeftHand/MovementDirect.enabled = true 
		$RightHand/MovementDirect.enabled = true 
		$RightHand/MovementJump.enabled = true 
		$RightHand/MovementTurn.enabled = true 
		$MovementSwimming.enabled = false
		
func center_player_on(p_transform : Transform3D):
	# In order to center our player so the players feet are at the location
	# indicated by p_transform, and having our player looking in the required
	# direction, we must offset this transform using the cameras transform.

	# So we get our current camera transform in local space
	var camera_transform = $XRCamera3D.transform

	# We obtain our view direction and zero out our height
	var view_direction = camera_transform.basis.z
	view_direction.y = 0

	# Now create the transform that we will use to offset our input with
	var transform : Transform3D
	transform = transform.looking_at(-view_direction, Vector3.UP)
	transform.origin = camera_transform.origin
	transform.origin.y = 0

	# And now update our origin point
	global_transform = (p_transform * transform.inverse()).orthonormalized()

func _on_oxygen_timer_timeout():
	if current_oxygen <= 0: 
		health.apply_damage(5)

func _on_health_health_depleted():
	$XRCamera3D/YouDied.visible = true 
	
	await  get_tree().create_timer(2).timeout
	
	GameManager.current_level_root.load_scene("res://game/start_level/start_level.tscn")
