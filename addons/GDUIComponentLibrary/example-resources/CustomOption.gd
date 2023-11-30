@tool
extends HBoxContainer

signal pressed

var text: String = "":
	set(new_text):
		text = new_text
		%Button.text = new_text


func _on_button_pressed() -> void:
	pressed.emit()


func _ready():
	%Button.pressed.connect(_on_button_pressed)
