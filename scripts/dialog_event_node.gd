extends DialogGraphNodeBase

@export var node_resource: DialogEvent:
	set(value):
		node_resource = value
		
		if is_node_ready() and value:
			_event_node_name_changed()

func _ready():
	super._ready()
	node_resource = node_resource

func _on_dragged(p_from: Vector2, p_to: Vector2):
	if is_node_ready() and p_from != p_to:
		move_node(p_from, p_to)

func _update_position():
	node_resource.position = position_offset

func _event_node_name_changed():
	%NameEdit.text = node_resource.event_name

func _on_name_edit_focus_exited():
	var undo_redo: UndoRedo = Root.current_project.undo_redo
	undo_redo.create_action("Rename Event")
	
	undo_redo.add_do_property(node_resource, &"event_name", %NameEdit.text)
	undo_redo.add_do_method(_event_node_name_changed)
	
	undo_redo.add_undo_property(node_resource, &"event_name", node_resource.event_name)
	undo_redo.add_undo_method(_event_node_name_changed)
	
	undo_redo.commit_action()
