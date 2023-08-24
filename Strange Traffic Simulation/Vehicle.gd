class_name Vehicle extends PathFollow3D

@export var raycast: RayCast3D

var max_speed: float = 6
var min_speed: float = 1

var right_of_way: bool = true

@onready var speed: float = randf_range(min_speed, max_speed)

var current_speed: float

var new_path: Path3D

func _ready():
	raycast.target_position = Vector3(0, 0, 1) * 1

func _process(delta):
	raycast_check()
	if progress_ratio >= 1.0: on_end_reached()
	
	if right_of_way:
		current_speed = speed * delta
		progress += current_speed

func on_end_reached():
	var old_path = get_parent()
	old_path.remove_child(self)
	
	if new_path != null:
		new_path.add_child(self)
		progress_ratio = 0
	
func raycast_check():
	if raycast.is_colliding():
		if raycast.get_collider() is Area3D:
			var children = raycast.get_collider().get_children()
			var potential_paths := []
			
			for child in children:
				if child is Path3D and child != get_parent():
					potential_paths.append(child)
			
			if !potential_paths.is_empty():
				new_path = potential_paths[randi_range(0, potential_paths.size() - 1)]
		if raycast.get_collider() is StaticBody3D:
			if raycast.get_collider().collision_layer == 2:
				right_of_way = false
			else:
				right_of_way = true
