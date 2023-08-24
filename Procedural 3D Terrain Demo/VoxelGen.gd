extends GridMap

#const CHUNK_LIMIT: int = 32
const CHUNK_HEIGHT: int = 4
const CHUNK_SIZE: int = 64
const RENDER_DISTANCE: int = 4

var height_map = FastNoiseLite.new()
var moisture_map = FastNoiseLite.new()
var temperature_map = FastNoiseLite.new()

@export var player: CharacterBody3D

var loaded_chunks := []

const CELLS = {
	"air": 0,
	"stone": 1,
	"dirt": 2,
	"grass": 3,
	"sand": 4,
	"water": 5,
	"snow": 6,
}

func _ready():
	randomize()
	var world_seed = 0 #randi()
	
	height_map.seed = world_seed
	height_map.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	height_map.frequency = 1.0 / 64.0
	height_map.fractal_octaves = 4.0
	
	moisture_map.seed = world_seed
	moisture_map.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	
	temperature_map.seed = world_seed
	temperature_map.noise_type = FastNoiseLite.TYPE_PERLIN
	temperature_map.frequency = 1.0 / 256.0
	temperature_map.fractal_octaves = 3.0

func _process(_delta):
	var chunk_offset = CHUNK_SIZE
	generate_chunks(Vector3(
		snappedf(player.global_position.x, chunk_offset),
		0,
		snappedf(player.global_position.z, chunk_offset)
	))

func get_cell(pos: Vector3, height: float, land: float, moisture: float, temperature: float) -> int:
	if land > 0:
		if height > -0.05 and height < 0.05:
			return CELLS.air
		if temperature < -1:
			return CELLS.snow
		elif temperature > 1:
			return CELLS.sand
		return CELLS.grass
	elif land <= 0 and pos.y <= CHUNK_SIZE/2:
		return CELLS.air # CELLS.water
	return CELLS.air

func generate_chunks(player_position: Vector3):
	generate_chunk(player_position)
	if RENDER_DISTANCE >= 4:
		generate_chunk(player_position + Vector3(CHUNK_SIZE, 0, 0))
		generate_chunk(player_position + Vector3(-CHUNK_SIZE, 0, 0))
		generate_chunk(player_position + Vector3(0, 0, CHUNK_SIZE))
		generate_chunk(player_position + Vector3(0, 0, -CHUNK_SIZE))

func generate_chunk(player_position: Vector3):
	var chunk_loaded: bool
	
	var current_region := Vector2i(
		local_to_map(player_position).x,
		local_to_map(player_position).z
	) / CHUNK_SIZE
	
	for loaded_chunk in loaded_chunks:
		if loaded_chunk.position == local_to_map(player_position): chunk_loaded = true
	
	if !chunk_loaded:
		var chunk = Chunk.new()
		chunk.position = local_to_map(player_position)
		chunk.region = current_region
		print("Chunk " + str(chunk.region) + " loaded")
		for y in CHUNK_HEIGHT:
			for z in CHUNK_SIZE:
				for x in CHUNK_SIZE:
					var cell_pos = Vector3(
						chunk.position.x + x - CHUNK_SIZE/2,
						chunk.position.y + y,
						chunk.position.z + z - CHUNK_SIZE/2)
					var height = height_map.get_noise_3dv(cell_pos) * 1
					var land = height_map.get_noise_2d(cell_pos.x, cell_pos.z)
					var moisture = moisture_map.get_noise_2d(cell_pos.x, cell_pos.z)
					var temperature = temperature_map.get_noise_2d(cell_pos.x, cell_pos.z) * 10
					set_cell_item(cell_pos, get_cell(cell_pos, height, land, moisture, temperature))
					chunk.add_cell(cell_pos)
		loaded_chunks.append(chunk)
	
	# Delete old chunks
	#if loaded_chunks.size() > RENDER_DISTANCE + 1:
	#	var old_chunk: Chunk = loaded_chunks[0]
	#	for cell in old_chunk.array: set_cell_item(cell, -1)
	#	loaded_chunks.erase(old_chunk)
	
func clear_chunk(chunk: Chunk):
	for cell in chunk.array:
		set_cell_item(cell, -1)
	loaded_chunks.erase(chunk)	
