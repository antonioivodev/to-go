class_name TaskContainer
extends Node

@export var check_box: CheckBox
@export var label: RichTextLabel


func _ready() -> void:
	check_box.toggled.connect(_on_toggle)


func _on_toggle(on_toggle: bool):
	var text = label.text
	if on_toggle:
		label.parse_bbcode("[color=#AAAAAA]%s[/color]" % text)
	else:
		label.parse_bbcode(text)
