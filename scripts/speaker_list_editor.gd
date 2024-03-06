extends Window

const DEFAULT_SPEAKER_NAME: String = "New Speaker"

var speaker_editors: Array[Node]

func _ready():
	Root.project_changed.connect(_on_root_project_changed)
	_on_root_project_changed(Root.current_project)

func _on_root_project_changed(p_new_project: DialogTree):
	if not p_new_project.speakers_changed.is_connected(_on_speakers_changed):
		p_new_project.speakers_changed.connect(_on_speakers_changed)
	
	_on_speakers_changed(true)

func _on_speakers_changed(p_initial_load: bool = false):
	for editor in speaker_editors:
		editor.queue_free()
	
	speaker_editors.clear()
	
	var i: int = 0
	
	for speaker in Root.current_project.speakers.values():
		var editor = preload("res://scenes/speaker_editor.tscn").instantiate()
		editor.text = speaker.name
		
		if speaker.thumbnail:
			editor.icon = speaker.thumbnail
		else:
			editor.icon = preload("res://textures/default_character_10.svg")
		
		%SpeakerList.add_child(editor)
		%SpeakerList.move_child(editor, i)
		speaker_editors.push_back(editor)
		
		editor.text_submitted.connect(_on_speaker_name_changed.bind(speaker.name))
		editor.get_node("%RemoveButton").pressed.connect(_on_speaker_removed.bind(speaker.name))
		
		editor.open_icon_dialog = %IconSelectFileDialog
		editor.icon_chosen.connect(_on_speaker_icon_changed.bind(speaker.name))
		
		i += 1
	
	if not p_initial_load:
		Root.mark_modified()

func _on_add_speaker_button_pressed():
	var new_speaker = DialogSpeaker.new()
	new_speaker.name = DEFAULT_SPEAKER_NAME
	Root.current_project.speakers[DEFAULT_SPEAKER_NAME] = new_speaker
	Root.current_project.update_speakers()

func _on_speaker_name_changed(p_new_name: String, p_old_name: String):
	var speaker: DialogSpeaker = Root.current_project.speakers[p_old_name]
	
	speaker.name = p_new_name
	Root.current_project.speakers.erase(p_old_name)
	Root.current_project.speakers[p_new_name] = speaker
	Root.current_project.update_speakers()

func _on_speaker_icon_changed(p_icon: Texture2D, p_name: String):
	Root.current_project.speakers[p_name].thumbnail = p_icon
	Root.current_project.update_speakers()

func _on_speaker_removed(p_name: String):
	Root.current_project.speakers.erase(p_name)
	Root.current_project.update_speakers()

func _on_close_requested():
	hide()
