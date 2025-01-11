extends Node2D

@export_category("Grid Spawner")
@export var grid_size: int = 3
@export_range(1, 10) var block_size: int = 10
@export var padding_px: int = 10

@export_category("Game Settings")
@export var update_interval: int = 3
@export var sim_timer_text: Label
@export var show_time_decimals: bool = false
@export var enemy_drop_interval: int = 1
@export var enemy_spawn_sim_time: int = 5

@export_category("Game State")
@export var life_points: int = 10
@export var life_points_text: Label

@onready var block_preload = preload("res://scenes/presets/grid_block.tscn")

# var block_states: Array[bool]
var sim_steps: int = 0

var _blocks_child_idx_offset: int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_blocks_child_idx_offset = get_child_count()
	
	var grid_midpoint: int = round((block_size * 10 + padding_px) * grid_size / 2.0)
	position.x = (640 - (182.5 * grid_size/15)) - (grid_midpoint / 2.0)
	position.y = position.x
	
	var block_pos: Vector2 = Vector2.ZERO
	var block_num: int = 0
	for x in grid_size:
		block_pos.x = (x * ((block_size * 10) + padding_px))
		for y in grid_size:
			block_pos.y = (y * ((block_size * 10) + padding_px))
			var block: Node = block_preload.instantiate()
			block.position = block_pos
			block.scale.x = block_size
			block.scale.y = block_size
			block.name = str(block_num)
			block_num += 1
			block.get_node("Area2D").block_state_toggled.connect(_on_block_state_changed)
			add_child(block)
			# block_states.append(false)
			
	$"Simulate Next Step".start(update_interval)
	$"Enemy Drop".start(enemy_drop_interval)
	get_node("../")
	pass

# Process input
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("next_sim_step"):
		$"Simulate Next Step".stop()
		$"Simulate Next Step".emit_signal("timeout")
		$"Simulate Next Step".start()
		print("Skipped to next step")
	if event.is_action_pressed("harvest_all"):
		$"Simulate Next Step".paused = true
		harvest_all_blocks()
		$"Simulate Next Step".paused = false
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var time_left: String = ""
	if show_time_decimals:
		time_left = str(floor($"Simulate Next Step".time_left*100)/100.0)
	else:
		time_left = str(ceil($"Simulate Next Step".time_left))
	sim_timer_text.text = "Next Sim In: " + time_left + "s"
	
	life_points_text.text = "LP: " + str(life_points)
	pass
	
# Simulation Update
func _on_simulate_next_step() -> void:
	print("Running Sim Step")
	sim_steps += 1
	var old_block_states: Array[bool]
	var new_block_states: Array[bool]
	# Set up state arrays
	for i in range(grid_size*grid_size):
		new_block_states.append(false)
		old_block_states.append(get_block_node(i).is_alive)
	for x in range(grid_size):
		for y in range(grid_size):
			var num: int = get_block_idx_from_2d(x, y)
			var is_alive: bool = get_block_node(num).is_alive
			var neighbor_count: int = get_cell_neighbors(num, old_block_states)
			
			# ignore enemy blocks
			if get_block_node(num).block_type != 0:
				continue
			
			# Alive rules
			if is_alive:
				# Underpopulation
				if (neighbor_count < 2):
					new_block_states[num] = false
					get_block_node(num).set_state(false)
					continue
				# Sustain
				if (neighbor_count == 2 || neighbor_count == 3):
					new_block_states[num] = true
					get_block_node(num).set_state(true)
					continue
				# Overpopulation
				if (neighbor_count > 3):
					new_block_states[num] = false
					get_block_node(num).set_state(false)
					continue
			# Dead rules
			else:
				# Reproduce
				if (neighbor_count == 3):
					new_block_states[num] = true
					get_block_node(num).set_state(true)
					continue
			new_block_states[num] = false;
	# block_states = new_block_states
	# Spawn enemy
	if (sim_steps % enemy_spawn_sim_time == 0):
		spawn_enemy_block()
		print("Spawning Enemy")
	pass
	
func spawn_enemy_block() -> void:
	var x: int = randi_range(0, grid_size-1)
	var block: Area2D = get_block_node(get_block_idx_from_2d(x, 0))
	# block_states[block.name.to_int()] = true
	block.set_state(true)
	block.block_type = 1
	pass
	
# Update Enemy blocks
func _enemy_blocks_update() -> void:
	var enemies_pos: Array[int]
	
	for x in range(grid_size):
		for y in range(grid_size):
			if (get_block_node(get_block_idx_from_2d(x, y)).block_type != 0):
				enemies_pos.append(get_block_idx_from_2d(x, y))
	
	for num in enemies_pos:
		var block: Area2D = get_block_node(num)
		if (block.block_type != 0):
			var coord: Vector2i = get_block_2d_from_idx(num)
			# Make sure block is not at bottom
			if (coord.y < grid_size-1):
				var new_y: int = coord.y + 1
				var new_block: Area2D = get_block_node(get_block_idx_from_2d(coord.x, new_y))
				# Check if bottom block is also enemy (stacking)
				if (new_block.block_type != 0):
					continue
				# block_states[num] = false
				block.set_state(false)
				# block_states[new_block.name.to_int()] = true
				new_block.set_state(true)
				new_block.block_type = 1
				print("move enemy down")
			else:
				print("enemy at bottom")
	pass
	
# Handles harvesting all live player cells
func harvest_all_blocks() -> void:
	for x in range(grid_size):
		for y in range(grid_size):
			var num: int = get_block_idx_from_2d(x, y)
			# Harvest only player blocks
			if (get_block_node(num).is_alive) && get_block_node(num).block_type==0:
				get_block_node(num).toggle_state()
	pass
	
# When a block's state is changed
func _on_block_state_changed(num: int, state: bool) -> void:
	# block_states[num] = state
	print(str(num) + ": " + str(state))
	pass
	
# Used for converting 2d index to 1d
func get_block_idx_from_2d(x: int, y: int) -> int:
	var idx: int = (grid_size * x) + y
	return idx
	
func get_block_2d_from_idx(idx: int) -> Vector2i:
	var pos2d: Vector2i = Vector2i.ZERO
	pos2d.x = floor(idx / (grid_size * 1.0))
	idx = idx % grid_size
	pos2d.y = idx
	return pos2d

# Calculate the how many neighbors are alive
func get_cell_neighbors(num: int, block_states: Array[bool]) -> int:
	var pos: Vector2i = get_block_2d_from_idx(num)
	var neighbors: int = 0
	for x in range(-1, 2):
		for y in range(-1, 2):
			# ignore the cell itself and enemies
			if (x == 0 && y == 0) || get_block_node(num).block_type != 0:
				continue
			# check if in range
			if (pos.x + x >= 0 && pos.y + y >= 0) and (pos.x + x < grid_size && pos.y + y < grid_size):
				# Check if neighbors is alive and ignore enemies
				if block_states[get_block_idx_from_2d(pos.x+x, pos.y+y)]:
					if get_block_node(get_block_idx_from_2d(pos.x+x, pos.y+y)).block_type == 0:
						neighbors += 1
	return neighbors
	
# Get block node by index
func get_block_node(num: int) -> Area2D:
	return get_child(num+_blocks_child_idx_offset).get_child(0)
