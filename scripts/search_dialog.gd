extends VBoxContainer

@onready var graph_edit: GraphEdit = %GraphEdit
@onready var search_string: LineEdit = %SearchString
@onready var search_result: Label = %SearchResult
@onready var search_button: Button = %SearchButton
@onready var prev_button: Button = %PreviousButton
@onready var next_button: Button = %NextButton
@onready var occurence_button: Label = %OccurenceLabel

var case_sensitive: bool = false

var results: Array[DialogTreeNode] = []:
	set(value):
		results = value
		
		if not is_node_ready():
			return
		
		if value.is_empty():
			search_result.text = "No results found."
			occurence_button.text = "0/0"
		else:
			search_result.text = "%s results." % len(value)
			selected_result = 0
			focus_selected_result()
		

var selected_result: int = 0:
	set(value):
		selected_result = value
		
		if not is_node_ready():
			return
		
		var buttons_disabled = len(results) <= 1
		prev_button.disabled = buttons_disabled
		next_button.disabled = buttons_disabled
		occurence_button.text = "%s/%s" % [value + 1, len(results)]

func _on_search_button_pressed():
	perform_search(search_string.text)

func _on_search_string_text_submitted(p_new_text: String):
	perform_search(p_new_text)

func _on_search_string_text_changed(p_new_text: String):
	search_button.disabled = p_new_text.is_empty()

func _on_cancel_button_pressed():
	hide()

func _on_match_case_toggle_toggled(p_toggled_on: bool):
	case_sensitive = p_toggled_on

func _on_previous_button_pressed():
	selected_result = wrapi(selected_result - 1, 0, len(results))
	focus_selected_result()

func _on_next_button_pressed():
	selected_result = wrapi(selected_result + 1, 0, len(results))
	focus_selected_result()

func perform_search(p_text: String):
	results = Root.current_project.search(p_text, case_sensitive)

func focus_selected_result():
	if results.is_empty():
		return
	
	var tree_node: DialogTreeNode = results[selected_result]
	
	if tree_node:
		var node: GraphNode = tree_node.graph_node
		graph_edit.set_selected(node)
		graph_edit.scroll_offset = node.position_offset + node.size * 0.5 - graph_edit.size * 0.5
