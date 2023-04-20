extends Node3D

@onready var camera = get_viewport().get_camera_3d()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position = global_position.lerp(
		camera.global_position, delta * 20.0
	)
	
	rotation.y = lerp(
		rotation.y, 
		camera.rotation.y,
		delta * 10.0
	)
