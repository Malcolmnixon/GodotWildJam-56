extends Node

@export var depth_top = 0.0
@export var depth_bottom = -10.0

@export var enviroment: WorldEnvironment
@export var directional_light: DirectionalLight3D

var init_light_energy = 0.0
var init_fog_density = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	if is_instance_valid(enviroment): 
		init_fog_density = enviroment.environment.fog_density
		
	if is_instance_valid(directional_light): 
		init_light_energy = directional_light.light_energy

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	var cam_pos = get_viewport().get_camera_3d().global_position
	var depth_normal = (cam_pos.y - depth_top) / (depth_bottom - depth_top )
	
	depth_normal = clamp(depth_normal, 0.01, 1.0)
	
	directional_light.light_energy = init_light_energy * (1 - depth_normal)
	enviroment.environment.fog_density = init_fog_density * depth_normal
