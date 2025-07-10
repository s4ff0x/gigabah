extends CharacterBody3D
class_name Player3D

## Movement parameters
@export var camera: Camera3D
@export var speed: float = 10
@export var move_direction: Vector2 = Vector2.ZERO
@export var replicated_position: Vector3 = Vector3.ZERO

var _pending_input: Vector2 = Vector2.ZERO
@export var interpolation_speed: float = 16.0

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

func _physics_process(_delta: float) -> void:
	if multiplayer.get_unique_id() == name.to_int() and multiplayer.get_unique_id() != 1:
		# Client: send input to server
		var input_vec: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		if input_vec != move_direction:
			receive_input.rpc_id(1, input_vec)
	# Only the server moves the player
	if multiplayer.is_server():
		move_direction = _pending_input
		velocity.x = move_direction.x * speed
		velocity.z = move_direction.y * speed
		velocity.y = 0
		move_and_slide()
		replicated_position = position

func _process(delta: float) -> void:
	# Only interpolate on clients (not the server)
	if !multiplayer.is_server():
		position = position.lerp(replicated_position, clamp(interpolation_speed * delta, 0, 1))

@rpc("any_peer")
func receive_input(input_vec: Vector2) -> void:
	"""Called remotely by clients to send their input to the server."""
	if multiplayer.is_server():
		_pending_input = input_vec
