class_name Road extends Node3D

@export var left_path: Path3D
@export var right_path: Path3D
@export var spawn_vehicle: bool = false
@export var spawn_vehicle_count: int = 1

func _ready():
	if spawn_vehicle:
		var areas := []
		var paths := []
		for child in get_children():
			if child is Area3D: areas.append(child)
		if areas.size() > 0:
			for area in areas:
				for child in area.get_children():
					if child is Path3D: paths.append(child)
		if paths.size() > 0:
			var spawn_path: Path3D = paths[randi_range(0, paths.size() - 1)]
			for i in spawn_vehicle_count:
				add_vehicle(spawn_path)

func add_vehicle(parent: Path3D):
	var vehicles = [
		"res://vehicles/Ambulance.tscn",
		"res://vehicles/Luxury SUV.tscn",
		"res://vehicles/Police.tscn",
		"res://vehicles/Sedan.tscn",
		"res://vehicles/SUV.tscn",
		"res://vehicles/Taxi.tscn",
	]
	var vehicle = load("res://vehicles/Sedan.tscn").instantiate() # load(vehicles[randi_range(0, vehicles.size() - 1)]).instantiate()
	parent.add_child(vehicle)
