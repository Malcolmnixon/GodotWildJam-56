extends Node

var player = null 
var player_path = "res://save/player.tscn"
var spawn_point: Vector3 = Vector3.ZERO

var collected_coins : int = 0
var collected_cocain : int = 0
var current_level_root: Node3D = null 

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func load_player(o): 
	var player = preload("res://components/player/player.tscn")
	var p = player.instantiate()
	
	o.add_child(p)
	p.set_owner(o)
	
	p.global_position = spawn_point
	player = p 
	
func set_spawn_point(pos): 
	spawn_point = pos

func collect_coin(): 
	var current_coins: int = GlobalEzcfg.get_value(
		"collectables", 
		"coins",
	)
	
	var new_amount: int = current_coins + 1
	
	GlobalEzcfg.save_value(
		"collectables", 
		"coins", 
		new_amount
	)

func collect_cocain(): 
	var current_cocain: int = GlobalEzcfg.get_value(
		"collectables", 
		"cocain",
	)
	
	var new_amount: int = current_cocain + 1
	
	GlobalEzcfg.save_value(
		"collectables", 
		"cocain", 
		new_amount
	)
