class_name UserSession extends Resource

const PATH: String = "user://session.tres"

@export var _recent_files: PackedStringArray
@export var _asked_for_help_times: int = 0:
	set(value):
		_asked_for_help_times = value
		emit_changed()

var recent_files: PackedStringArray:
	get:
		return _recent_files

func _init():
	changed.connect(save)

static func load() -> UserSession:
	if ResourceLoader.exists(PATH, "UserSession"):
		return ResourceLoader.load(PATH, "UserSession", ResourceLoader.CACHE_MODE_REPLACE) as UserSession
	else:
		return new()

func save():
	ResourceSaver.save(self, PATH)

func push_recent_file(p_path: String):
	var found_index = _recent_files.find(p_path)
	
	if found_index != -1:
		_recent_files.remove_at(found_index)
	
	_recent_files.insert(0, p_path)
	emit_changed()

func clear_recent_files():
	_recent_files.clear()
	emit_changed()
