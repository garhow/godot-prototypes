extends Node3D

func _ready():
	var chunk: Chunk = Chunk.new()
	chunk.make_mesh()
