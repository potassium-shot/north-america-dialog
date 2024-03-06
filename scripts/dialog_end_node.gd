extends DialogGraphNodeBase

@export var node_resource: DialogEnd

func _on_dragged(p_from: Vector2, p_to: Vector2):
	if is_node_ready() and p_from != p_to:
		move_node(p_from, p_to)

func _update_position():
	node_resource.position = position_offset
