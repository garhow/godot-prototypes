class_name Chunk extends Node

func make_mesh():
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var mesh = Mesh.new()
	var mesh_instance = MeshInstance3D.new()
	
	get_tree().root.call_deferred("add_child", mesh_instance)
