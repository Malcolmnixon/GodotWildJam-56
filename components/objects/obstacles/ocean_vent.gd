extends Node3D

@export var target_velocity: Vector3 = Vector3.UP
var player_body: XRToolsPlayerBody

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if is_instance_valid(player_body): 
		player_body.velocity += target_velocity

func _on_xr_tools_wind_area_body_entered(body):
	if body is XRToolsPlayerBody: 
		player_body = body

func _on_xr_tools_wind_area_body_exited(body):
	if body is XRToolsPlayerBody: 
		player_body = null
