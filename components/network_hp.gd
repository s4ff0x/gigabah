extends MultiplayerSynchronizer
class_name NetworkHP

@export var max_health: int = 100
@export var current_health: int = max_health

func _enter_tree() -> void:
	set_multiplayer_authority(1)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
