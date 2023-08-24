extends Control

export(NodePath) var list_path

var list : GridContainer

func _ready():
	list = get_node(list_path)

func _process(_delta):
	pass

func reset_vehicle_list():
	var vehicle_nodes = get_tree().get_nodes_in_group("Vehicles")
	for entry in list.get_children():
		entry.queue_free()
	for vehicle in vehicle_nodes:
		var button = Button.new()
		button.name = vehicle.name
		button.text = vehicle.name
		button.connect("button_down", self, "_on_vehicle_selected", [vehicle])
		list.add_child(button)

func _on_vehicle_selected(vehicle : Node):
	Game.player.set_vehicle(vehicle)
