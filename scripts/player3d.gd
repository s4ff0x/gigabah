extends CharacterBody3D
class_name Player3D

## Movement parameters
@export var camera: Camera3D
@export var speed: float = 10
@export var move_direction: Vector2 = Vector2.ZERO

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())
	if name.to_int() == multiplayer.get_unique_id():
		camera.make_current()

func _physics_process(_delta: float) -> void:
	if is_multiplayer_authority():
		move_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	velocity.x = move_direction.x * speed
	velocity.z = move_direction.y * speed
	velocity.y = 0
	move_and_slide()
