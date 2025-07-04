extends MultiplayerSpawner

@export var player_scene: PackedScene


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	multiplayer.peer_connected.connect(spawn_player)
	multiplayer.peer_disconnected.connect(despawn_player)

func spawn_player(id: int) -> void:
	if !multiplayer.is_server(): return
	var player: Node = player_scene.instantiate()
	player.name = str(id)
	player.position = Vector2(randf_range(100, 500), randf_range(100, 500))
	get_node(spawn_path).call_deferred("add_child", player)

func despawn_player(id: int) -> void:
	if !multiplayer.is_server(): return
	var player: Node = get_node(spawn_path).get_node(str(id))
	if player:
		player.queue_free()