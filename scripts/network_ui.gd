extends Control
class_name NetworkUI

@export var address_input: LineEdit
@export var status_label: Label


func _on_host_button_pressed() -> void:
	NetworkManager.start_server()
	status_label.text = "Hosting..."
	hide()


func _on_join_button_pressed() -> void:
	var address: String = address_input.text.strip_edges()
	NetworkManager.start_client(address)
	status_label.text = "Joining..."
	hide()
