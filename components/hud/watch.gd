extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var oxygen = $OxygenProgress.value
	
	$OxygenProgress.value = GameManager.player.current_oxygen
	$HealthProgress.value = GameManager.player.health.current_health
	
	var beep = $"../../Beep"
	if oxygen < 30.0: 
		if !beep.playing:
			$"../../Beep".play()
	else: 
		$"../../Beep".stop() 
