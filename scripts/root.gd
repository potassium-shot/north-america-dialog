extends Node

const DEFAULT_PROJECT: DialogTree = preload("res://resources/default_project.tres")

var current_project: DialogTree = DEFAULT_PROJECT.duplicate(true):
	set(value):
		if current_project and current_project.changed.is_connected(true_mark_modified):
			current_project.changed.disconnect(true_mark_modified)
		
		current_project = value
		project_changed.emit(value)
		project_has_been_modified = false
		
		if value:
			value.changed.connect(true_mark_modified)
		
		update_window_title()

var current_file_path: String:
	set(value):
		current_file_path = value
		
		if not value.is_empty():
			session.push_recent_file(value)

var project_has_been_modified: bool = false

@onready var session: UserSession = UserSession.load()

@onready var unsaved_dialog: ConfirmationDialog = get_tree().root.get_node("UiRoot/%UnsavedConfirmationDialog")
@onready var auto_popup: Window = get_tree().root.get_node("UiRoot/%AutoPopup")

signal project_changed(p_new_project: DialogTree)

func _enter_tree():
	OS.low_processor_usage_mode = true
	get_tree().auto_accept_quit = false

func _ready():
	project_changed.emit(current_project)
	update_window_title()

func _notification(p_what: int):
	if p_what == NOTIFICATION_WM_CLOSE_REQUEST:
		quit()

func new_file():
	if await prompt_if_unsaved():
		current_file_path = String()
		current_project = DEFAULT_PROJECT.duplicate(true)
		auto_popup.pop("New File")

func open_file(p_path: String):
	if await prompt_if_unsaved():
		current_file_path = p_path
		current_project = ResourceLoader.load(p_path, "DialogTree", ResourceLoader.CACHE_MODE_REPLACE)
		auto_popup.pop("Opened %s" % current_file_path.get_file())

func save_file(p_path: String):
	current_file_path = p_path
	ResourceSaver.save(current_project, p_path)
	project_has_been_modified = false
	update_window_title()
	
	auto_popup.pop("Saved to %s" % p_path)

func export_file(p_path: String):
	current_project.export_path = p_path
	p_path = current_file_path.get_base_dir().path_join(p_path).simplify_path()
	var path_root = p_path.substr(0, p_path.length() - 4)
	
	var dialog = FileAccess.open(path_root + "-dialog.csv", FileAccess.WRITE)
	dialog.store_string(current_project.export_nodes_to_csv())
	dialog.close()
	
	var speakers = FileAccess.open(path_root + "-speakers.csv", FileAccess.WRITE)
	speakers.store_string(current_project.export_speakers_to_csv())
	speakers.close()
	
	var entries = FileAccess.open(path_root + "-entries.csv", FileAccess.WRITE)
	entries.store_string(current_project.export_entries_to_csv())
	entries.close()
	
	auto_popup.pop("Exported to %s" % p_path)

func close_file():
	new_file()

func quit():
	if await prompt_if_unsaved():
		get_tree().quit()

func is_current_file_saved() -> bool:
	return not current_file_path.is_empty()

func get_new_id() -> int:
	var id: int = randi()
	
	while current_project.has_node(id) or id == 0:
		id = randi()
	
	return id

## CURRENTLY DOES NOTHING DUE TO REFACTORING, TODO: REMOVE
func mark_modified():
	pass

func true_mark_modified():
	project_has_been_modified = true
	update_window_title()

func prompt_if_unsaved() -> bool:
	if project_has_been_modified:
		return await unsaved_dialog.prompt()
	else:
		return true

func update_window_title():
	DisplayServer.window_set_title(
		"North America Dialog - Editing \"%s\"%s" % [
			"<unsaved>" if current_file_path.is_empty() else current_file_path.get_file(),
			" (*)" if project_has_been_modified else "",
		]
	)
