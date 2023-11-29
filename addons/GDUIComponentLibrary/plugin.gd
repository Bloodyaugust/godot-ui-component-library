@tool
extends EditorPlugin


func _enter_tree():
	add_custom_type(
		"SingleSelect",
		"PanelContainer",
		preload("res://addons/GDUIComponentLibrary/components/SingleSelect.gd"),
		preload("res://addons/GDUIComponentLibrary/icons/icon-select.png")
	)


func _exit_tree():
	remove_custom_type("SingleSelect")
