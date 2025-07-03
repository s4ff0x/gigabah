extends CanvasLayer
class_name NetworkUI

@onready var host_button: Button = $VBoxContainer/HostButton
@onready var join_button: Button = $VBoxContainer/JoinButton
@onready var address_input: LineEdit = $VBoxContainer/AddressInput
@onready var status_label: Label = $VBoxContainer/StatusLabel

func _ready() -> void:
	host_button.text = "Host Game"
	join_button.text = "Join Game"
	address_input.placeholder_text = "Server Address"
	address_input.text = "127.0.0.1"
	status_label.text = "Select mode"
	host_button.pressed.connect(_on_host_pressed)
	join_button.pressed.connect(_on_join_pressed)

func _on_host_pressed() -> void:
	var network_manager: Node = get_tree().current_scene.get_node_or_null("NetworkManager")
	if network_manager:
		network_manager.start_server()
		status_label.text = "Hosting..."
		hide()
	else:
		status_label.text = "NetworkManager not found!"

func _on_join_pressed() -> void:
	var network_manager: Node = get_tree().current_scene.get_node_or_null("NetworkManager")
	if network_manager:
		var address: String = address_input.text.strip_edges()
		network_manager.start_client(address)
		status_label.text = "Joining..."
		hide()
	else:
		status_label.text = "NetworkManager not found!" 
