extends ColorRect

var possible_tiles: Array = []
var collapsed: bool = false
var tile_type: int = -1

func _ready():
	custom_minimum_size = Vector2(40, 40)

func set_possibilities(tiles: Array):
	possible_tiles = tiles.duplicate()
	update_visual()

func set_collapsed_tile(tile: int, color: Color):
	collapsed = true
	tile_type = tile
	color = color
	update_visual()

func update_visual():
	if collapsed:
		# Solid color for collapsed tile
		color.a = 1.0
	else:
		# Semi-transparent white for uncollapsed
		color = Color(1, 1, 1, 0.3)

func get_entropy() -> int:
	if collapsed:
		return 0
	return possible_tiles.size()
