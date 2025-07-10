@tool

extends NetworkComponent
class_name NetworkPosition

var parent: CharacterBody3D

@export var server_position: Vector3 = Vector3.ZERO

@export var enable_interpolation: bool = true
@export var interpolation_speed: float = 18.0

func _enter_tree() -> void:
	pass
	

func _validate_property(_property: Dictionary) -> void:
	replication_config.add_property(^":server_position")
	replication_config.property_set_replication_mode(^":server_position", SceneReplicationConfig.REPLICATION_MODE_ALWAYS)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent = get_parent() as CharacterBody3D
	if parent != null:
		server_position = parent.position
	else:
		printerr("NetworkPosition: Parent is null")
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta: float) -> void:
	# if !multiplayer.is_server():
	# 	parent.position = parent.position.lerp(server_position, clamp(interpolation_speed * delta, 0, 1))

func _physics_process(delta: float) -> void:
	# Only the server moves the player
	if multiplayer.is_server():
		parent.move_and_slide()
		server_position = parent.position
	else:
		parent.position = parent.position.lerp(server_position, clamp(interpolation_speed * delta, 0, 1))
