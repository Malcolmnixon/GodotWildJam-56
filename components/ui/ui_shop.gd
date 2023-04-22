extends Control


func _process(delta):
	$ColorRect/Control/CreditsLabel.text = "CREDITS: " + str(get_coins())

func get_coins() -> int: 
	var current_coins: int = GlobalEzcfg.get_value(
		"collectables", 
		"coins",
		0
	)
	
	return current_coins


func _on_harpoon_button_pressed():
		print("pressed")
		if get_coins() >= 3: 
			GameManager.buy_shop_item("harpoon", 3)
			GameManager.emit_signal("item_bought", "harpoon")
			$ColorRect/VBoxContainer/HarpoonContainer/HarpoonButton.disabled = true
