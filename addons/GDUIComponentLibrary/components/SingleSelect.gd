@tool
extends PanelContainer

signal option_selected(option: String)

@export
var collapse_icon: Texture2D = preload("res://addons/GDUIComponentLibrary/icons/chevron-up.png")
@export var button_custom_minimum_size: Vector2 = Vector2(200, 30):
	set(new_button_custom_minimun_size):
		button_custom_minimum_size = new_button_custom_minimun_size

		button.custom_minimum_size = button_custom_minimum_size
@export
var expand_icon: Texture2D = preload("res://addons/GDUIComponentLibrary/icons/chevron-down.png")
@export var options: Array[String] = []:
	set(new_options):
		options = new_options

		for child in options_container.get_children():
			if child is Button:
				if child.is_connected("pressed", _on_option_selected):
					child.pressed.disconnect(_on_option_selected)
			child.queue_free()

		for option_index in len(options):
			var new_label: Button = Button.new()

			new_label.text = options[option_index]
			new_label.pressed.connect(func(): _on_option_selected(options[option_index]))

			options_container.add_child(new_label)
			if option_index < options.size() - 1:
				options_container.add_child(HSeparator.new())
@export var selected_option: String = "":
	set(new_selected_option):
		selected_option = new_selected_option
		button.text = new_selected_option
		show_options = false
@export var show_options: bool = false:
	set(new_show_options):
		show_options = new_show_options

		if show_options:
			options_container.position = _get_options_container_position()
			options_container.custom_minimum_size = _get_options_container_size()
			options_container.visible = true
			button.icon = collapse_icon
		else:
			options_container.visible = false
			button.icon = expand_icon

var button: Button = Button.new()
var button_container: HBoxContainer = HBoxContainer.new()
var inner_margin_container: MarginContainer = MarginContainer.new()
var options_container: VBoxContainer = VBoxContainer.new()
var options_container_canvas_layer: CanvasLayer = CanvasLayer.new()
var options_container_container: PanelContainer = PanelContainer.new()
var root_container: VBoxContainer = VBoxContainer.new()


func _get_options_container_position() -> Vector2:
	return Vector2(
		inner_margin_container.global_position.x, button_container.global_position.y + size.y
	)


func _get_options_container_size() -> Vector2:
	print(Vector2(size.x, 0))
	return Vector2(size.x, 0)


func _on_button_pressed() -> void:
	show_options = !show_options


func _on_option_selected(option: String) -> void:
	selected_option = option
	button.text = option
	option_selected.emit(option)


func _init():
	theme_changed.connect(func(): options_container.theme = theme)

	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	options_container_container.visible = show_options
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.icon_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	button.expand_icon = true
	button.icon = expand_icon
	button.custom_minimum_size = button_custom_minimum_size
	options_container.custom_minimum_size = _get_options_container_size()
	options_container.theme = theme
	options_container.position = _get_options_container_position()

	options_container.visible = false

	button.pressed.connect(_on_button_pressed)

	add_child(inner_margin_container)
	inner_margin_container.add_child(root_container)
	root_container.add_child(button_container)
	button_container.add_child(button)
	root_container.add_child(options_container_container)
	options_container_container.add_child(options_container_canvas_layer)
	options_container_canvas_layer.add_child(options_container)
