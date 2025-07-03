extends Node

# HealthSystem: ECS-style system for handling health logic

func _process(_delta: float) -> void:
	var health_components: Array[Node] = get_tree().get_nodes_in_group("health_components")

	for health: Node in health_components:
		if health.current_health <= 0:
			# Remove the entity (parent node) if health is depleted
			if is_instance_valid(health.get_parent()):
				health.get_parent().queue_free() 