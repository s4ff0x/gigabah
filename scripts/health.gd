extends Node

class_name Health

@export var max_health: int = 100
@export var current_health: int = 100

func _ready() -> void:
	add_to_group("health_components")
	current_health = max_health

func take_damage(amount: int) -> void:
	"""Reduces health by the given amount."""
	current_health = max(current_health - amount, 0)

func heal(amount: int) -> void:
	"""Increases health by the given amount, up to max_health."""
	current_health = min(current_health + amount, max_health) 