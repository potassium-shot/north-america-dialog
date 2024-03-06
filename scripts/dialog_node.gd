extends DialogGraphNodeBase

const NO_SPEAKER_ICON: Texture2D = preload("res://textures/no_character.svg")
const NO_SPEAKER_TEXT: String = "(none)"
const SPEAKER_DEFAULT_ICON: Texture2D = preload("res://textures/default_character_10.svg")

@onready var speaker_selector: MenuButton = %SpeakerSelector

@export var node_resource: DialogNode:
	set(value):
		node_resource = value
		
		if is_node_ready() and value:
			_dialog_node_speaker_changed()
			_dialog_node_lines_changed()
			_dialog_node_options_changed()

var dialog_line_editors: Array[Node]
var dialog_options_editors: Array[Node]

func _ready():
	super._ready()
	
	Root.current_project.speakers_changed.connect(_update_speakers)
	_update_speakers()
	speaker_selector.get_popup().id_pressed.connect(_on_speaker_selected)
	node_resource = node_resource

func _on_dragged(p_from: Vector2, p_to: Vector2):
	if is_node_ready() and p_from != p_to:
		node_resource.position = position_offset

func _on_resize_request(p_new_minsize: Vector2):
	if is_node_ready():
		node_resource.size = p_new_minsize
	
	Root.mark_modified()

#region Speakers

func _update_speakers():
	var speakers_popup: PopupMenu = speaker_selector.get_popup()
	
	speakers_popup.clear()
	
	for speaker: DialogSpeaker in Root.current_project.speakers.values():
		var icon: Texture2D = speaker.thumbnail
		
		if not icon:
			icon = SPEAKER_DEFAULT_ICON
		
		speakers_popup.add_icon_item(icon, speaker.name)
	
	speakers_popup.add_icon_item(NO_SPEAKER_ICON, NO_SPEAKER_TEXT)
	
	_dialog_node_speaker_changed()

func _dialog_node_speaker_changed():
	if node_resource.speaker.is_empty():
		speaker_selector.icon = NO_SPEAKER_ICON
		speaker_selector.tooltip_text = "(no speaker)"
	else:
		speaker_selector.icon = Root.current_project.speakers[node_resource.speaker].thumbnail
		
		if not speaker_selector.icon:
			speaker_selector.icon = SPEAKER_DEFAULT_ICON
		
		speaker_selector.tooltip_text = node_resource.speaker
	
	Root.mark_modified()

func _on_speaker_selected(p_index: int):
	match speaker_selector.get_popup().get_item_text(p_index):
		NO_SPEAKER_TEXT:
			node_resource.speaker = ""
		var other:
			node_resource.speaker = other
	
	_dialog_node_speaker_changed()

#endregion Speakers

#region Lines

func _dialog_node_lines_changed():
	for editor in dialog_line_editors:
		editor.queue_free()
	
	dialog_line_editors.clear()
	
	for i in range(node_resource.line_count):
		var editor = preload("res://scenes/dialog_line_editor.tscn").instantiate()
		editor.text = node_resource.get_line(i)
		%LinesList.add_child(editor)
		%LinesList.move_child(editor, i)
		dialog_line_editors.push_back(editor)
		
		editor.get_node("%TextEdit").focus_exited.connect(_on_line_editor_focus_exited.bind(i))
		editor.get_node("%RemoveButton").pressed.connect(_on_line_editor_removed.bind(i))
	
	Root.mark_modified()

func _on_add_line_button_pressed():
	node_resource.push_line("")
	_dialog_node_lines_changed()

func _on_line_editor_focus_exited(p_index: int):
	node_resource.set_line(p_index, dialog_line_editors[p_index].text)
	Root.mark_modified()

func _on_line_editor_removed(p_index: int):
	node_resource.remove_line(p_index)
	_dialog_node_lines_changed()

#endregion Lines

#region Options

func _dialog_node_options_changed():
	for editor in dialog_options_editors:
		editor.queue_free()
	
	dialog_options_editors.clear()
	
	for i in range(0, get_child_count()):
		set_slot_enabled_right(i, false)
	
	if node_resource.option_count == 0:
		set_slot_enabled_right(0, true)
	else:
		for i in range(node_resource.option_count):
			var editor = preload("res://scenes/dialog_option_editor.tscn").instantiate()
			var option = node_resource.get_option(i)
			editor.text = option.text
			add_child(editor)
			move_child(editor, 3 + i)
			dialog_options_editors.push_back(editor)
			
			set_slot_enabled_right(3 + i, true)
			
			editor.get_node("%LineEdit").focus_exited.connect(_on_option_editor_focus_exited.bind(i))
			editor.get_node("%RemoveButton").pressed.connect(_on_option_editor_removed.bind(i))
	
	Root.mark_modified()

func _on_add_option_button_pressed():
	node_resource.push_option(DialogOption.new())
	_dialog_node_options_changed()

func _on_option_editor_focus_exited(p_index: int):
	node_resource.get_option(p_index).text = dialog_options_editors[p_index].text
	Root.mark_modified()

func _on_option_editor_removed(p_index: int):
	node_resource.remove_option(p_index)
	_dialog_node_options_changed()

#endregion Options