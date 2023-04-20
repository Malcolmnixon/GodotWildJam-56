extends Node3D

@export var projectile : PackedScene


func _on_scuba_harpoon_action_pressed(pickable):
	var proj = projectile.instantiate()
	
	GameManager.current_level_root.add_child(proj)
	
	proj.global_position = global_position
	proj.global_rotation = global_rotation
