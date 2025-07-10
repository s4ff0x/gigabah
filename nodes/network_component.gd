extends MultiplayerSynchronizer
class_name NetworkComponent


func _enter_tree() -> void:
	replication_interval = 0.05
	delta_interval = 0.02
	set_multiplayer_authority(1)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
