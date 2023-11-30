@tool
extends PanelContainer

signal option_selected(option: String)

@export
var collapse_icon: Texture2D = preload("res://addons/GDUIComponentLibrary/icons/chevron-up.png")
@export var search_custom_minimum_size: Vector2 = Vector2(200, 30):
	set(new_search_custom_minimum_size):
		search_custom_minimum_size = new_search_custom_minimum_size

		search.custom_minimum_size = search_custom_minimum_size
@export
var expand_icon: Texture2D = preload("res://addons/GDUIComponentLibrary/icons/chevron-down.png")
@export var options: Array[String] = []:
	set(new_options):
		options = new_options
		_render_options()
@export_file() var option_scene: Variant = null:
	set(new_option_scene):
		if new_option_scene is String:
			option_scene = load(new_option_scene)
		else:
			option_scene = new_option_scene

		if show_options:
			_render_options()
@export var selected_option: String = "":
	set(new_selected_option):
		selected_option = new_selected_option
		search.text = new_selected_option
		show_options = false
@export var show_options: bool = false:
	set(new_show_options):
		show_options = new_show_options

		if show_options:
			_render_options()
			options_container.position = _get_options_container_position()
			options_container.custom_minimum_size = _get_options_container_size()
			options_container.visible = true
			expand_collapse_texture.texture = collapse_icon
		else:
			options_container.visible = false
			expand_collapse_texture.texture = expand_icon

var expand_collapse_texture: TextureRect = TextureRect.new()
var search: LineEdit = LineEdit.new()
var search_container: HBoxContainer = HBoxContainer.new()
var inner_margin_container: MarginContainer = MarginContainer.new()
var options_container: VBoxContainer = VBoxContainer.new()
var options_container_canvas_layer: CanvasLayer = CanvasLayer.new()
var options_container_container: PanelContainer = PanelContainer.new()
var root_container: VBoxContainer = VBoxContainer.new()

var _search_text: String = ""


func _get_options_container_position() -> Vector2:
	return Vector2(
		inner_margin_container.global_position.x, search_container.global_position.y + size.y
	)


func _get_options_container_size() -> Vector2:
	return Vector2(size.x, 0)


func _on_search_focus_entered() -> void:
	show_options = true


func _on_search_text_changed(new_text: String) -> void:
	_search_text = new_text
	if show_options:
		_render_options()


func _on_option_selected(option: String) -> void:
	selected_option = option
	option_selected.emit(option)


func _render_options() -> void:
	for child in options_container.get_children():
		if child.has_signal("pressed") and child.is_connected("pressed", _on_option_selected):
			child.pressed.disconnect(_on_option_selected)
		child.queue_free()

	var filtered_options = (
		options.filter(func(option: String): return _search_text.to_lower() in option.to_lower())
		if _search_text
		else options
	)
	for option_index in len(filtered_options):
		var new_option_component: Variant = (
			option_scene.instantiate() if option_scene else Button.new()
		)

		new_option_component.text = filtered_options[option_index]
		new_option_component.pressed.connect(
			func(): _on_option_selected(filtered_options[option_index])
		)

		options_container.add_child(new_option_component)
		if option_index < filtered_options.size() - 1:
			options_container.add_child(HSeparator.new())


func _init():
	theme_changed.connect(func(): options_container.theme = theme)

	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	options_container_container.visible = show_options
	search.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	search.custom_minimum_size = search_custom_minimum_size
	expand_collapse_texture.texture = expand_icon
	expand_collapse_texture.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	expand_collapse_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	options_container.custom_minimum_size = _get_options_container_size()
	options_container.theme = theme
	options_container.position = _get_options_container_position()

	options_container.visible = false

	search.focus_entered.connect(_on_search_focus_entered)
	search.text_changed.connect(_on_search_text_changed)

	add_child(inner_margin_container)
	inner_margin_container.add_child(root_container)
	root_container.add_child(search_container)
	search_container.add_child(search)
	search_container.add_child(expand_collapse_texture)
	root_container.add_child(options_container_container)
	options_container_container.add_child(options_container_canvas_layer)
	options_container_canvas_layer.add_child(options_container)
