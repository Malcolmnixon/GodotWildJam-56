extends Node3D

@export var damage = 3
@export var speed : float = 15
var hit = false 

func _physics_process(delta):
	if hit: 
		return 
	
	if $RayCast3D.is_colliding(): 
		var last_trans = global_transform
		get_parent().remove_child(self)
		$RayCast3D.get_collider().add_child(self)
		if $RayCast3D.get_collider().get_node("Health"): 
			$RayCast3D.get_collider().get_node("Health").apply_damage(damage)
			$BloodSplatter.emitting = true
		global_transform = last_trans
		hit = true 
	
	global_position -= global_transform.basis.z * delta * speed
