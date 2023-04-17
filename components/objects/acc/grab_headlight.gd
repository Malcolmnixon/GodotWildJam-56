extends XRToolsPickable

# Flashlight turn on/off button
@export var trigger_action : String = "trigger"

# Battery drop button
@export var drop_action : String = "by_button"

@export var energy_timer_time : float = .25

@export var current_energy : int = 0

@export var energy_drain_rate = 1

@onready var battery_zone = $BatteryZone


# Current controller holding this object
var _current_controller : XRController3D

var got_energy : bool = true
var isOn : bool = false
var battery_energy : int = 0



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# In Godot 4 we must now manually call our super class ready function
	super()

	# Listen for when this object is picked up or dropped
	picked_up.connect(_on_picked_up)
	dropped.connect(_on_dropped)


func action():
	if got_energy and $headlight/SpotLight3D.visible == false:
		emit_signal("action_pressed", self)
		if battery_energy >= 1 or current_energy >= 1:
			if battery_energy >= 1:
				battery_energy-= energy_drain_rate
				$headlight/SpotLight3D.light_energy = battery_energy  / 100
				current_energy = battery_energy
				
				var battery = battery_zone.picked_up_object
				if battery != null:
					battery.get_node("Battery").energy = battery_energy

			if current_energy <= 0:
				emit_signal("light_off")

		if current_energy <= 0:
			$headlight/SpotLight3D.visible = false

		# Make player wait until time designated for gun to allow next shot
		got_energy = false
		$LightTimer.wait_time = energy_timer_time
		$LightTimer.start()
# Called when this object is picked up
func _on_picked_up(_pickable) -> void:
	# Listen for button events on the associated controller
	_current_controller = get_picked_up_by_controller()
	if _current_controller:
		_current_controller.button_pressed.connect(_on_controller_button_pressed)
		battery_zone.enabled = true


# Called when this object is dropped
func _on_dropped(_pickable) -> void:
	# Unsubscribe to controller button events when dropped
	if _current_controller:
		_current_controller.button_pressed.disconnect(_on_controller_button_pressed)
		_current_controller = null
		battery_zone.enabled = false
		$headlight/Lid.visible = true

# Called when a controller button is pressed
func _on_controller_button_pressed(button : String):
	# Skip if not pose-toggle button
	if button != "by_button":
		return

	# Switch the grab point
	var active_grab_point := get_active_grab_point()
	if active_grab_point == $GrabPointHandLeft:
		switch_active_grab_point($GrabPointGripLeft)
		await get_tree().create_timer(1).timeout
		switch_active_grab_point($GrabPointHandLeft)
	elif active_grab_point == $GrabPointHandRight:
		switch_active_grab_point($GrabPointGripRight)
		await get_tree().create_timer(1).timeout
		switch_active_grab_point($GrabPointHandRight)


func _process(delta):
	if is_picked_up():
		$BatteryBar.text = str(current_energy)
		#make it impossible to grab battery while holding the flashlight if it has energy left to prevent misfires when trying to use slide
		if battery_zone.picked_up_object == null or battery_energy == 0:	
			battery_zone.enabled = true
			$headlight/Lid.visible = false
		else:
			battery_zone.enabled = false
			$headlight/Lid.visible = true

		if picked_up_by != null and by_controller != null:
			if by_controller.get_input(trigger_action) > 0.5:
				if current_energy <= 0:
					isOn = false
					return
				else:
					$headlight/SpotLight3D.visible = !$headlight/SpotLight3D.visible
					isOn = true
					action()

	if picked_up_by != null and by_controller != null:
		if by_controller.get_input(drop_action):
			# drop our magazine
			battery_zone.drop_object()


func _on_light_timer_timeout():
	got_energy = true

func _on_battery_zone_has_picked_up(what):
	if what.get_node_or_null("Battery") != null:
		battery_energy = what.get_node_or_null("Battery").energy


func _on_battery_zone_has_dropped():
	if current_energy > 1:
		current_energy = 0
		$headlight/SpotLight3D.visible = false
	battery_energy = 0


func _on_interactable_area_button_button_pressed(button):
	if current_energy <= 0:
		isOn = false
		return
	else:
		$headlight/SpotLight3D.visible = !$headlight/SpotLight3D.visible
		isOn = true
		action()
