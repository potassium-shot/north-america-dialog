extends DialogGraphNodeBase

@export var node_resource: DialogEntry:
	set(value):
		node_resource = value
		
		if is_node_ready() and value:
			_entry_node_name_changed()

func _ready():
	super._ready()
	
	node_resource = node_resource

func _on_dragged(p_from: Vector2, p_to: Vector2):
	if is_node_ready() and p_from != p_to:
		node_resource.position = position_offset

func _entry_node_name_changed():
	%NameEdit.text = node_resource.entry_name
	Root.mark_modified()

func _on_name_edit_focus_exited():
	node_resource.entry_name = %NameEdit.text
	_entry_node_name_changed()
