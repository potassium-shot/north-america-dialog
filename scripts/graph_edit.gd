extends GraphEdit

const DialogGraphNode = preload("res://scripts/dialog_node.gd")
const EntryGraphNode = preload("res://scripts/dialog_entry_node.gd")
const EventGraphNode = preload("res://scripts/dialog_event_node.gd")

@onready var context_menu: PopupMenu = %ContextMenu

var nodes: Array[GraphNode]
var selected_nodes: Dictionary # {Node: null}

func _enter_tree():
	Root.project_changed.connect(_on_root_project_changed)

func _gui_input(p_event: InputEvent):
	var button_event: InputEventMouseButton = p_event as InputEventMouseButton
	
	if button_event:
		if button_event.button_index == MOUSE_BUTTON_RIGHT and not button_event.pressed:
			context_menu.position = get_local_mouse_position()
			context_menu.popup()
		elif button_event.button_index == MOUSE_BUTTON_LEFT and not button_event.pressed:
			if Input.is_action_pressed("quick_dialog"):
				new_dialog_node()
			elif Input.is_action_pressed("quick_entry"):
				new_entry_node()
			elif Input.is_action_pressed("quick_end"):
				new_end_node()
			elif Input.is_action_pressed("quick_event"):
				new_event_node()

func _on_root_project_changed(p_new_project: DialogTree):
	for node in nodes:
		node.queue_free()
	
	nodes.clear()
	clear_connections()
	
	for node in p_new_project._nodes.values():
		if node is DialogNode:
			var graph_node = spawn_dialog_node_at(node.position, node)
			graph_node.size = node.size
		elif node is DialogEntry:
			spawn_entry_node_at(node.position, node)
		elif node is DialogEnd:
			spawn_end_node_at(node.position, node)
		elif node is DialogEvent:
			spawn_event_node_at(node.position, node)
	
	for node in nodes:
		if node is DialogGraphNode:
			if node.node_resource.option_count == 0:
				if node.node_resource.optionless_connection_id:
					var connect_to: DialogTreeNode\
						= Root.current_project.get_node(node.node_resource.optionless_connection_id)
					connect_node(
							node.name,
							0,
							connect_to.graph_node.name,
							0,
						)
					connect_to.back_connected_nodes[node.node_resource.node_id] = 0
			else:
				for i in range(node.node_resource.option_count):
					var option: DialogOption = node.node_resource.get_option(i)
					
					if option.connection_id:
						var connect_to: DialogTreeNode = Root.current_project.get_node(option.connection_id)
						connect_node(
							node.name,
							i,
							connect_to.graph_node.name,
							0,
						)
						connect_to.back_connected_nodes[node.node_resource.node_id] = i
		elif node is EntryGraphNode or node is EventGraphNode:
			if node.node_resource.connection_id:
				var connect_to: DialogTreeNode = Root.current_project.get_node(node.node_resource.connection_id)
				connect_node(
					node.name,
					0,
					connect_to.graph_node.name,
					0,
				)
				connect_to.back_connected_nodes[node.node_resource.node_id] = 0

func _on_context_menu_id_pressed(p_id: int):
	context_menu.visible = false
	
	match p_id:
		0:
			new_dialog_node()
		
		1:
			new_entry_node()
		
		2:
			new_end_node()
		
		3:
			new_event_node()

func spawn_dialog_node_at(p_position: Vector2, p_dialog_node: DialogNode) -> GraphNode:
	var node: GraphNode = preload("res://scenes/dialog_node.tscn").instantiate()
	p_dialog_node.graph_node = node
	node.node_resource = p_dialog_node
	add_child(node)
	node.position_offset = p_position
	nodes.push_back(node)
	return node

func spawn_entry_node_at(p_position: Vector2, p_entry_node: DialogEntry) -> GraphNode:
	var node: GraphNode = preload("res://scenes/dialog_entry_node.tscn").instantiate()
	p_entry_node.graph_node = node
	node.node_resource = p_entry_node
	add_child(node)
	node.position_offset = p_position
	nodes.push_back(node)
	return node

