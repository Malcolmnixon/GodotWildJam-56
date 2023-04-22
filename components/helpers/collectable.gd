extends XRToolsPickable

enum Type { 
	coin, 
	cocaine
}

@export var stream : AudioStream
@export var type : Type = Type.coin

# Called when the node enters the scene tree for the first time.
func _ready():
	picked_up.connect(_on_picked_up)
	if stream:
		$AudioStreamPlayer3D.stream = stream

func _on_picked_up(pickable):
	if type == Type.coin: 
			GameManager.collect_coin()
	else: 
		GameManager.collect_cocaine()
	print("collected")
	$AudioStreamPlayer3D.play()

	await get_tree().create_timer(0.5).timeout
	
	queue_free()
