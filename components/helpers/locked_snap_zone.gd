extends RemoteTransform3D

@export var pickable: XRToolsPickable

# Called when the node enters the scene tree for the first time.
func _ready():
	if pickable: 
		pickable.set_collision_mask_value(20, false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !pickable: 
		return 
		
	if pickable.is_picked_up(): 
		remote_path = ""
	else: 
		remote_path = pickable.get_path()
		

