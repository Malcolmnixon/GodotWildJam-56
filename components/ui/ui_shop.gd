extends Control


func _ready():
	if GameManager.get_shop_item("harpoon"): 
			$ColorRect/VBoxContainer/HarpoonContainer/HarpoonButton.disabled = true
	if GameManager.get_shop_item("headlamp"): 
			$ColorRect/VBoxContainer/HeadlampContainer/HeadlampButton.disabled = true
	if GameManager.get_shop_item("knife"): 
		$ColorRect/VBoxContainer/KnifeContainer/KnifeButton.disabled = true
		

func _process(delta):
	$ColorRect/Control/CreditsLabel.text = "CREDITS: " + str(get_coins())

func get_coins() -> int: 
	var current_coins: int = GlobalEzcfg.get_value(
		"collectables", 
		"coins",
		0
	)
	
	return current_coins

func buy_item(item: String, price): 
	GameManager.buy_shop_item(item, price)
	GameManager.emit_signal("item_bought", item)

func _on_harpoon_button_pressed():
		if get_coins() >= 5: 
			buy_item("harpoon", 5)
			$ColorRect/VBoxContainer/HarpoonContainer/HarpoonButton.disabled = true

func _on_knifelamp_button_button_down():
	if get_coins() >= 2: 
		buy_item("knife", 2)
		$ColorRect/VBoxContainer/KnifeContainer/KnifeButton.disabled = true

func _on_headlamp_button_pressed():
	if get_coins() >= 3: 
		buy_item("headlamp", 3)
		$ColorRect/VBoxContainer/HeadlampContainer/HeadlampButton.disabled = true

