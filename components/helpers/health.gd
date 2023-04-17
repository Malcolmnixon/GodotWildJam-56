extends Node

class_name Health

@export var current_health = 100

signal health_depleted
signal damage_taken

func take_damage(dmg): 
	current_health -= dmg 
	
	emit_signal("damage_taken")
	
	if current_health <= 0: 
		emit_signal("health_depleted")
	
