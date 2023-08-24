extends Camera3D

func _process(_delta):
	look_at(Vector3.ZERO, Vector3.UP)
	if Input.is_action_just_pressed("ui_down"):
		position.z -= 10
	if Input.is_action_just_pressed("ui_up"):
		position.z += 10
	if Input.is_action_just_pressed("ui_page_up"):
		position.y += 10
	if Input.is_action_just_pressed("ui_page_down"):
		position.y -= 10
	if Input.is_action_just_pressed("ui_left"):
		position.x += 10
	if Input.is_action_just_pressed("ui_right"):
		position.x -= 10
