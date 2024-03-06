class_name DialogGraphNodeBase extends GraphNode

@export var node_icon: Texture2D

func _ready():
	var icon: TextureRect = TextureRect.new()
	icon.texture = node_icon
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	get_titlebar_hbox().add_child(icon, false, Node.INTERNAL_MODE_FRONT)
