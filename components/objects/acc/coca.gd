extends XRToolsPickable

@export var coca : int


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# In Godot 4 we must now manually call our super class ready function
	super()

	# Listen for when this object is picked up or dropped
	picked_up.connect(_on_picked_up)
	dropped.connect(_on_dropped)


# Called when this object is picked up
func _on_picked_up(_pickable) -> void:
	coca -= 1

# Called when this object is dropped
func _on_dropped(_pickable) -> void:
	queue_free()
