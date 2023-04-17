extends Node

@export var depth_light_top : float = 40.0
@export var depth_light_bottom : float = 5.0

@export var light_top : float = 1.0
@export var light_bottom : float = 0.1

@export var depth_fog_top : float = 20.0
@export var depth_fog_bottom : float = 5.0

@export var fog_density_top : float = 0.02
@export var fog_density_bottom : float = 0.1

@export var enviroment: WorldEnvironment
@export var directional_light: DirectionalLight3D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var cam_pos := get_viewport().get_camera_3d().global_position

	# Calculate the light-coefficient [0.0 .. 1.0]
	var light_coefficient : float = clamp(
		inverse_lerp(depth_light_top, depth_light_bottom, cam_pos.y),
		0.0, 1.0)

	# Apply the light energy to lighting
	var light_energy : float = lerp(light_top, light_bottom, light_coefficient)
	directional_light.light_energy = light_energy
	enviroment.environment.ambient_light_energy = light_energy
	enviroment.environment.fog_light_energy = light_energy

	# Calculate the fog coefficient
	var fog_coefficient : float = clamp(
		inverse_lerp(depth_fog_top, depth_fog_bottom, cam_pos.y),
		0.0, 1.0)

	# Apply the fog coefficient
	var fog_density : float = lerp(fog_density_top, fog_density_bottom, fog_coefficient)
	enviroment.environment.fog_density = fog_density