func spawn_end_node_at(p_position: Vector2, p_end_node: DialogEnd) -> GraphNode:
	var node: GraphNode = preload("res://scenes/dialog_end_node.tscn").instantiate()
	p_end_node.graph_node = node
	node.node_resource = p_end_node
	add_child(node)
	node.position_offset = p_position
	nodes.push_back(node)
	return node

func spawn_event_node_at(p_position: Vector2, p_event_node: DialogEvent) -> GraphNode:
	var node: GraphNode = preload("res://scenes/dialog_event_node.tscn").instantiate()
	p_event_node.graph_node = node
	node.node_resource = p_event_node
	add_child(node)
	node.position_offset = p_position
	nodes.push_back(node)
	return node

func new_dialog_node() -> GraphNode:
	var id: int = Root.get_new_id()
	var dialog_node: DialogNode = DialogNode.new()
	dialog_node.node_id = id
	Root.current_project.push_node(dialog_node)
	
	var node: GraphNode = spawn_dialog_node_at(_get_mouse_position_offset(), dialog_node)
	node.position_offset.x = snap(node.position_offset.x)
	node.position_offset.y = snap(node.position_offset.y)
	
	Root.mark_modified()
	return node

func new_entry_node() -> GraphNode:
	var id: int = Root.get_new_id()
	var entry_node: DialogEntry = DialogEntry.new()
	entry_node.node_id = id
	Root.current_project.push_node(entry_node)
	
	var node: GraphNode = spawn_entry_node_at(_get_mouse_position_offset(), entry_node)
	node.position_offset.x = snap(node.position_offset.x)
	node.position_offset.y = snap(node.position_offset.y)
	
	Root.mark_modified()
	return node

func new_end_node() -> GraphNode:
	var id: int = Root.get_new_id()
	var end_node: DialogEnd = DialogEnd.new()
	end_node.node_id = id
	Root.current_project.push_node(end_node)
	
	var node: GraphNode = spawn_end_node_at(_get_mouse_position_offset(), end_node)
	node.position_offset.x = snap(node.position_offset.x)
	node.position_offset.y = snap(node.position_offset.y)
	
	Root.mark_modified()
	return node

func new_event_node() -> GraphNode:
	var id: int = Root.get_new_id()
	var event_node: DialogEvent = DialogEvent.new()
	event_node.node_id = id
	Root.current_project.push_node(event_node)
	
	var node: GraphNode = spawn_event_node_at(_get_mouse_position_offset(), event_node)
	node.position_offset.x = snap(node.position_offset.x)
	node.position_offset.y = snap(node.position_offset.y)
	
	Root.mark_modified()
	return node

func remove_node(p_node: GraphNode):
	var node_resource: DialogTreeNode = p_node.node_resource
	
	if node_resource is DialogNode:
		if node_resource.option_count == 0:
			if node_resource.optionless_connection_id:
				var other: DialogTreeNode = Root.current_project.get_node(node_resource.optionless_connection_id)
				other.back_connected_nodes.erase(
						node_resource.node_id
					)
				disconnect_node(
					p_node.name,
					0,
					other.graph_node.name,
					0,
				)
		else:
			for option in node_resource._options:
				if option.connection_id:
					var other: DialogTreeNode = Root.current_project.get_node(option.connection_id)
					other.back_connected_nodes.erase(
						node_resource.node_id
					)
					disconnect_node(
						p_node.name,
						0,
						other.graph_node.name,
						0,
					)
	elif node_resource is DialogEntry or node_resource is DialogEvent:
		if node_resource.connection_id:
			var other: DialogTreeNode = Root.current_project.get_node(node_resource.connection_id)
			other.back_connected_nodes.erase(
				node_resource.node_id
			)
			disconnect_node(
				p_node.name,
				0,
				other.graph_node.name,
				0,
			)
	
	for connection in node_resource.back_connected_nodes:
		var port = node_resource.back_connected_nodes[connection]
		var connected_node: DialogTreeNode = Root.current_project.get_node(connection)
		
		disconnect_node(
			connected_node.graph_node.name,
			port,
			p_node.name,
			0,
		)
		
		if connected_node is DialogNode:
			if connected_node.option_count == 0:
				if connected_node.optionless_connection_id == node_resource.node_id:
					connected_node.optionless_connection_id = 0
			else:
				for option: DialogOption in connected_node._options:
					if option.connection_id == node_resource.node_id:
						option.connection_id = 0
						break
		elif connected_node is DialogEntry or connected_node is DialogEvent:
			if connected_node.connection_id == node_resource.node_id:
				connected_node.connection_id = 0
	
	Root.current_project.remove_node(node_resource.node_id)
	nodes.erase(p_node)
	selected_nodes.erase(p_node)
	p_node.queue_free()
	Root.mark_modified()

