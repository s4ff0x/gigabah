extends Node

const PORT: int = 25445

var peer: ENetMultiplayerPeer
const ADDRESS: String = "51.250.122.114"

## Signals
signal player_joined(peer_id: int)
signal player_left(peer_id: int)

## Constants
const PLAYER_SCENE: PackedScene = preload("res://scenes/player.tscn")

func _ready() -> void:
	if OS.has_feature("dedicated_server"):
		Engine.max_fps = 60
		start_server()
	elif OS.has_feature("client"):
		start_client(ADDRESS)
	else:
		start_client("127.0.0.1")

## Start as server
func start_server() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	print("Server started on port %d" % PORT)

## Start as client
func start_client(address: String) -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_client(address, PORT)
	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	print("Connecting to %s:%d..." % [address, PORT])

## Player connection handlers
func _on_peer_connected(id: int) -> void:
	if multiplayer.is_server():
		var spawner: MultiplayerSpawner = get_tree().current_scene.get_node("MultiplayerSpawner")
		spawner.spawn(id)
		emit_signal("player_joined", id)

func _on_peer_disconnected(id: int) -> void:
	emit_signal("player_left", id)

## Client connection handlers
func _on_connected_to_server() -> void:
	print("Connected to server.")

func _on_connection_failed() -> void:
	print("Failed to connect to server.")

func _on_server_disconnected() -> void:
	print("Disconnected from server.") 
