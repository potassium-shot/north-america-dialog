class_name DialogEntry extends DialogTreeNode

@export var entry_name: String:
	set(value):
		if value == entry_name:
			return
		
		entry_name = value
		emit_changed()

@export var connection_id: int:
	set(value):
		if value == connection_id:
			return
		
		connection_id = value
		emit_changed()

func search(p_text: String, p_case_sensitive: bool) -> bool:
	return (entry_name.find(p_text) if p_case_sensitive else entry_name.findn(p_text)) != -1
