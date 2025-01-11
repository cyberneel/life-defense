extends Area2D

enum BlockType {PLAYER = 0, ENEMY_NOR = 1, ENEMY_REP = 2}

@export_category("Grid Block")
@export var alive_color: Color = Color(1, 0, 0)
@export var enemy_color: Color = Color(0, 1, 0)
@export var dead_color: Color = Color(.25, .25, .25)
@export var hover_color: Color = Color(.5, .5, .5)
@export var player_cost: int = 1
@export var enemy_cost: int = 3

signal block_state_toggled(num: int, state: bool)

var is_alive: bool = false
var parentSprite: Sprite2D
var block_type: BlockType = BlockType.PLAYER
var grid_spawner: Node2D

var mouse_hover: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parentSprite = get_parent()
	grid_spawner = parentSprite.get_parent()
	update_state()
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_state()
	pass

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	#if (block_type == BlockType.PLAYER):
		if event.is_action_pressed("left_click"):
			toggle_state()
		
func toggle_state() -> void:
	if (!is_alive && grid_spawner.life_points <= 0):
		return
	if (is_alive && block_type != BlockType.PLAYER):
		if (grid_spawner.life_points < enemy_cost):
			return
	if (is_alive):
		if block_type == BlockType.PLAYER:
			grid_spawner.life_points += player_cost
		else:
			grid_spawner.life_points -= enemy_cost
	else:
		grid_spawner.life_points -= player_cost
	is_alive = !is_alive
	$CPUParticles2D.color_ramp.set_color(0, parentSprite.self_modulate)
	$CPUParticles2D.emitting = true
	update_state()
	emit_signal("block_state_toggled", parentSprite.name.to_int(), is_alive)
	
func set_state(new_state: bool) -> void:
	if (is_alive != new_state):
		is_alive = new_state
		$CPUParticles2D.color_ramp.set_color(0, parentSprite.self_modulate)
		$CPUParticles2D.emitting = true
		update_state()
	
func update_state() -> void:
	if (is_alive == false):
		block_type = BlockType.PLAYER
	var status_color: Color = (enemy_color if (block_type == BlockType.ENEMY_NOR) else alive_color) if is_alive else (hover_color if mouse_hover else dead_color)
	parentSprite.self_modulate = status_color
	if is_alive and mouse_hover:
		parentSprite.self_modulate = parentSprite.self_modulate.darkened(.4)

func _on_mouse_entered() -> void:
	if (block_type != BlockType.PLAYER && grid_spawner.life_points <= 3):
		return
	mouse_hover = true

func _on_mouse_exited() -> void:
	mouse_hover = false
