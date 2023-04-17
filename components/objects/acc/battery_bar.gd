extends Label3D

func _ready():
	set_process(true)
	
func _process(_delta: float):
	self.text = get_parent().String(battery_energy)
