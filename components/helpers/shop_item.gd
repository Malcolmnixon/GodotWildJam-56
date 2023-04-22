extends XRToolsPickable

@export var shop_item_name: String

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	
	
	var item_bought = GlobalEzcfg.get_value(
		"shop", 
		shop_item_name,
		0
	)
	
	if item_bought: 
		visible = true 
		process_mode = Node.PROCESS_MODE_INHERIT
	else: 
		visible = false  
		process_mode = Node.PROCESS_MODE_DISABLED

	GameManager.item_bought.connect(_item_bought)
	
func _item_bought(item): 
	if item == shop_item_name: 
		visible = true 
		process_mode = Node.PROCESS_MODE_INHERIT
		
