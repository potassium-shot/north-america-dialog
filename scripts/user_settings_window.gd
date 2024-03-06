extends Window

@onready var categories_list: ItemList = %Categories

var currently_visible_category: Control = null:
	set(value):
		if currently_visible_category:
			currently_visible_category.visible = false
		
		currently_visible_category = value
		
		if value:
			value.visible = true

func _ready():
	categories_list.select(0)
	_on_categories_item_selected(0)

func _on_categories_item_selected(p_index: int):
	currently_visible_category = %Settings.get_node(categories_list.get_item_text(p_index))

func _on_close_requested():
	visible = false
