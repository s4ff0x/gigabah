extends CharacterBody2D
class_name Player

## Movement parameters
@export var speed: float = 200.0

## Internal state
var input_vector: Vector2 = Vector2.ZERO

func _ready() -> void:
	set_physics_process(multiplayer.is_server())

func _unhandled_input(_event: InputEvent) -> void:
	if multiplayer_is_authority() and not multiplayer.is_server():
		var dir: Vector2 = Vector2.ZERO
		if Input.is_action_pressed("ui_right"):
			dir.x += 1
		if Input.is_action_pressed("ui_left"):
			dir.x -= 1
		if Input.is_action_pressed("ui_down"):
			dir.y += 1
		if Input.is_action_pressed("ui_up"):
			dir.y -= 1
		dir = dir.normalized()
		if dir != input_vector:
			input_vector = dir
			_rpc_send_input(input_vector)

@rpc("any_peer")
func _rpc_send_input(dir: Vector2) -> void:
	if multiplayer.is_server():
		input_vector = dir

func _physics_process(_delta: float) -> void:
	if multiplayer.is_server():
		velocity = input_vector * speed
		move_and_slide()
		_rpc_sync_position(global_position)

@rpc("call_local")
func _rpc_sync_position(pos: Vector2) -> void:
	if not multiplayer.is_server():
		global_position = pos

func multiplayer_is_authority() -> bool:
	return multiplayer.get_unique_id() == get_multiplayer_authority()
