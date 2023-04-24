extends Label3D


# Called when the node enters the scene tree for the first time.
func _ready():
	var amount = GlobalEzcfg.get_value(
		"collectables",
		"cocaine", 
		0
	)
	
	
	if amount >= 5: 
		text = "You win!"
	else:
		text = str(amount) + "/5 collected"
