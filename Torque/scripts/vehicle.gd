extends VehicleBody

# Attributes
export(float, 160) var braking_power = 100
export(float, 0.8) var steering_limit = 0.3
export(float, 3.2) var steering_speed = 1.6
export(int, 120) var engine_force_value = 60

# States
var braking : bool

# Inputs
var acceleration_input : float
var steering_input : float

func _physics_process(delta):
	if Game.player.current_vehicle == self:
		apply_vehicle_attributes(delta)
		get_input()

func apply_vehicle_attributes(delta):
	var speed = linear_velocity.length()
	
	brake = braking_power * delta if braking else 0
	steering = move_toward(steering, steering_input * steering_limit, steering_speed * delta)
	
	if acceleration_input > 0:
		if speed < 5 and speed != 0: engine_force = clamp(engine_force_value * 5 / speed, 0, 100)
		else: engine_force = engine_force_value
	else:
		engine_force = 0
	
	if acceleration_input < 0: 
		if transform.basis.xform_inv(linear_velocity).x >= -1:
			if speed < 5 and speed != 0: engine_force = -clamp(engine_force_value * 5 / speed, 0, 100)
			else: engine_force = -engine_force_value
		else:
			brake = 1
	else:
		brake = 0.0

func get_input():
	acceleration_input = Input.get_axis("accelerate", "reverse")
	braking = Input.is_action_pressed("brake")
	steering_input = Input.get_axis("steer_right", "steer_left")

func reset_attributes():
	engine_force = 0
	steering = 0
