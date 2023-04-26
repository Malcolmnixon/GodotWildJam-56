extends XRToolsPickable

@export var shop_item_name: String
@onready var interactable_handle = get_node_or_null("InteractableHandle")
@onready var second_hand_position = get_node_or_null("SecondHandMarker3D")
@onready var primary_hand_position = get_node_or_null("PrimaryHandMarker3D")
# Check if using two-handed
var using_two_handed : bool = false
# Store second hand controller
var second_hand_controller : XRController3D
# Store second hand node
var second_hand
# Store weapon basis just before two-handing
var basis_before_two_handed : Basis
# Store primary hand node's transform as it was before two handing
var primary_hand_original_transform : Transform3D
# Store second hand node's transform as it was before two handing
var second_hand_original_transform :Transform3D

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	# Store default transform basis
	basis_before_two_handed = transform.basis

	picked_up.connect(_on_picked_up)
	dropped.connect(_on_dropped)
	# Connect grabbed and dropped signal from interactable handle for two handed if there is a handle
	if interactable_handle != null:
		interactable_handle.picked_up.connect(_on_second_hand_grabbed)
		interactable_handle.dropped.connect(_on_second_hand_dropped)
		
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
	
func _process(delta):
	# If drop item, turn off two-handed (TO-DO: other steps necessary to return to status quo)
	if by_controller == null:
		using_two_handed = false
	# If two handed activated, change transform to be guided by both hand positions
	if using_two_handed:
		# The following line "works" but the weapon is out of position, thought is this probably has something to do with the operation of the grab points system on the object
		#global_transform.basis = by_controller.global_transform.basis.looking_at(second_hand_controller.global_transform.origin)
		
		# There is a better and more accurate way of doing the below with better Transform math, idea is we want to do the basis calculation above but then also further calculate what positioning is baked into the weapon from using the grab point system
		# Also for some reason this system doesn't allow for twisting the weapon either
		# So basically, insert better object math below to have the rest work.
		#global_transform = by_controller.global_transform.looking_at(second_hand_controller.global_transform.origin)
		#global_transform.origin -= (by_controller.global_transform.origin-_remote_transform.global_transform.origin)
		global_transform = by_controller.global_transform.looking_at(second_hand_controller.global_transform.origin,Vector3.UP)


func _item_bought(item): 
	if item == shop_item_name: 
		visible = true 
		process_mode = Node.PROCESS_MODE_INHERIT


# Called when this object is picked up
func _on_picked_up(_pickable) -> void:
	by_controller = get_picked_up_by_controller()
	if by_controller:
		interactable_handle.transform.origin = Vector3(0,0,0)


# Called when this object is dropped
func _on_dropped(_pickable) -> void:
	if by_controller:
		by_controller = null
		transform.basis = basis_before_two_handed
		interactable_handle.transform.origin = Vector3(0,0,0)


func _on_second_hand_grabbed(_handle):
	# Don't activate two handed mode if not already picked up
	if !is_picked_up():
		return
	# If item is already picked up, then we're in two-handed mode
	if is_picked_up() and by_controller != null:
		second_hand_controller = _handle.by_controller
		second_hand = _handle.by_hand
		second_hand_original_transform = _handle.by_hand.transform
		primary_hand_original_transform = by_hand.transform
		if second_hand.name.matchn("*left*"):
			primary_hand_position.transform = $GrabPointHandRight.transform
		else:
			primary_hand_position.transform = $GrabPointHandLeft.transform
		if second_hand_position != null:
			second_hand_position.get_node("RemoteTransform3D").remote_path = _handle.by_hand.get_path()
		if primary_hand_position != null:	
			primary_hand_position.get_node("RemoteTransform3D").remote_path = by_hand.get_path()
		using_two_handed = true
		
		
func _on_second_hand_dropped(handle):
	# If not using two handed, do nothing
	if !using_two_handed:
		return
	else:
		using_two_handed = false
	# Return to single handed mode
	primary_hand_position.get_node("RemoteTransform3D").remote_path = ""
	second_hand_position.get_node("RemoteTransform3D").remote_path = ""
	by_hand.transform = primary_hand_original_transform
	second_hand.transform = second_hand_original_transform
	second_hand_controller = null
	second_hand = null
	if is_picked_up() and by_controller != null:
		transform.basis = basis_before_two_handed
