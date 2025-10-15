extends Control

@onready var grid_container = $MarginContainer/VBoxContainer/ScrollContainer/GridContainer
@onready var generate_button = $MarginContainer/VBoxContainer/ControlsContainer/GenerateButton
@onready var width_slider = $MarginContainer/VBoxContainer/SizeContainer/WidthContainer/WidthSlider
@onready var height_slider = $MarginContainer/VBoxContainer/SizeContainer/HeightContainer/HeightSlider
@onready var width_label = $MarginContainer/VBoxContainer/SizeContainer/WidthContainer/WidthLabel
@onready var height_label = $MarginContainer/VBoxContainer/SizeContainer/HeightContainer/HeightLabel
@onready var status_label = $MarginContainer/VBoxContainer/StatusLabel

const CELL_SIZE = 20
const MIN_SIZE = 10
const MAX_WIDTH = 60
const MAX_HEIGHT = 45

var grid_width: int = 40
var grid_height: int = 30
var island_generator: IslandGenerator
var cell_visuals: Array = []
var is_generating: bool = false

func _ready():
	generate_button.pressed.connect(_on_generate_pressed)
	width_slider.value_changed.connect(_on_width_changed)
	height_slider.value_changed.connect(_on_height_changed)
	
	# Setup sliders
	width_slider.min_value = MIN_SIZE
	width_slider.max_value = MAX_WIDTH
	width_slider.value = grid_width
	width_slider.step = 5
	
	height_slider.min_value = MIN_SIZE
	height_slider.max_value = MAX_HEIGHT
	height_slider.value = grid_height
	height_slider.step = 5
	
	update_size_labels()
	setup_grid()
	
	island_generator = IslandGenerator.new(grid_width, grid_height)
	update_status("Click Generate to create an island!")

func update_size_labels():
	width_label.text = "Width: %d" % grid_width
	height_label.text = "Height: %d" % grid_height

func _on_width_changed(value: float):
	grid_width = int(value)
	update_size_labels()
	rebuild_grid()

func _on_height_changed(value: float):
	grid_height = int(value)
	update_size_labels()
	rebuild_grid()

func rebuild_grid():
	setup_grid()
	island_generator = IslandGenerator.new(grid_width, grid_height)

func setup_grid():
	# Clear existing cells
	for child in grid_container.get_children():
		child.queue_free()
	
	cell_visuals.clear()
	grid_container.columns = grid_width
	
	for y in range(grid_height):
		var row = []
		for x in range(grid_width):
			var cell = ColorRect.new()
			cell.custom_minimum_size = Vector2(CELL_SIZE, CELL_SIZE)
			cell.color = Color(0.2, 0.2, 0.3, 1)
			grid_container.add_child(cell)
			row.append(cell)
		cell_visuals.append(row)

func _on_generate_pressed():
	if is_generating:
		return
	
	is_generating = true
	generate_button.disabled = true
	
	update_status("Initializing Wave Function Collapse...")
	await get_tree().create_timer(0.1).timeout
	
	island_generator.reset_grid()
	
	update_status("Collapsing wave functions...")
	await get_tree().create_timer(0.1).timeout
	
	var success = island_generator.generate_full()
	
	if not success:
		update_status("Generation incomplete - retrying...")
		await get_tree().create_timer(0.1).timeout
		island_generator.reset_grid()
		island_generator.generate_full()
	
	render_island()
	finish_generation()

func render_island():
	for y in range(grid_height):
		for x in range(grid_width):
			var tile = island_generator.get_tile(x, y)
			if tile != -1:
				var color = IslandGenerator.TILE_COLORS[tile]
				cell_visuals[y][x].color = color

func finish_generation():
	is_generating = false
	generate_button.disabled = false
	update_status("Island generated! Click Generate for a new one.")

func update_status(text: String):
	status_label.text = text
