extends Node
class_name NetworkManager

## Signals
signal player_joined(peer_id: int)
signal player_left(peer_id: int)

## Properties
var is_server: bool = false
var players: Dictionary = {}

## Constants
const PLAYER_SCENE: PackedScene = preload("res://scenes/player.tscn")

## Start as server
func start_server(port: int = 12345) -> void:
    var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
    peer.create_server(port)
    multiplayer.multiplayer_peer = peer
    is_server = true
    multiplayer.peer_connected.connect(_on_peer_connected)
    multiplayer.peer_disconnected.connect(_on_peer_disconnected)
    print("Server started on port %d" % port)

## Start as client
func start_client(address: String, port: int = 12345) -> void:
    var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
    peer.create_client(address, port)
    multiplayer.multiplayer_peer = peer
    is_server = false
    multiplayer.connected_to_server.connect(_on_connected_to_server)
    multiplayer.connection_failed.connect(_on_connection_failed)
    multiplayer.server_disconnected.connect(_on_server_disconnected)
    print("Connecting to %s:%d..." % [address, port])

## Player connection handlers
func _on_peer_connected(id: int) -> void:
    if is_server:
        _spawn_player(id)
        emit_signal("player_joined", id)

func _on_peer_disconnected(id: int) -> void:
    if is_server:
        _remove_player(id)
        emit_signal("player_left", id)

## Spawn player node
func _spawn_player(peer_id: int) -> void:
    var player: Node = PLAYER_SCENE.instantiate()
    player.name = "Player_%d" % peer_id
    player.set_multiplayer_authority(peer_id)
    get_tree().current_scene.add_child(player)
    players[peer_id] = player

## Remove player node
func _remove_player(peer_id: int) -> void:
    if players.has(peer_id):
        (players[peer_id] as Node).queue_free()
        players.erase(peer_id)

## Client connection handlers
func _on_connected_to_server() -> void:
    print("Connected to server.")

func _on_connection_failed() -> void:
    print("Failed to connect to server.")

func _on_server_disconnected() -> void:
    print("Disconnected from server.") 