class_name DialogTreeNode extends Serializable

@export var node_id: int
@export var position: Vector2:
	set(value):
		position = value
		emit_changed()

var graph_node: GraphNode

## Dictionary {int: int} {node_id: connection_port}
var back_connected_nodes: Dictionary

func search(_p_text: String, _case_sensitive: bool) -> bool:
	return false
