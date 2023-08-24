extends CharacterBody2D

# Physics constants
const GRAVITY = 980 * 2
const JUMP_VELOCITY = 400.0

## Enables debug mode.
@export var show_debug : bool = true

## Enables camera rotation.
@export var camera_rotation : bool = false

## Enables smooth camera and sprite rotation.
@export var smooth_rotation : bool = true

##
# Nodes
##

## The game's camera.
@onready var camera : Camera2D = $Camera
## The player's collision.
@onready var collision : CollisionShape2D = $Collision
## The character sprite.
@onready var sprite : AnimatedSprite2D = $Sprite

##
# Movement Physics
##

var acceleration : float = 2
var deceleration : float = 10
var facing_direction : float = 1
var maximum_speed : float = 400
var speed : float

##
# Space Physics
##

## The direction to the closest planet.
var gravitational_direction : Vector2
## The gravitational force applied to the player.
var gravitational_force : float
## The minimum gravitational force before the player dies
var minimum_gravitational_force = 10
## Nearest planet to the player.
var planet : StaticBody2D

##
# States
##

## Returns true if the player is on the ground.
var grounded : bool
## Returns true if the player is jumping.
var jumped : bool

func _process(_delta):
	update_debug_info()

func _physics_process(delta):
	find_nearest_planet()
	
	calculate_gravity()
	
	set_direction()
	
	set_state()
	
	get_input()
	
	apply_movement()
	
	rotate_player(delta)
	
	# Apply gravity
	apply_gravity(delta)
	
	# Apply speed limit
	limit_velocity()
	
	# Apply velocity to the character
	move_and_slide()

func apply_gravity(delta : float):
	velocity += gravitational_force * gravitational_direction * delta

func apply_movement():
	if grounded:
		velocity += -up_direction.rotated(45 * -sign(speed)) * speed

func calculate_gravity():
	var player_mass = 32
	var planet_mass = planet.get_node("Collision").shape.radius
	gravitational_direction = global_position.direction_to(planet.global_position)
	gravitational_force = GRAVITY * (player_mass * planet_mass / pow(global_position.distance_to(planet.global_position), 2))

func get_input():
	# Player actions
	if grounded:
		if Input.is_action_pressed("player_move_left"):
			if speed > 0:
				speed -= deceleration
				if speed <= 0:
					speed = -0.5
			elif speed > -maximum_speed:
				speed -= acceleration
				if speed <= -maximum_speed:
					speed = -maximum_speed
		elif Input.is_action_pressed("player_move_right"):
			if speed < 0:
				speed += deceleration
				if speed >= 0:
					speed = 0.5
			elif speed < maximum_speed:
				speed += acceleration
				if speed >= maximum_speed:
					speed = maximum_speed
		else: speed -= min(abs(speed), acceleration) * sign(speed)
		if Input.is_action_just_pressed("player_jump") and !jumped:
			jumped = true
			velocity += JUMP_VELOCITY * -gravitational_direction
	
	# Game-related actions
	if Input.is_action_just_pressed("game_reset"):
		reset_player()

# Updates debug information
func update_debug_info():
	if show_debug:
		$HUD/Debug.visible = true
		$HUD/Debug/Margin/List/Distance.text = "Distance to Nearest Planet: " + str(round(planet.global_position.distance_to(global_position)))
		$"HUD/Debug/Margin/List/Gravitational Force".text = "Gravitational Force: " + str(round(gravitational_force))
		$HUD/Debug/Margin/List/Planet.text = "Nearest Planet: " + str(planet.name)
		$HUD/Debug/Margin/List/Velocity.text = "Velocity: " + str(velocity.round())
		$HUD/Debug/Margin/List/Grounded.button_pressed = grounded
		$HUD/Debug/Margin/List/Jumping.button_pressed = jumped
	else: $HUD/Debug.visible = false

# Find the nearest planet
func find_nearest_planet():
	# All planets in the current stage
	var planets = get_tree().get_nodes_in_group("Planets")
	
	# Set nearest planet as the first
	planet = planets[0]
	
	# Find nearest planet of all planets in the stage
	for current_planet in planets:
		if current_planet.global_position.distance_to(global_position) < planet.global_position.distance_to(global_position):
			planet = current_planet

func limit_velocity():
	velocity.x = clamp(velocity.x, -maximum_speed, maximum_speed)
	velocity.y = clamp(velocity.y, -maximum_speed, maximum_speed)

func reset_player():
	gravitational_direction = Vector2.ZERO
	gravitational_force = 0
	grounded = false
	jumped = false
	position = Vector2.ZERO
	speed = 0
	velocity = Vector2.ZERO

func rotate_player(delta : float):
	camera.rotating = camera_rotation
	camera.smoothing_enabled = smooth_rotation
	camera.rotation = lerp_angle(camera.rotation, gravitational_direction.angle() - PI/2, delta * 8) if smooth_rotation else gravitational_direction.angle() - PI/2
	collision.rotation = gravitational_direction.angle() - PI/2
	sprite.rotation = lerp_angle(sprite.rotation, gravitational_direction.angle() - PI/2, delta * 8) if smooth_rotation else gravitational_direction.angle() - PI/2

func set_direction():
	up_direction = -gravitational_direction

func set_state():
	if is_on_floor():
		grounded = true
		jumped = false
		velocity = Vector2.ZERO
	else:
		grounded = false
		if gravitational_force < minimum_gravitational_force:
			reset_player()
