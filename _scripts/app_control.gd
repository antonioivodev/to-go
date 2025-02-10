extends Control

@export_category("Preloads")
@export var task_panel_container_preload: PackedScene

@export_category("References")
@export var task_container: Control
@export var text_line_editor: LineEdit
@export var task_add_button: Button
@export var task_remove_button: Button

const TASK_LIST_FILEPATH: String = "user://tasks.json"


func _ready() -> void:
	task_add_button.pressed.connect(_on_add_task_button_pressed)
	task_remove_button.pressed.connect(_on_remove_tasks_button_pressed)
	text_line_editor.text_submitted.connect(_on_text_submitted)
	get_window().close_requested.connect(_on_window_close_requested)

	var file = FileAccess.open(TASK_LIST_FILEPATH, FileAccess.READ_WRITE)
	if file != null:
		load_tasks(file.get_as_text())
	file.close()


func _on_text_submitted(new_text: String) -> void:
	print_debug("_on_text_submitteds: %s" % new_text)
	if new_text.is_empty():
		return

	_create_new_task(new_text)


func _on_add_task_button_pressed() -> void:
	_create_new_task(text_line_editor.text)


func _on_remove_tasks_button_pressed() -> void:
	var tasks: Array[Node] = task_container.get_children()
	for t: TaskPanelContainer in tasks:
		if t.button.button_pressed:
			t.queue_free()


func _on_window_close_requested() -> void:
	save_tasks()


func _create_new_task(task_text: String, is_marked: bool = false):
	if task_text.is_empty():
		return

	var task: TaskPanelContainer = task_panel_container_preload.instantiate()
	task.label.text = task_text
	task.button.button_pressed = is_marked
	task_container.add_child(task)
	print_debug("_create_new_task {%s, %s}" % [task_text, is_marked])
	text_line_editor.text = ""


func save_tasks() -> void:
	print_debug("saving tasks...")

	var tasks: Array[Node] = task_container.get_children()
	var dict: Dictionary
	for i in range(tasks.size()):
		var task: TaskPanelContainer = tasks[i]
		dict[i] = {
			label = task.label.text,
			value = task.button.button_pressed
		}

	var file = FileAccess.open(TASK_LIST_FILEPATH, FileAccess.WRITE)
	var json = JSON.stringify(dict)
	file.store_string(json)
	file.close()


func load_tasks(json_string: String) -> void:
	print_debug("loading tasks...")

	var dict: Dictionary
	if not json_string.is_empty():
		dict = JSON.parse_string(json_string)

	for k in dict.keys():
		_create_new_task(dict[k].label, dict[k].value)
