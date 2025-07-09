extends CharacterBody3D
class_name Player3D

## Movement parameters
@export var camera: Camera3D
@export var speed: float = 10
@export var move_direction: Vector2 = Vector2.ZERO
@export var replicated_position: Vector3 = Vector3.ZERO

var _pending_input: Vector2 = Vector2.ZERO
@export var interpolation_speed: float = 25.0
var predicted_position: Vector3 = Vector3.ZERO
var last_input: Vector2 = Vector2.ZERO
const RECONCILE_THRESHOLD: float = 1.0

func _enter_tree() -> void:
	# Always set authority to server (ID 1)
	set_multiplayer_authority(1)
	if multiplayer.get_unique_id() == 1:
		# Server does not need to set camera
		return
	if name.to_int() == multiplayer.get_unique_id():
		camera.make_current()

func _ready() -> void:
	replicated_position = position
	predicted_position = position

func _physics_process(_delta: float) -> void:
	var is_local_player : bool= name.to_int() == multiplayer.get_unique_id() and multiplayer.get_unique_id() != 1
	if is_local_player:
		# Local player: send input to server and predict movement
		var input_vec: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		if input_vec != move_direction:
			rpc_id(1, "receive_input", input_vec)
		last_input = input_vec
		# Predict movement locally
		_predict_movement(input_vec)

	# Only the server moves the player
	if multiplayer.is_server():
		_move_behaviour(_pending_input)
		replicated_position = position

func _process(delta: float) -> void:
	# Only reconcile on local client player (not the server or remote players)
	var is_local_player : bool = name.to_int() == multiplayer.get_unique_id() and multiplayer.get_unique_id() != 1
	if !multiplayer.is_server():
		if is_local_player:
			if position.distance_to(replicated_position) > RECONCILE_THRESHOLD:
				position = replicated_position
				predicted_position = replicated_position
		else:
			# Only interpolate other clients
			position = position.lerp(replicated_position, clamp(interpolation_speed * delta, 0, 1))

func _predict_movement(input_vec: Vector2) -> void:
	_move_behaviour(input_vec)
	predicted_position = position

@rpc("any_peer")
func receive_input(input_vec: Vector2) -> void:
	"""Called remotely by clients to send their input to the server."""
	if multiplayer.is_server():
		_pending_input = input_vec

func _move_behaviour(input_vec: Vector2) -> void:
	move_direction = input_vec
	velocity.x = move_direction.x * speed
	velocity.z = move_direction.y * speed
	velocity.y = 0
	move_and_slide()
