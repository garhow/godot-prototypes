class_name Chunk extends Node

var array := []

var position: Vector3i
var region: Vector2i

func add_cell(position: Vector3i):
	array.append(position)
	#print(array)