func snap(i: float) -> float:
	if snapping_enabled:
		return roundf(i / snapping_distance) * snapping_distance
	else:
		return i

func _on_delete_nodes_request(p_nodes: Array[StringName]):
	for node in p_nodes:
		remove_node(get_node(NodePath(node)))

func _on_connection_request(
	p_from_node: StringName,
	p_from_port: int,
	p_to_node: StringName,
	p_to_port: int,
):
	var undo_redo: UndoRedo = Root.current_project.undo_redo
	
	undo_redo.create_action("Connect Nodes")
	
	undo_redo.add_do_method(
		perform_connection.bind(p_from_node, p_from_port, p_to_node, p_to_port)
	)
	
	undo_redo.add_undo_method(
		perform_disconnection.bind(p_from_node, p_from_port, p_to_node, p_to_port)
	)
	
	undo_redo.commit_action()

func perform_connection(
	p_from_node: StringName,
	p_from_port: int,
	p_to_node: StringName,
	p_to_port: int,
):
	var from_node: GraphNode = get_node(NodePath(p_from_node))
	var to_node: GraphNode = get_node(NodePath(p_to_node))
	
	if from_node is DialogGraphNode:
		if from_node.node_resource.option_count == 0:
			if from_node.node_resource.optionless_connection_id:
				_on_disconnection_request(
					p_from_node,
					p_from_port,
					Root
						.current_project.get_node(from_node.node_resource.optionless_connection_id)
						.graph_node
						.name,
					0,
				)
			
			from_node.node_resource.optionless_connection_id = to_node.node_resource.node_id
		else:
			var current_connection: int = from_node.node_resource.get_option(p_from_port).connection_id
			
			if current_connection:
				_on_disconnection_request(
					p_from_node,
					p_from_port,
					Root
						.current_project.get_node(current_connection)
						.graph_node
						.name,
					0,
				)
			
			from_node.node_resource.get_option(p_from_port).connection_id = to_node.node_resource.node_id
	elif from_node is EntryGraphNode:
		if from_node.node_resource.connection_id:
			_on_disconnection_request(
				p_from_node,
				p_from_port,
				Root
					.current_project.get_node(from_node.node_resource.connection_id)
					.graph_node
					.name,
				0,
			)
		
		from_node.node_resource.connection_id = to_node.node_resource.node_id
	elif from_node is EventGraphNode:
		if from_node.node_resource.connection_id:
			_on_disconnection_request(
				p_from_node,
				p_from_port,
				Root
					.current_project.get_node(from_node.node_resource.connection_id)
					.graph_node
					.name,
				0,
			)
		
		from_node.node_resource.connection_id = to_node.node_resource.node_id
	
	to_node.node_resource.back_connected_nodes[from_node.node_resource.node_id] = p_from_port
	
	connect_node(
		p_from_node,
		p_from_port,
		p_to_node,
		p_to_port,
	)

