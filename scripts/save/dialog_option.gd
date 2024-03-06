class_name DialogOption extends Serializable

@export var text: String:
	set(value):
		if value == text:
			return
		
		text = value
		emit_changed()

@export var connection_id: int:
	set(value):
		if value == connection_id:
			return
		
		connection_id = value
		emit_changed()
