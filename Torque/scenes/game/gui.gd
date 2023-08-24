extends Control

export(NodePath) var list_path

var list : GridContainer

var vehicle_nodes

func _ready():
	list = get_node(list_path)

func _process(_delta):
	pass

func reset_vehicle_list():
	for entry in list.get_children():
		entry.queue_free()
	for vehicle in vehicle_nodes:
		var button = Button.new()
		button.name = vehicle.name
		button.text = vehicle.name
		button.connect("button_down", self, "_on_button_pressed")
		list.add_child(button)

func _on_button_pressed():
	
