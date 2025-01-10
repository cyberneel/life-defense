extends Area2D

@export_category("Grid Block")
@export var alive_color: Color = Color(1, 0, 0)
@export var dead_color: Color = Color(.25, .25, .25)

signal block_state_toggled(num: int, state: bool)

var is_alive: bool = false
var parentSprite: Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parentSprite = get_parent()
	update_state()
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_state()
	pass

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("left_click"):
		toggle_state()
		
func toggle_state() -> void:
	is_alive = !is_alive
	update_state()
	emit_signal("block_state_toggled", parentSprite.name.to_int(), is_alive)
	
func update_state() -> void:
	var status_color: Color = alive_color if is_alive else dead_color
	parentSprite.self_modulate = status_color
