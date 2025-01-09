extends Node2D

@export_category("Grid Spawner")
@export var grid_size: int = 3
@export_range(1, 10) var block_size: int = 10
@export var padding_px: int = 10

@export_category("Game Settings")
@export var update_interval: int = 3

@onready var block_preload = preload("res://scenes/presets/grid_block.tscn")

var block_states: Array[bool]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var window_width: int = DisplayServer.screen_get_size().x
	var grid_midpoint: int = (block_size * 10 + padding_px) * grid_size / 2.0
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
			add_child(block)
			block_states.append(false)
			
	$"Simulate Next Step".start(update_interval)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
# Simulation Update
func _on_simulate_next_step() -> void:
	print("Sim")
	pass