func _on_disconnection_request(
	p_from_node: StringName,
	p_from_port: int,
	p_to_node: StringName,
	p_to_port: int,
):
	var undo_redo: UndoRedo = Root.current_project.undo_redo
	
	undo_redo.create_action("Disonnect Nodes")
	
	undo_redo.add_do_method(
		perform_disconnection.bind(p_from_node, p_from_port, p_to_node, p_to_port)
	)
	
	undo_redo.add_undo_method(
		perform_connection.bind(p_from_node, p_from_port, p_to_node, p_to_port)
	)
	
	undo_redo.commit_action()

func perform_disconnection(
	p_from_node: StringName,
	p_from_port: int,
	p_to_node: StringName,
	p_to_port: int,
):
	var from_node: GraphNode = get_node(NodePath(p_from_node))
	var to_node: GraphNode = get_node(NodePath(p_to_node))
	
	if from_node is DialogGraphNode:
		if from_node.node_resource.option_count == 0:
			from_node.node_resource.optionless_connection_id = 0
		else:
			from_node.node_resource.get_option(p_from_port).connection_id = 0
	elif from_node is EntryGraphNode:
		from_node.node_resource.connection_id = 0
	elif from_node is EventGraphNode:
		from_node.node_resource.connection_id = 0
	
	to_node.node_resource.back_connected_nodes.erase(from_node.node_resource.node_id)
	
	disconnect_node(
		p_from_node,
		p_from_port,
		p_to_node,
		p_to_port,
	)

func _get_mouse_position_offset() -> Vector2:
	return (scroll_offset + get_local_mouse_position()) / zoom

func _on_end_node_move():
	Root.mark_modified()

func _on_node_selected(p_node: Node):
	selected_nodes[p_node] = null

func _on_node_deselected(p_node: Node):
	selected_nodes.erase(p_node)

func _on_copy_nodes_request():
	DisplayServer.clipboard_set(
		JSON.stringify(selected_nodes.keys().map(func(n): return [
				n.node_resource.get_script().get_path(),
				n.node_resource.to_dictionary(),
			]))
	)

func _on_paste_nodes_request():
	var parsed_json: Variant = JSON.parse_string(DisplayServer.clipboard_get())
	
	if parsed_json != null:
		for element in parsed_json:
			if parsed_json != null and element is Array:
				var node: GraphNode
				
				match element[0]:
					"res://scripts/save/dialog_node.gd":
						node = new_dialog_node()
						node.node_resource.from_dictionary(element[1], [
							&"lines",
							&"options",
							&"speaker",
						])
						node.node_resource = node.node_resource
					
					"res://scripts/save/dialog_entry.gd":
						node = new_entry_node()
						node.node_resource.from_dictionary(element[1], [
							&"entry_name",
						])
						node.node_resource = node.node_resource
					
					"res://scripts/save/dialog_end.gd":
						new_end_node()
					
					"res://scripts/save/dialog_event.gd":
						node = new_event_node()
						node.node_resource.from_dictionary(element[1], [
							&"event_name",
						])
						node.node_resource = node.node_resource

func _on_duplicate_nodes_request():
	for node in selected_nodes:
		var node_resource = node.node_resource
		var new_node: GraphNode
		var new_node_resource: DialogTreeNode
		
		if node_resource is DialogNode:
			new_node = new_dialog_node()
			new_node_resource = new_node.node_resource
			new_node_resource.lines = node_resource.lines.duplicate()
			
			for option: DialogOption in node_resource._options:
				var new_option: DialogOption = DialogOption.new()
				new_option.text = option.text
				new_node_resource.push_option(new_option)
		
		elif node_resource is DialogEntry:
			new_node = new_entry_node()
			new_node_resource = new_node.node_resource
			new_node_resource.entry_name = node_resource.entry_name
		elif node_resource is DialogEnd:
			new_node = new_end_node()
			new_node_resource = new_node.node_resource
		elif node_resource is DialogEvent:
			new_node = new_event_node()
			new_node_resource = new_node.node_resource
			new_node_resource.event_name = node_resource.event_name
		
		new_node.node_resource = new_node_resource
