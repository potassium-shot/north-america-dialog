class_name DialogNode extends DialogTreeNode

@export var speaker: StringName:
	set(value):
		if value == speaker:
			return
		
		speaker = value
		emit_changed()

@export var _lines: Array[String]

@export var _options: Array[DialogOption]:
	set(value):
		_options = value
		
		for option in value:
			option.changed.connect(emit_changed)

@export var optionless_connection_id: int:
	set(value):
		if value == optionless_connection_id:
			return
		
		optionless_connection_id = value
		emit_changed()

@export var size: Vector2 = Vector2(400.0, 300.0):
	set(value):
		if value == size:
			return
		
		size = value
		emit_changed()

func push_line(p_line: String):
	_lines.push_back(p_line)
	emit_changed()

func insert_line(p_index: int, p_line: String):
	_lines.insert(p_index, p_line)
	emit_changed()

func remove_line(p_index: int):
	_lines.remove_at(p_index)
	emit_changed()

func set_line(p_index: int, p_line: String):
	if _lines[p_index] == p_line:
		return
	
	_lines[p_index] = p_line
	emit_changed()

var line_count: int:
	get:
		return len(_lines)

func get_line(p_index: int) -> String:
	return _lines[p_index]

func push_option(p_option: DialogOption):
	_options.push_back(p_option)
	p_option.changed.connect(emit_changed)
	emit_changed()

func insert_option(p_index: int, p_option: DialogOption):
	_options.insert(p_index, p_option)
	p_option.changed.connect(emit_changed)
	emit_changed()

func remove_option(p_index: int):
	_options[p_index].changed.disconnect(emit_changed)
	_options.remove_at(p_index)
	emit_changed()

func get_option(p_index: int) -> DialogOption:
	return _options[p_index]

var option_count: int:
	get:
		return len(_options)

func export_to_csv(p_nodes: Dictionary) -> String:
	var lines_string: String = ""
	
	for line in _lines:
		lines_string += "\"\"%s\"\"," % line.c_escape()
	
	var options_string: String = ""
	
	for option in _options:
		var actions: String = DialogNode.fetch_actions(option.connection_id, p_nodes)
		options_string += "(Text=\"\"%s\"\",Actions=(%s))," % [
			option.text.c_escape(),
			actions.substr(0, actions.length() - 1)
		]
	
	var optionless_string: String
	
	if optionless_connection_id:
		optionless_string = DialogNode.fetch_actions(optionless_connection_id, p_nodes)
		optionless_string = optionless_string.substr(0, optionless_string.length() - 1)
	else:
		optionless_string = "(Type=EndDialog,GotoDialogName=\"\"\"\",EventName=\"\"\"\")"
	
	var result: String = "%s,\"%s\",\"(%s)\",\"(%s)\",\"(%s)\"" % [
		node_id,
		speaker,
		lines_string.substr(0, lines_string.length() - 1),
		options_string.substr(0, options_string.length() - 1),
		optionless_string,
	]
	return result

static func fetch_actions(p_connection_id: int, p_nodes: Dictionary) -> String:
	if p_connection_id:
		var connected_node: DialogTreeNode = p_nodes[p_connection_id]
		
		if connected_node is DialogNode:
			return "(Type=Goto,GotoDialogName=\"\"%s\"\",EventName=\"\"\"\")," % connected_node.node_id
		elif connected_node is DialogEvent:
			return "(Type=Event,GotoDialogName=\"\"\"\",EventName=\"\"%s\"\"),%s" % [
				connected_node.event_name.c_escape(),
				fetch_actions(connected_node.connection_id, p_nodes),
			]
		elif connected_node is DialogEnd:
			return "(Type=EndDialog,GotoDialogName=\"\"\"\",EventName=\"\"\"\"),"
		else:
			assert(false, "Unknown node type")
			return "(Type=EndDialog,GotoDialogName=\"\"\"\",EventName=\"\"\"\"),"
	else:
		return ""

func search(p_text: String, p_case_sensitive: bool) -> bool:
	return (
		_lines.any(
			func(l): return (l.find(p_text) if p_case_sensitive else l.findn(p_text)) != -1
		)
		or _options.any(
			func(o): return (o.text.find(p_text) if p_case_sensitive else o.text.findn(p_text)) != -1
		)
		or (speaker.find(p_text) if p_case_sensitive else speaker.findn(p_text)) != -1
	)
