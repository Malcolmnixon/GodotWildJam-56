@tool
class_name XRToolsMovementSwimming
extends XRToolsMovementProvider


## XR Tools Movement Provider for Swimming
##
## This script provides swimming movement for the player.
##

## Enumeration of swimming behaviour
enum SwimmingType { 
	PHYSICAL, 	# Use physical mostion for input
	ANALOG,		# Use joystick for input
}

## Enumeration of controller to use for swimming
enum SwimmingController {
	LEFT,		## Use left controller
	RIGHT,		## Use right controler
}

## Enumeration of pitch control input
enum SwimmingPitch {
	HEAD,		## Head controls pitch
	CONTROLLER,	## Controller controls pitch
}

## Enumeration of bearing control input
enum SwimmingBearing {
	HEAD,		## Head controls bearing
	CONTROLLER,	## Controller controls bearing
	BODY,		## Body controls bearing
}


## Movement provider order
@export var order : int = 30

## Swing behaviour type 
@export var type: SwimmingType = SwimmingType.PHYSICAL

## Flight controller
@export var controller : SwimmingController = SwimmingController.LEFT

## Flight pitch control
@export var pitch : SwimmingPitch = SwimmingPitch.CONTROLLER

## Flight bearing control
@export var bearing : SwimmingBearing = SwimmingBearing.CONTROLLER

## Swimming speed from control
@export var speed_scale : float = 3.0

## Swimming traction pulling flight velocity towards the controlled speed
@export var speed_traction : float = 3.0

## Swimming drag
@export var drag : float = 0.1

## Guidance effect (virtual fins/wings)
@export var guidance : float = 0.1

## Minimum velocity to reach before physical swimming starts
@export var physical_threshold: float = 0.1

## Velocity multiplier for physical swimming
@export var physical_multiplier: float = 0.1

## Swimming controller
var _controller : XRController3D

# Node references
@onready var _camera := XRHelpers.get_xr_camera(self)
@onready var _left_controller := XRHelpers.get_left_controller(self)
@onready var _right_controller := XRHelpers.get_right_controller(self)

var velocity_percision = 5 
@onready var _left_averager = XRToolsVelocityAverager.new(velocity_percision)
@onready var _right_averager = XRToolsVelocityAverager.new(velocity_percision)


# Add support for is_xr_class on XRTools classes
func is_xr_class(name : String) -> bool:
	return name == "XRToolsMovementSwimming" or super(name)


func _ready():
	# In Godot 4 we must now manually call our super class ready function
	super()

	# Get the flight controller
	if controller == SwimmingController.LEFT:
		_controller = _left_controller
	else:
		_controller = _right_controller

func _process(delta):
	# set averagers
	_left_averager.add_transform(delta, _left_controller.transform)
	_right_averager.add_transform(delta, _right_controller.transform)

# Process physics movement for flight
func physics_movement(delta: float, player_body: XRToolsPlayerBody, disabled: bool):
	
		if type == SwimmingType.PHYSICAL: 
			
			# velocities 
			var l_vel = _left_averager.linear_velocity()
			var r_vel = _right_averager.linear_velocity()
			
			# combined velocity lengths 
			var c_length = l_vel.length() + r_vel.length()
			
			# velocity checks for forward and back movement 
			var forward = l_vel.x < -physical_threshold and r_vel.x > physical_threshold
			var back = l_vel.x > physical_threshold and r_vel.x < -physical_threshold
	
			var swim_velocity := player_body.velocity
			var swim_transform := Transform3D()
			
			# rotate swim transform to make vertical movement more comfortable
			swim_transform = _camera.global_transform.rotated_local(
				Vector3.RIGHT, 
				deg_to_rad(15)
			)
			
			# Accelerate swim velocity towards the camera 
			if forward: 
				swim_velocity += -swim_transform.basis.z * physical_multiplier * c_length
			
			# Apply drag 
			swim_velocity *= 1.0 - drag * delta
			
			# Apply swim velocity to player body 
			player_body.velocity = player_body.move_body(swim_velocity)
			
			return true
		else: 
			# Disable flying if requested, or if no controller
			if disabled or !enabled or !_controller.get_is_active():
				return

			# Select the pitch vector
			var pitch_vector: Vector3
			if pitch == SwimmingPitch.HEAD:
				# Use the vertical part of the 'head' forwards vector
				pitch_vector = -_camera.transform.basis.z.y * player_body.up_player_vector
			else:
				# Use the vertical part of the 'controller' forwards vector
				pitch_vector = -_controller.transform.basis.z.y * player_body.up_player_vector

			# Select the bearing vector
			var bearing_vector: Vector3
			if bearing == SwimmingBearing.HEAD:
				# Use the horizontal part of the 'head' forwards vector
				bearing_vector = -player_body.up_player_plane.project(
						_camera.global_transform.basis.z)
			elif bearing == SwimmingBearing.CONTROLLER:
				# Use the horizontal part of the 'controller' forwards vector
				bearing_vector = -player_body.up_player_plane.project(
						_controller.global_transform.basis.z)
			else:
				# Use the horizontal part of the 'body' forwards vector
				var left := _left_controller.global_transform.origin
				var right := _right_controller.global_transform.origin
				var left_to_right := right - left
				bearing_vector = player_body.up_player_plane.project(
						left_to_right.rotated(player_body.up_player_vector, PI/2))

			# Construct the flight bearing
			var forwards := (bearing_vector.normalized() + pitch_vector).normalized()
			var side := forwards.cross(player_body.up_player_vector)

			# Construct the target velocity
			var joy_forwards := _controller.get_vector2("primary").y
			var joy_side := _controller.get_vector2("primary").x
			var heading := forwards * joy_forwards + side * joy_side

			# Calculate the flight velocity
			var flight_velocity := player_body.velocity
			flight_velocity *= 1.0 - drag * delta
			flight_velocity = flight_velocity.lerp(heading * speed_scale, speed_traction * delta)

			# Apply virtual guidance effect
			if guidance > 0.0:
				var velocity_forwards := forwards * flight_velocity.length()
				flight_velocity = flight_velocity.lerp(velocity_forwards, guidance * delta)

			# If exclusive then perform the exclusive move-and-slide
			player_body.velocity = player_body.move_body(flight_velocity)
			return true

# This method verifies the movement provider has a valid configuration.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := super()

	# Verify the camera
	if !XRHelpers.get_xr_camera(self):
		warnings.append("Unable to find XRCamera3D")

	# Verify the left controller
	if !XRHelpers.get_left_controller(self):
		warnings.append("Unable to find left XRController3D node")

	# Verify the right controller
	if !XRHelpers.get_right_controller(self):
		warnings.append("Unable to find left XRController3D node")

	# Return warnings
	return warnings
