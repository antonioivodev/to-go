extends Node

@export var task_container_preload: PackedScene
@export var task_list_container: Node

const TASK_LIST_FILEPATH: String = "user://tasks.json"


func _ready() -> void:
	%LineEdit.text_submitted.connect(_on_line_edit_text_submitted)
	%AddTaskButton.pressed.connect(_on_add_task_button_pressed)
	%EraseTasksButton.pressed.connect(_on_erase_tasks_button_pressed)
	get_window().close_requested.connect(_on_window_close_requested)

	var file = FileAccess.open(TASK_LIST_FILEPATH, FileAccess.READ_WRITE)
	if file != null:
		load_tasks(file.get_as_text())
	file.close()


func _on_line_edit_text_submitted(new_text: String) -> void:
	_create_new_task(new_text)


func _on_add_task_button_pressed() -> void:
	_create_new_task(%LineEdit.text)


func _on_erase_tasks_button_pressed() -> void:
	var tasks: Array[Node] = task_list_container.get_children()
	for t: TaskContainer in tasks:
		if t.check_box.button_pressed:
			t.queue_free()


func _create_new_task(text: String, value: bool = false) -> void:
	if text.is_empty():
		return

	var task: TaskContainer = task_container_preload.instantiate()
	task_list_container.add_child(task)
	task.label.text = text
	task.check_box.button_pressed = value
	task.check_box.toggled.emit(value)
	%LineEdit.text = ""


func _on_window_close_requested() -> void:
	save_tasks()


func save_tasks() -> void:
	var tasks: Array[Node] = task_list_container.get_children()
	var dict: Dictionary
	for i in range(tasks.size()):
		var task: TaskContainer = tasks[i]
		dict[i] = {
			label = task.label.text,
			value = task.check_box.button_pressed
		}

	var file = FileAccess.open(TASK_LIST_FILEPATH, FileAccess.WRITE)
	var json = JSON.stringify(dict)
	file.store_string(json)
	file.close()


func load_tasks(json_string: String) -> void:
	var dict: Dictionary
	if not json_string.is_empty():
		dict = JSON.parse_string(json_string)
	
	for k in dict.keys():
		_create_new_task(dict[k].label, dict[k].value)
