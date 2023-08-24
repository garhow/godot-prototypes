extends Node

# Node paths
export(NodePath) var camera_path
export(NodePath) var camera_root_path
export(NodePath) var user_interface_path

# Nodes
var camera : Camera
var camera_root : Spatial
var user_interface : Control
var current_vehicle : VehicleBody

func _ready():
	Game.player = self
	camera = get_node(camera_path)
	camera_root = get_node(camera_root_path)
	user_interface = get_node(user_interface_path)
	user_interface.reset_vehicle_list()

func _physics_process(delta):
	if Input.is_action_just_pressed("pause"):
		spawn_vehicle()
	if current_vehicle:
		camera_root.rotation.y = lerp_angle(camera_root.rotation.y, current_vehicle.rotation.y, 10 * delta)
		camera_root.translation = lerp(camera_root.translation, current_vehicle.translation, 10 * delta)

func set_vehicle(vehicle : VehicleBody):
	current_vehicle = vehicle

func spawn_vehicle():
	add_child(load("res://scenes/vehicles/racecar.tscn").instance(), true)
	user_interface.reset_vehicle_list()
