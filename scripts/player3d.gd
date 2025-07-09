extends CharacterBody3D
class_name Player3D

## Movement parameters
@export var camera: Camera3D
@export var speed: float = 10
@export var move_direction: Vector2 = Vector2.ZERO
@export var replicated_position: Vector3 = Vector3.ZERO
@export var replicated_seq: int = 0

var _pending_input: Vector2 = Vector2.ZERO
@export var interpolation_speed: float = 25.0
var predicted_position: Vector3 = Vector3.ZERO
var last_input: Vector2 = Vector2.ZERO
const RECONCILE_THRESHOLD: float = 0.5

# Advanced reconciliation
var input_sequence: int = 0
var input_buffer: Array = [] # Array of {seq: int, input: Vector2, delta: float}
# Server-side: store the last processed input sequence number
var _pending_seq: int = 0

func _enter_tree() -> void:
	set_multiplayer_authority(1)
	if multiplayer.get_unique_id() == 1:
		return
	if name.to_int() == multiplayer.get_unique_id():
		camera.make_current()

func _ready() -> void:
	replicated_position = position
	predicted_position = position
	input_sequence = 0
	input_buffer.clear()

func _physics_process(_delta: float) -> void:
	var is_local_player : bool = name.to_int() == multiplayer.get_unique_id() and multiplayer.get_unique_id() != 1
	if is_local_player:
		# Local player: send input to server with sequence number and buffer it
		var input_vec: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		if input_vec != move_direction or input_buffer.is_empty():
			input_sequence += 1
			# Buffer input
			input_buffer.append({"seq": input_sequence, "input": input_vec})
			rpc_id(1, "receive_input", input_vec, input_sequence)
		last_input = input_vec
		# Predict movement locally
		_predict_movement(input_vec)
	# Only the server moves the player
	if multiplayer.is_server():
		_move_behaviour(_pending_input)
		replicated_position = position
		# Send back the last processed input sequence number
		replicated_seq = _pending_seq
	# Non-local clients: interpolate toward replicated position
	if !is_local_player and !multiplayer.is_server():
		position = position.lerp(replicated_position, clamp(interpolation_speed * _delta, 0, 1))

func _process(delta: float) -> void:
	var is_local_player : bool = name.to_int() == multiplayer.get_unique_id() and multiplayer.get_unique_id() != 1
	if !multiplayer.is_server():
		if is_local_player:
			# Advanced reconciliation: check for server correction
			if position.distance_to(replicated_position) > RECONCILE_THRESHOLD:
				# Snap to server position
				position = replicated_position
				predicted_position = replicated_position
				# Remove all acknowledged inputs
				_remove_acknowledged_inputs(replicated_seq)
				# Re-apply unacknowledged inputs
				for entry: Dictionary in input_buffer:
					_move_behaviour(entry["input"])
					predicted_position = position
				# Set position to latest prediction
				position = predicted_position
		else:
			# Other clients: interpolate
			position = position.lerp(replicated_position, clamp(interpolation_speed * delta, 0, 1))

# Called by the server to receive input and sequence number
@rpc("any_peer")
func receive_input(input_vec: Vector2, seq: int) -> void:
	if multiplayer.is_server():
		_pending_input = input_vec
		_pending_seq = seq

# Remove all acknowledged inputs from the buffer
func _remove_acknowledged_inputs(ack_seq: int) -> void:
	while !input_buffer.is_empty() and input_buffer[0]["seq"] <= ack_seq:
		input_buffer.pop_front()

# Predict local movement using the same logic as the server
func _predict_movement(input_vec: Vector2) -> void:
	_move_behaviour(input_vec)
	predicted_position = position

# Move logic, shared by server and prediction
func _move_behaviour(input_vec: Vector2) -> void:
	if input_vec.length() > 0:
		input_vec = input_vec.normalized()
	move_direction = input_vec
	velocity.x = move_direction.x * speed
	velocity.z = move_direction.y * speed
	velocity.y = 0
	move_and_slide()
