extends Node2D

@export var button: Button
@export var clap: AudioStreamPlayer
@export var time_label: Label
@export var colory: ColorRect
@export var particles: PackedScene
@export var otherparticles: CPUParticles2D

var bpm : float = 124
var beats : bool = false
var default_time : float = 60 / bpm
var time_elapsed : float = default_time

func _ready():
	button.button_down.connect(_on_pressed)
	var prebeat = Timer.new()
	add_child(prebeat)
	prebeat.wait_time = 0.7
	prebeat.start()
	prebeat.timeout.connect(_enable_beats)

func _on_pressed():
	if beats:
		clap.play()
		if time_elapsed <= 0.1 or time_elapsed >= default_time - 0.1:
			colory.color = Color.GREEN
			#var par = particles.instantiate()
			#add_child(par)
			otherparticles.emitting = true
		else:
			colory.color = Color.RED

func _enable_beats():
	beats = true

func _process(delta):
	if beats:
		time_elapsed -= delta
		time_label.text = str(snapped(time_elapsed, 0.1))
		if time_elapsed <= 0:
			time_elapsed = default_time
