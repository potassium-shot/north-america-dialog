## This is the resource that is saved
class_name DialogTree extends Resource

## Dictionary {int: DialogTreeNode}
@export var _nodes: Dictionary = Dictionary():
	set(value):
		_nodes = value
		
		for node in value:
			value[node].changed.connect(emit_changed)

## Dictionary {String: DialogSpeaker}
@export var speakers: Dictionary = Dictionary():
	set(value):
		speakers = value
		
		for speaker in value:
			value[speaker].changed.connect(emit_changed)

@export var export_path: String = ""

var undo_redo: UndoRedo = UndoRedo.new()

signal speakers_changed()

func update_speakers():
	speakers_changed.emit()
	emit_changed()

func push_node(p_node: DialogTreeNode):
	_nodes[p_node.node_id] = p_node
	p_node.changed.connect(emit_changed)
	emit_changed()

func remove_node(p_id: int):
	_nodes[p_id].changed.disconnect(emit_changed)
	_nodes.erase(p_id)
	emit_changed()

func get_node(p_id: int) -> DialogTreeNode:
	return _nodes[p_id]

func has_node(p_id: int) -> bool:
	return _nodes.has(p_id)

func export_nodes_to_csv() -> String:
	var result = "---,Speaker,Lines,Options,EndAction\n"
	
	for node in _nodes.values():
		if node is DialogNode:
			result += node.export_to_csv(_nodes) + "\n"
	
	return result

func export_speakers_to_csv() -> String:
	var result = "---,Display Name\n"
	
	for speaker in speakers:
		speaker = speaker.c_escape()
		result += "%s,\"%s\"\n" % [speaker, speaker]
	
	return result

func export_entries_to_csv() -> String:
	var result = "---,NodeId\n"
	
	for node in _nodes.values():
		if node is DialogEntry:
			result += "%s,\"%s\"\n" % [node.entry_name.c_escape(), node.connection_id]
	
	return result

func search(p_text: String, p_case_sensitive: bool) -> Array[DialogTreeNode]:
	var result: Array[DialogTreeNode] = []
	result.assign(_nodes.values().filter(func (n): return n.search(p_text, p_case_sensitive)))
	return result

func _notification(p_what: int):
	if p_what == NOTIFICATION_PREDELETE:
		undo_redo.free()
