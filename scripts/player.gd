extends CharacterBody2D
class_name Player

## Movement parameters
@export var camera: Camera2D
@export var speed: float = 400.0

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())
	if name.to_int() != multiplayer.get_unique_id():
		camera.enabled = false

func _physics_process(_delta: float) -> void:
	if !is_multiplayer_authority(): return

	velocity = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down") * speed
	move_and_slide()
