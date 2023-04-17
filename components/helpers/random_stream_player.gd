@tool
extends AudioStreamPlayer3D

class_name RandomStreamPlayer

@export var streams: Array[AudioStream]

@export var test: bool = false 

func _process(delta):
	
	if !Engine.is_editor_hint(): 
		return 
		
	if test: 
		play_random()
		test = false 

func play_random(): 
	var st = streams.pick_random()
	
	stream = st
	play()
