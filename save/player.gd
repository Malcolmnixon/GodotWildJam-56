extends XROrigin3D

enum PlayerBehaviour { 
	swim, 
	land
}

@export var player_behaviour: PlayerBehaviour = PlayerBehaviour.land
var swim_node = preload("res://game/swimming_level/movement/movement_swimming.tscn")

func _enter_tree():
	GameManager.player = self

func _ready():
	set_behaviour(player_behaviour)

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
