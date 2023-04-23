extends XRToolsPickable

@export var damage = 1

## Minimum velocity to reach before physical swimming starts
@export var physical_threshold: float = 0.1

# Current controller holding this object
var _current_controller : XRController3D

@onready var hitbox = $Hitbox

@onready var _left_controller := XRHelpers.get_left_controller(self)
@onready var _right_controller := XRHelpers.get_right_controller(self)

var velocity_percision = 5 
@onready var _left_averager = XRToolsVelocityAverager.new(velocity_percision)
@onready var _right_averager = XRToolsVelocityAverager.new(velocity_percision)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# In Godot 4 we must now manually call our super class ready function
	super()

	# Listen for when this object is picked up or dropped
	picked_up.connect(_on_picked_up)
	dropped.connect(_on_dropped)

func _process(delta):
	# set averagers
	_left_averager.add_transform(delta, _left_controller.transform)
	_right_averager.add_transform(delta, _right_controller.transform)
	
func _physics_process(delta):
	# velocities 
	var l_vel = _left_averager.linear_velocity()
	var r_vel = _right_averager.linear_velocity()
	
	# combined velocity lengths 
	var c_length = l_vel.length() + r_vel.length()
	
	# velocity checks for forward and back movement 
	var swim_input = Vector3(l_vel.x, 0, l_vel.z).dot(Vector3(r_vel.x, 0, r_vel.z)) < -physical_threshold
	# Accelerate swim velocity towards the camera 
	if swim_input:
		_melee()


func _melee():
	if _current_controller:
			for body in hitbox.get_overlapping_bodies():
				if body.get_node("Health"): 
					body.get_node("Health").apply_damage(damage) # how is this working, would like to multiply by the current XRToolsVelocityAverager
					$BloodSplatter.emitting = true
# Called when this object is picked up
func _on_picked_up(_pickable) -> void:
	# Listen for button events on the associated controller
	_current_controller = get_picked_up_by_controller()
	if _current_controller:
		_current_controller.button_pressed.connect(_on_controller_button_pressed)


# Called when this object is dropped
func _on_dropped(_pickable) -> void:
	# Unsubscribe to controller button events when dropped
	if _current_controller:
		_current_controller.button_pressed.disconnect(_on_controller_button_pressed)
		_current_controller = null


# Called when a controller button is pressed
func _on_controller_button_pressed(button : String):
	# Skip if not pose-toggle button
	if button != "by_button":
		return

	# Switch the grab point
	var active_grab_point := get_active_grab_point()
	if active_grab_point == $GrabPointHandLeft:
		switch_active_grab_point($GrabPointGripLeft)
	elif active_grab_point == $GrabPointHandRight:
		switch_active_grab_point($GrabPointGripRight)
	elif active_grab_point == $GrabPointGripLeft:
		switch_active_grab_point($GrabPointHandLeft)
	elif active_grab_point == $GrabPointGripRight:
		switch_active_grab_point($GrabPointHandRight)
