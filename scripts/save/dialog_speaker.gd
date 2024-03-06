class_name DialogSpeaker extends Resource

@export var name: String:
	set(value):
		if value == name:
			return
		
		name = value
		emit_changed()

@export var thumbnail: Texture2D:
	set(value):
		if value == thumbnail:
			return
		
		thumbnail = value
		emit_changed()
