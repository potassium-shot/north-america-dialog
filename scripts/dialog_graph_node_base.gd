class_name DialogGraphNodeBase extends GraphNode

@export var node_icon: Texture2D

func _ready():
	var icon: TextureRect = TextureRect.new()
	icon.texture = node_icon
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	get_titlebar_hbox().add_child(icon, false, Node.INTERNAL_MODE_FRONT)

func _update_position():
	pass

func move_node(p_from: Vector2, p_to: Vector2):
	var undo_redo: UndoRedo = Root.current_project.undo_redo
	undo_redo.create_action("Move Node")
	
	undo_redo.add_do_property(self, &"position_offset", p_to)
	undo_redo.add_do_method(_update_position)
	
	undo_redo.add_undo_property(self, &"position_offset", p_from)
	undo_redo.add_undo_method(_update_position)
	
	undo_redo.commit_action()
