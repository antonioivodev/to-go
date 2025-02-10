class_name TaskPanelContainer
extends Node

@export_category("References")
@export var label: RichTextLabel
@export var button: BaseButton

func _ready() -> void:
	button.toggled.connect(_on_toggle)


func _on_toggle(on_toggle: bool):
	var text = label.text
	if on_toggle:
		label.parse_bbcode("[color=#FF0000]%s[/color]" % text)
	else:
		label.parse_bbcode(text)
