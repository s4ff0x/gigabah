extends CharacterBody2D
class_name Player

## Movement parameters
@export var camera: Camera2D
@export var speed: float = 400.0
@export var move_direction: Vector2 = Vector2.ZERO

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())
	if name.to_int() != multiplayer.get_unique_id():
		camera.enabled = false

func _physics_process(_delta: float) -> void:
	if is_multiplayer_authority():
		move_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	velocity = move_direction * speed
	move_and_slide()
