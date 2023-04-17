extends Node

@export var energy : int
func _physics_process(_delta):
	if energy <= 0:
		queue_free()
