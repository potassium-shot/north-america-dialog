class_name DialogEvent extends DialogTreeNode

@export var event_name: String:
	set(value):
		if value == event_name:
			return
		
		event_name = value
		emit_changed()

@export var connection_id: int:
	set(value):
		if value == connection_id:
			return
		
		connection_id = value
		emit_changed()

func search(p_text: String, p_case_sensitive: bool) -> bool:
	return (event_name.find(p_text) if p_case_sensitive else event_name.findn(p_text)) != -1
